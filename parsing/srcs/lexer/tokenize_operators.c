/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   tokenize_operators.c                               :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/03 01:35:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/03 02:05:55 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

// Gère les opérateurs doubles (<<, >>)
static t_token	*handle_double_operator(char *input, int *i)
{
	t_token	*new_token;

	new_token = NULL;
	if (input[*i] == '<' && input[*i + 1] == '<')
	{
		new_token = create_token(TOKEN_HEREDOC, "<<");
		(*i) += 2;
	}
	else if (input[*i] == '>' && input[*i + 1] == '>')
	{
		new_token = create_token(TOKEN_APPEND, ">>");
		(*i) += 2;
	}
	return (new_token);
}

// Gère les opérateurs de redirection d'entrée (<, <<)
t_token	*handle_input_redir(char *input, int *i)
{
	t_token	*new_token;

	if (input[*i + 1] == '<')
		new_token = handle_double_operator(input, i);
	else
	{
		new_token = create_token(TOKEN_REDIR_IN, "<");
		(*i)++;
	}
	return (new_token);
}

// Gère les opérateurs de redirection de sortie (>, >>)
t_token	*handle_output_redir(char *input, int *i)
{
	t_token	*new_token;

	if (input[*i + 1] == '>')
		new_token = handle_double_operator(input, i);
	else
	{
		new_token = create_token(TOKEN_REDIR_OUT, ">");
		(*i)++;
	}
	return (new_token);
}

int	handle_operator(char *input, int *i, t_token **tokens)
{
	t_token	*new_token;

	new_token = NULL;
	if (input[*i] == '|')
	{
		new_token = create_token(TOKEN_PIPE, "|");
		(*i)++;
	}
	else if (input[*i] == '<')
		new_token = handle_input_redir(input, i);
	else if (input[*i] == '>')
		new_token = handle_output_redir(input, i);
	if (!new_token)
		return (0);
	add_token_to_list(tokens, new_token);
	return (1);
}
