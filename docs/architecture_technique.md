# Architecture Technique

## 1. Vue d'ensemble

En allant du plus haut au plus bas.

### User Interface

On a une interface qui contient plusieurs fenetre (cf. tab dans un navigateur).
Dans chaque fenetre on a :
	- Une section qui décrit la Pipe (input -> module1 -> moduleN -> output)
		Chaque module contient sa liste de parametre modifiable, son input et son output (sous forme de fleche vers le module suivant).
	- Une liste de module qu'on peut drag&drop dans la pipe qui contient tout les modules natif et Lua.
		Cette liste s'auto-reload en fonction des modification apporter dans le `UserFolder` et des fichiers Lua ajouter/modifier.
	- Une liste de bouton de sauvegarde/undo/redo/snapshot

## 2. Modèle de données central (ContentPayload, etc.)


## 3. Le contrat CipherModule (natif + Lua)

Un `CypherModule` (_abrégé_ `Module` _dans la plupart des documents_) est un outils qui contient les fonctions de cryptage, décryptage quand c'est possible.
Ce module doit definir sa  liste de parametre pour l'encryptage et le décryptage ainsi que préciser s'il est :
	- unidirectionnel / bidirectionnal
	- déterministe
		Des operation avec des floats ne sont basiquemetn pas determinisme
		Le random (suivant son implementation) n'est generalement pas deterministe

Ils doivent préciser leurs input et leurs output (`text`/`image`)
Ils doivent aussi préciser leurs paramètres et pour chacun leurs type (`string`/`img`/`int`/`uint`/`float`) et leurs nom/id.
	Exemple: Un Module `Text2Img` aura un input de texte et un output d'image


Un exemple en pseudo code baser sur du C
```pseudo-code

enum ResourceType {
	Text,
	Image,
};

class Resource {
	ResourceType type;
	string text;
	img image;
};

enum ParamType {
	string,
	img,
	int,
	uint,
	float,
};

class Parameter {
	string name;
	ParamType type;
	string stringifyParameter;
	
	string getParamAsString();
	img getParamAsImg();
	int getParamAsInt();
	uint getParamAsUint();
	float getParamAsFloat();
};

class MyCipherModule {
	List<Parameter> encryptParams;
	List<Parameter> decryptParams;
	
	uint GetEncrypParamCount();
	Parameter GetEncryptParam(uint index);
	
	uint GetDecrypParamCount();
	Parameter GetDecryptParam(uint index);
	
	ResourceType GetInputType();
	ResourceType GetOutputType();

	Resource Encrypt(Resource input, List<Parameter> parameters);
	Resource Decrypt(Resource input, List<Parameter> parameters);
};
```

Le contrat (ou l'interface) du CyperModule doit être suffisamment precise et générique qu'elle doit pouvoir être aussi bien implémenter en Lua, qu'en GDScript et hypotétiquement en n'importe quel langage.

## 4. Le ModuleLoader (fusion natif/Lua, hot-reload)

Le `ModuleLoader` est un composant dont le rôle est, à partir d'un nom/id, de trouver et charger le CypherModule correct. Qu'il vienne du Lua (_et donc d'un fichier disk_) ou de Godot (_et donc écris en GDScript et charger depuis l'executable_).

Son Role est donc de donner une reference (ou une handle) vers le module qui pourra a son tour être utiliser (via son interface la plus haute sans avoir a savoir si le module est ecris en Lua ou Natif).

Le Hot-Reload fonctionne grace a une validation (dans un thread secondaire ou dans la main thread) que les module Lua ont été changer. S'ils sont été changer on va les compiler/link et valider que le code fonctionner (ou retourner un message d'erreur sans alterer le module actuellement charger en memoire)

et si tout fonctionne on va alors échanger le module en memoire et broadcast un event comme quoi le module a ete reload (UI...)

```pseudocode

class CypherModule;
class GodotEvent;

struct ModuleHandle {
	// 0 means null
	uint handle;
};

class ModuleLoader {
	Map<ModuleHandle, CypherModule> loadedModules;
	GodotEvent onModuleLoaded;
	GodotEvent onModuleReloaded;
	GodotEvent onModuleUnloaded;
	
	// Check d'abord si l'ID existe dans le User Folder. S'il existe, il le charge,
	// sinon, regarde si module Godot existe, et renvoie son Handle (sans le recharger).
	ModuleHandle LoadModule(string id);
	CypherModule GetModule();
	bool _ModuleChanged(CypherModule module);
	void _ReloadModule(ModuleHandle handle, CypherModule module);
	void _LoadGodotModules();
	
	uint _frameCount = 0;
	uint _checkEveryXFrame = 10;
	
	void _ready() {
		_LoadGodotModules();
	}
	
	void _process() {
		if (_frameCount % _checkEveryXFrame == 0) {
			for (auto& [handle, module] : loadedModule) {
				if (_ModuleChanged(module)) {
					_ReloadModule(handle, module);
				}
			}
		} 
		_frameCount += 1;
	}
};

```

## 5. Le moteur de pipeline (exécution, undo/redo, snapshots)

### Pipeline

Une `Pipeline` est un outils qui permet d'ordonner des modules en chaine (_linéaire pour la V1, en Graph pour la V2_).

Pour ce faire, il faut definir les `Step` ainsi que les `Resource` et les `Parameter`.

Une `Resource` est un input/output de la pipeline entière ou d'un module. (cf. `CypherModule`). Elle est (dans la V1), un texte ou une image.

Un `Parameter` est le paramètre d'un module (_i.e. le décalage/shift dans un code caesae_). Il possede un type (`string`/`img`/`int`/`uint`/`float`), un nom et une valeur.

Les `Resource` et `Parameter` sont identifier de maniere unique (`UUID`) dans une `Pipeline`. Autrement dis, chaque resources et parametre de la pipeline et stocker dans une `Map` propre a chaque pipeline. (_Un faible travail sans intéret pour la V1 mais qui simplifiera la migration dans la V2_).

Les `Step` eux sont des **utilisations** de modules. Ils contiennent l'ID du module qu'ils utilisent, les ID des parametres qu'ils utilisent et est-ce que la step utilise la fonction de cryptage ou de décryptage ainsi que l'ID de leur output uniquement.
Leurs input ne sera fournis qu'a la traverser de la Pipeline, supprimant une problematique de synchronisation des input/output.
Les `Step` sont également stocker dans une `Map` avec un ID et l'ordre est une simple liste d'ID.
Le réagencement, l'insertion et la suppression ne demandant pas de synchronisation externe est simple.
Chaque `Step` possedant ses uniques `Resource` et `Parameter`, ils peuvent être supprimer en meme temps que les steps sont supprimer et creer de la meme maniere.
N'utiliser que des ID (ou handle) pour les `CypherModule` permet de limiter toute interdependance avec le `ModuleLoader` et notamment avec le Hot-Reload.
(d'autre information de debug comme le nom, le path, etc peuvent etre stocker dans les Step mais rien qui ne puisse pas être supprimer ou ne rajoute de dependance).

La serialisation d'une pipeline se repose donc sur la serialisation de ses 3 `Map` (resources/parameters/steps) ainsi que de son ordre.
Pas de sérialisation des Resources, uniquement de leurs parametre d'utilisation/creation (taille de l'image, format du texte UTF8/ASCII). En revanche, serialisation des valeurs des parametres. 

### Undo / Redo

Chaque action dans l'interface utilisateur est definie par une `Command`. Une commande est immuable est doit definir, a sa creation, comment realiser son action et comment l'annuler (undo/redo)


## 6. Le pont Lua (API exposée, limites volontaires)


## 7. Gestion des erreurs et logs
