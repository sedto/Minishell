# Documentation Parsing Minishell


## 1. Vue d’ensemble du parsing

Le parsing transforme la ligne de commande utilisateur (string) en une structure de commandes exploitable par l’exécuteur. Il gère :
- La tokenisation (découpage en mots, opérateurs, redirections…)
- L’expansion des variables
- La gestion des quotes
- La validation syntaxique
- La construction de la structure de commandes (commandes, arguments, redirections, pipes…)

---

## 2. Organisation des fichiers

- **lexer/** : Découpe la ligne en tokens (mots, opérateurs, redirections).
- **expander/** : Gère l’expansion des variables d’environnement et des quotes.
- **parser/** : Construit la structure de commandes à partir des tokens.
- **utils/** : Fonctions utilitaires pour le nettoyage et la gestion de l’input.

---

## 3. Structures principales

- `t_token` : Représente un token (mot, opérateur, redirection, etc.).
- `t_command` : Représente une commande complète (nom, arguments, redirections, pipe suivant, etc.).
- `t_redirection` : Représente une redirection (type, fichier cible, etc.).

---

## 4. Flux du parsing

1. **Nettoyage de l’input** (`clean_input.c`) :
   - Supprime les espaces inutiles, gère les cas particuliers.
2. **Tokenisation** (`lexer/tokenize.c`) :
   - Découpe la ligne en tokens (mots, opérateurs, redirections).
3. **Expansion** (`expander/expand_process.c`) :
   - Remplace les variables d’environnement, gère les quotes.
4. **Parsing** (`parser/parse_commands.c`, `parser/parse_handlers.c`) :
   - Construit la liste chaînée de commandes et d’arguments.
   - Associe les redirections à la bonne commande.
   - Gère les pipes et la séparation des commandes.
5. **Validation** (`parser/parse_validation.c`) :
   - Vérifie la syntaxe (quotes fermées, redirections valides, etc.).
6. **Suppression des tokens vides** (`parser/parse_utils.c`) :
   - Nettoie la liste de tokens pour éviter les commandes vides.

---

## 5. Détail des fonctions clés (parser/)

### `parse_commands.c`
- **parse_commands** : Point d’entrée du parsing, construit la liste de commandes à partir des tokens.
- **parse_command** : Traite une commande unique, collecte ses arguments et redirections.

### `parse_handlers.c`
- **handle_redirection** : Associe une redirection à la commande courante.
- **handle_argument** : Ajoute un argument à la commande courante.

### `create_commande.c`
- **create_command** : Alloue et initialise une nouvelle structure de commande.
- **add_argument** : Ajoute un argument à la commande.
- **add_redirection** : Ajoute une redirection à la commande.

### `parse_utils.c`
- **skip_whitespace_tokens** : Ignore les tokens d’espaces.
- **is_redirection_token** : Détecte si un token est une redirection.

### `parse_validation.c`
- **validate_syntax** : Vérifie la validité syntaxique de la ligne.

### `quote_remover.c`
- **remove_quotes** : Supprime les quotes autour des arguments après parsing.

---


## 6. Points d’attention

- Les arguments après une redirection sont bien ajoutés à la commande (cf. tests echo/redirection).
- Les pipes séparent les commandes, mais chaque commande peut avoir ses propres redirections.
- La gestion des erreurs de syntaxe doit être robuste (quotes, redirections invalides).

---

## 7. Pour aller plus loin

- Voir les fichiers sources pour des commentaires détaillés sur chaque fonction.
- Se référer au fichier `todo.txt` pour les bugs/exceptions connues et les priorités de correction.

---
