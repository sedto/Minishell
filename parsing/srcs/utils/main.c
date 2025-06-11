/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/05/26 22:24:01 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/11 16:05:12 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

// Variable globale pour les signaux (obligatoire selon le sujet)
volatile sig_atomic_t	g_signal = 0;

// Convertit le type de token en chaîne pour l'affichage
static char	*token_type_to_string(t_token_type type)
{
	if (type == TOKEN_WORD)
		return ("WORD");
	else if (type == TOKEN_PIPE)
		return ("PIPE");
	else if (type == TOKEN_REDIR_IN)
		return ("REDIR_IN");
	else if (type == TOKEN_REDIR_OUT)
		return ("REDIR_OUT");
	else if (type == TOKEN_APPEND)
		return ("APPEND");
	else if (type == TOKEN_HEREDOC)
		return ("HEREDOC");
	else if (type == TOKEN_EOF)
		return ("EOF");
	return ("UNKNOWN");
}

// Affiche tous les tokens d'une liste
static void print_tokens(t_token *tokens)
{
    t_token *current = tokens;
    
    while (current) {
        printf("[%s:", token_type_to_string(current->type));
        
        // DEBUG : affiche char par char
        printf("'");
        for (int i = 0; current->value[i]; i++) {
            printf("%c", current->value[i]);
        }
        printf("'");
        
        printf("]");
        if (current->next) printf(" ");
        current = current->next;
    }
    printf("\n");
}

// Fonction pour valider si l'expansion est correcte
// Traite une ligne d'input et teste le lexer avec expansion
static int	process_input(char *input, char **envp, int exit_code)
{
	char	*cleaned_input;
	t_token	*tokens;

	printf("\n=== Test du lexer avec expansion ===\n");
	printf("Input: \"%s\"\n", input);
	
	// Phase 1: Nettoyage (✅ existe déjà)
	cleaned_input = clean_input(input);
	if (!cleaned_input)
	{
		printf("Erreur: allocation mémoire lors du nettoyage\n");
		return (1);
	}
	printf("Cleaned: \"%s\"\n", cleaned_input);
	
	// Phase 2: Tokenisation (✅ existe déjà)
	tokens = tokenize(cleaned_input);
	if (!tokens)
	{
		printf("Erreur: échec de la tokenisation\n");
		free(cleaned_input);
		return (1);
	}
	
	printf("🔍 Tokens AVANT expansion:\n");
	print_tokens(tokens);
	
	// Phase 3: Expansion des variables (🆕 NOUVEAU!)
	tokens = expand_all_tokens(tokens, envp, exit_code);
	
	printf("✨ Tokens APRÈS expansion:\n");
	print_tokens(tokens);
	
	// Validation de l'expansion (🆕 NOUVEAU!)
	free_tokens(tokens);
	free(cleaned_input);
	return (0);
}

// Fonction pour tester des cas prédéfinis avec expansion
static void	run_predefined_tests(char **envp, int exit_code)
{
	printf("\n🧪 === TESTS EXPANSION VARIABLES ===\n");
	
	printf("\n--- Test 1: Variable simple ---");
	printf("\nAttendu: [WORD:'echo'] [WORD:'%s'] [EOF:'']\n", getenv("USER"));
	process_input("echo $USER", envp, exit_code);
	
	printf("\n--- Test 2: Variable dans double quotes ---");
	printf("\nAttendu: [WORD:'echo'] [WORD:'\"Hello %s\"'] [EOF:'']\n", getenv("USER"));
	process_input("echo \"Hello $USER\"", envp, exit_code);
	
	printf("\n--- Test 3: Variable dans single quotes (PAS d'expansion) ---");
	printf("\nAttendu: [WORD:'echo'] [WORD:'$USER'] [EOF:'']\n");
	process_input("echo '$USER'", envp, exit_code);
	
	printf("\n--- Test 4: Variable spéciale $? ---");
	printf("\nAttendu: [WORD:'echo'] [WORD:'42'] [EOF:'']\n");
	process_input("echo $?", envp, 42);
	
	printf("\n--- Test 5: Variables multiples ---");
	printf("\nAttendu: [WORD:'echo'] [WORD:'%s'] [WORD:'%s'] [EOF:'']\n", 
		getenv("USER"), getenv("HOME"));
	process_input("echo $USER $HOME", envp, exit_code);
	
	printf("\n--- Test 6: Variables concaténées ---");
	printf("\nAttendu: [WORD:'echo'] [WORD:'%s%s'] [EOF:'']\n", 
		getenv("USER"), getenv("HOME"));
	process_input("echo $USER$HOME", envp, exit_code);
	
	printf("\n--- Test 7: Variable inexistante ---");
	printf("\nAttendu: [WORD:'echo'] [WORD:''] [EOF:'']\n");
	process_input("echo $INEXISTANTE", envp, exit_code);
	
	printf("\n--- Test 8: $ seul (pas une variable) ---");
	printf("\nAttendu: [WORD:'echo'] [WORD:'$'] [EOF:'']\n");
	process_input("echo $", envp, exit_code);
	
	printf("\n=== FIN DES TESTS ===\n");
}

// Boucle principale du shell avec expansion
int	main(int argc, char **argv, char **envp)
{
	char	*input;
	int		exit_code;

	(void)argc;
	(void)argv;
	exit_code = 0;
	printf("🚀 Minishell - Test du Lexer avec Variables\n");
	printf("Variables disponibles: USER, HOME, PWD, ?\n");
	printf("Tapez 'test' pour les tests prédéfinis\n");
	printf("Tapez 'exit' ou Ctrl+D pour quitter\n\n");

	while (1)
	{
		input = readline("minishell$ ");
		if (!input)
		{
			printf("\nexit\n");
			break ;
		}
		if (*input)
			add_history(input);
		
		if (ft_strncmp(input, "exit", 4) == 0)
		{
			free(input);
			break ;
		}
		else if (ft_strncmp(input, "test", 4) == 0)
		{
			run_predefined_tests(envp, exit_code);
		}
		else if (*input)
		{
			process_input(input, envp, exit_code);
			exit_code = 0;
		}
		
		free(input);
	}
	return (0);
}