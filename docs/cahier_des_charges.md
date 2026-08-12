# Cahier des Charges

## Contexte et Objectifs

### Contexte

J'aimerais créer des énigmes facilement avec la certitude que mon énigmes est fiable (_pas d'erreur de copier coller ou de faute de frappe dans le parcours_)
J'aimerais également avoir une boite à outils de cryptographie qui centralise tous les algos pour réaliser ces énigmes
J'aimerais pouvoir faire un logiciel que je peux partager a mes joueurs pour qu'ils puissent resoudre mes enigmes
J'aimerais pouvoir partager cette application et que tout le monde puisse ajouter ses propres outils dans la boite a outils sans pour autant avoir a changer le code source.
J'aimerais utiliser cette outils comme une opportunité d'en apprendre plus sur Godot et d'expérimenter dessus

### Objectifs

- Avoir des outils d'encryptage de texte et d'image
- On doit pouvoir construire des outils de cryptage en Lua (encodage/decodage).
- On doit pouvoir assembler une liste de module pour pour crypter/decrypter un message.
- Les inputs et outputs de tout le pipeline doivent representer en temps réel l'état de decryptage.
- Les algorithmes d'encryptage / décryptage sont charger au runtime (_avec hot-reload_)
	- Certains algorithmes peuvent être natif mais override si des modules Lua possede le même nom
- L'outils doit être visuellement intuitif a utiliser (UX)

### Hors Périmètre

- modèles 3D, non traité avant V2+

## Utilisateurs et cas d'usage

- En tant que **MJ**, je veux **une liste d'outils de cryptographie au même endroit** pour pouvoir **créer des énigmes**
- En tant que **Joueurs/Solveur**, je veux **une liste d'outils de cryptographie au même endroit** pour pouvoir **résoudre des énigmes**. 
- En tant que **MJ/Développeur**, je veux pouvoir **facilement ajouter des outils (_de cryptographie_)** pour **créer mes énigmes**.
- En tant qu'**Amateur d'énigmes/MJ/Joueurs**, je veux pouvoir **partager mes pipelines d'encryptions/décriptions** pour pouvoir **aider la communauter avec des énigmes élégante/intéréssante**.
- En tant que **Développeur de modules** j'aimerais pouvoir **avoir une vision de comment mon algorithmes marche et des erreurs potentiels** pour pouvoir **debugger facilement mes algorithmes**
- En tant qu'**Utilisateur**, j'aimerais pouvoir **sauvegarder/charger un ou plusieurs pipeline** pour pouvoir reprendre mon travail plus tard.
- En tant que **MJ**, j'aimerais savoir **si un des blocs que j'utilise est a sens unique**
- En tant que **MJ**, j'aimerais pouvoir **obtenir une liste des clefs/parametres necessaire a connaitre pour résoudre mon énigmes** afin de pouvoir les transmettres a mes joueurs sous quelques maniere que je souhaite.

## Fonctionnalités

### MVP (V1)

- Réaliser une pipeline linéaire de module de cryptage (texte/image)
- Permettre de créer des modules en Lua
- Afficher en temps réel et continuellement les inputs/output de chacun des modules
- Avoir un module pour ajouter/retirer du texte en debut/fin/range/... dans un texte (i.e. donner des indices ou les retirer)
- Avoir des modules de base en GDScript
	- Permettre d'override des module GDScript avec du Lua moyennant le bon ID.
- Permettre de creer et tagger un module comme unidirectionnel ou bidirectionnel (et afficher si la pipeline est reversible)
- Permettre d'exporter, pour une lecture humaine, les clefs/paramètres des différents modules.
- Permettre de sauvegarde/charger une pipeline de cryptage/decryptage
	- Mettre suffisamment d'information sur les modules utiliser pour valider que l'utilisateur qui importe une pipeline possede bien le module utiliser (i.e. hash file, GDScript/Lua, etc)
- Mettre une console de log qui apparait affiche les logs des modules Lua. (_Ajouter la stacktrace si possible_)
	- Permettre d'exporter les logs dans un fichier texte (pour etre remonter aux developpeur du Module par exemple)
- Permettre de copier coller les textes/images de n'importe quel output/input
- Permettre un historique complet et retour arrière/retour avant dans la création de Pipe (pas pour le load/hot-reload de module Lua) et par Pipe si on a plusieurs Pipe ouverte en simultanée
- Permettre de faire une snapshot d'un etat de la pipe (_historique non-inclus_) pendant l'editions pour permettre d'experimenter facilement et revenir a une snapshot sans pour autant avoir a faire une sauvegarde/rechargement complet. 
	- Permettre d'ouvrir une snapshot dans un "nouvel onglet"

### V2 et au-delà

- Réaliser une pipeline nodale de module de cryptage (texte/image) (i.e. Unreal Blueprint)
	- Permettre le passage unidirectionnel (ou bi-directionnel quand c'est possible) d'une pipeline linéaire à nodale
	- Permettre de lier des outputs de nodes dans des inputs ou des parametres d'autres nodes
- Ajouter un "Mode Développeur" qui ajouterais une fenetre d'edition de Lua et une fenetre avec tout les scripts Lua, permettre de les sandboxer pour les tester, les debugger avec des breackpoint et tout l'attirail de developpement traditionnel.
- (_bien plus tard_) Ajouter du Multijoueur pour permettre la résolution d'énigme en équipe
- Ajouter des notes (formattable, Markdown par exemple) dans une pipeline (nodal ou linéaire)
- Rajouter l'historique au complet dans une snapshot d'edition
- Permettre de sauvegarde un état de travail (_Une pipe, son historique et ses snapshots_) pour pouvoir les partager ou revenir dessus plus tard avec l'historique au complet.

## Contraintes Techniques

- Utilisation de Godot `>=4.7` (_suseptible d'évoluer au fil du developement_)
- Target Desktop (Win/Linux/Mac)
- Utilisation de Lua pour réaliser les modules (donc utilisation du plugin `lua-gdextension`)
- Compilation d'un executable seul qui embarque tout
- Developpement du logiciel en license MIT
- Contrainte d'image propre a ce que Godot est capable d'importer nativement (en V1)
- Les modules communautaires sont externes au dépôt et à la licence du logiciel ; aucune licence n'est imposée aux créateurs de modules.
