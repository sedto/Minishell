/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/05/26 22:24:01 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/20 03:08:24 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

// Variable globale pour les signaux (obligatoire selon le sujet)
volatile sig_atomic_t	g_signal = 0;

// Parse et nettoie les tokens
static t_cmd	*parse_tokens(char *input, char **envp, int exit_code)
{
	char	*cleaned_input;
	t_token	*tokens;
	t_cmd	*commands;

	cleaned_input = clean_input(input);
	if (!cleaned_input)
		return (NULL);
	tokens = tokenize(cleaned_input);
	if (!tokens)
	{
		free(cleaned_input);
		return (NULL);
	}
	tokens = expand_all_tokens(tokens, envp, exit_code);
	commands = parse_tokens_to_commands(tokens);
	if (!commands)
	{
		free_tokens(tokens);
		free(cleaned_input);
		return (NULL);
	}
	remove_quotes_from_commands(commands);
	free_tokens(tokens);
	free(cleaned_input);
	return (commands);
}

// Traite une ligne d'entrée utilisateur complète
static int	process_input(char *input, char **envp, int exit_code)
{
	t_cmd	*commands;

	commands = parse_tokens(input, envp, exit_code);
	if (!commands)
		return (1);
	free_commands(commands);
	return (0);
}

// Gère une ligne d'entrée utilisateur
static int	handle_input_line(char *input, char **envp, int *exit_code)
{
	if (ft_strncmp(input, "exit", 4) == 0)
		return (1);
	else if (*input)
		*exit_code = process_input(input, envp, *exit_code);
	return (0);
}

// Boucle principale du minishell
int	main(int argc, char **argv, char **envp)
{
	char	*input;
	int		exit_code;

	(void)argc;
	(void)argv;
	exit_code = 0;
	while (1)
	{
		input = readline("minishell$ ");
		if (!input)
		{
			printf("exit\n");
			break ;
		}
		if (*input)
			add_history(input);
		if (handle_input_line(input, envp, &exit_code))
		{
			free(input);
			break ;
		}
		free(input);
	}
	return (exit_code);
}
