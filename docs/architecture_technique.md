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

Un module est un outils qui contient les fonctions de cryptage, décryptage quand c'est possible et une liste de parametre qui influe son fonctionnement. (Soit les meme pour les deux, soit un ensemble pour chaque foncitonnalité)
Ils peuvent etre ecris nativement en `GDScript` ou en `Lua`
Un module doit explicitement mentionner s'il est `unidirection`/`bidirectionnel`;`déterministe` ou non
	Des operation avec des floats ne sont basiquemetn pas determinisme
	Le random (suivant son implementation) n'est generalement pas deterministe
Ils doivent préciser leurs input et leurs output (`text`/`image`) ainsi que leurs parametres (`string`/`img`/`int`/`uint`/`float`)
	Exemple: Un Module `Text2Img` aura un input de texte et un output d'image

```pseudo-code

enum ParamType {
	string,
	img,
	int,
	uint,
	float,
}

class Parameter {
	string name;
	ParamType type;
	string stringifyParameter;
	
	string getParamAsString();
	img getParamAsImg();
	int getParamAsInt();
	uint getParamAsUint();
	float getParamAsFloat();
}

class MyCipherModule {
	
}
```



## 4. Le ModuleLoader (fusion natif/Lua, hot-reload)


## 5. Le moteur de pipeline (exécution, undo/redo, snapshots)

### Pipeline

Une Pipeline est une liste de module ordonnées. dont chacun des output d'un module corresponde à l'input d'un autre.
On associe a chaque instance d'un module un ID pour mieux les repérer (et préparer le passage au nodal en V2)

Une pipeline permet pour un input definit de passer dans tout les modules et de donner un output.

Une pipeline doit pouvoir etre serialiser et deserialiser

### Undo / Redo

Chaque action dans l'interface utilisateur est definie par une `Command`. Une commande est immuable est doit definir, a sa creation, comment realiser son action et comment l'annuler (undo/redo)


## 6. Le pont Lua (API exposée, limites volontaires)


## 7. Gestion des erreurs et logs
