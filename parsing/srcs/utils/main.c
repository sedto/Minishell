/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/05/26 22:24:01 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/03 01:32:25 by dibsejra         ###   ########.fr       */
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
static void	print_tokens(t_token *tokens)
{
	t_token	*current;

	current = tokens;
	printf("Tokens: ");
	while (current)
	{
		printf("[%s:\"%s\"]", token_type_to_string(current->type), 
			current->value);
		if (current->next)
			printf(" ");
		current = current->next;
	}
	printf("\n");
}

// Traite une ligne d'input et teste le lexer
static int	process_input(char *input)
{
	char	*cleaned_input;
	t_token	*tokens;

	printf("\n=== Test du lexer ===\n");
	printf("Input: \"%s\"\n", input);
	
	cleaned_input = clean_input(input);
	if (!cleaned_input)
	{
		printf("Erreur: allocation mémoire lors du nettoyage\n");
		return (1);
	}
	printf("Cleaned: \"%s\"\n", cleaned_input);
	
	tokens = tokenize(cleaned_input);
	if (!tokens)
	{
		printf("Erreur: échec de la tokenisation\n");
		free(cleaned_input);
		return (1);
	}
	
	print_tokens(tokens);
	
	free_tokens(tokens);
	free(cleaned_input);
	return (0);
}

// Fonction pour tester des cas prédéfinis
static void	run_predefined_tests(void)
{
	printf("\n🧪 === TESTS PRÉDÉFINIS DU LEXER ===\n");
	
	printf("\n--- Test 1: Commande simple ---");
	process_input("echo hello");
	
	printf("\n--- Test 2: Avec quotes ---");
	process_input("echo \"hello world\"");
	
	printf("\n--- Test 3: Pipe ---");
	process_input("ls | grep test");
	
	printf("\n--- Test 4: Redirections ---");
	process_input("cat < input >> output");
	
	printf("\n--- Test 5: Heredoc ---");
	process_input("cat << EOF");
	
	printf("\n--- Test 6: Quotes simples ---");
	process_input("echo 'single quotes'");
	
	printf("\n--- Test 7: Complexe ---");
	process_input("ls -la | grep \".txt\" > output");
	
	printf("\n=== FIN DES TESTS ===\n");
}

// Boucle principale du shell
int	main(void)
{
	char	*input;

	printf("🚀 Minishell - Test du Lexer\n");
	printf("Tapez 'test' pour les tests prédéfinis, ou une commande pour la tester\n");
	printf("Tapez 'exit' ou Ctrl+D pour quitter\n");

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
			run_predefined_tests();
		}
		else if (*input)
		{
			process_input(input);
		}
		
		free(input);
	}
	return (0);
}