/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main_utils.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/20 16:41:33 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/20 21:29:24 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

/* Vérifie si l'input est une commande exit */
int	is_exit_command(char *input)
{
	return (ft_strncmp(input, "exit", 4) == 0 && (input[4] == '\0'
			|| input[4] == ' ' || input[4] == '\t'));
}

/* Parse une ligne d'input complète en commandes exécutables */
t_cmd	*parse_tokens(char *input, char **envp, int exit_code)
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

/* Traite une ligne d'input et retourne le code de sortie */
int	process_input(char *input, char **envp, int exit_code)
{
	t_cmd	*commands;

	commands = parse_tokens(input, envp, exit_code);
	if (!commands)
		return (1);
	free_commands(commands);
	return (0);
}

/* Gère une ligne d'input et détermine si on doit quitter */
int	handle_input_line(char *input, char **envp, int *exit_code)
{
	if (is_exit_command(input))
		return (1);
	else if (*input)
		*exit_code = process_input(input, envp, *exit_code);
	return (0);
}
