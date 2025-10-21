/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   tokenize.c                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/03 00:09:49 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/03 11:26:12 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

/*
** Processes quotes in input string, advancing index to closing quote
*/
static int	process_quotes(char *input, int *i)
{
	char	quote;

	quote = input[*i];
	(*i)++;
	while (input[*i] && input[*i] != quote)
		(*i)++;
	if (input[*i] == quote)
		(*i)++;
	return (1);
}

/*
** Handles word tokens (commands, arguments, files)
** Manages quotes within words
*/
int	handle_word(char *input, int *i, t_token **tokens, t_shell_ctx *ctx)
{
	int		start;
	char	*word;
	t_token	*new_token;

	(void)ctx;
	start = *i;
	while (input[*i] && input[*i] != ' ' && input[*i] != '\t'
		&& input[*i] != '|' && input[*i] != '<' && input[*i] != '>')
	{
		if (input[*i] == '\'' || input[*i] == '"')
			process_quotes(input, i);
		else
			(*i)++;
	}
	word = ft_substr(input, start, *i - start);
	if (!word)
		return (0);
	new_token = create_token(TOKEN_WORD, word);
	free(word);
	if (!new_token)
		return (0);
	add_token_to_list(tokens, new_token);
	return (1);
}

/*
** Processes a character according to its type (operator or word)
*/
static int	process_character(char *input, int *i, t_token **tokens,
						t_shell_ctx *ctx)
{
	if (is_operator_char(input[*i]))
		return (handle_operator(input, i, tokens));
	else
		return (handle_word(input, i, tokens, ctx));
}

/*
** Main tokenization function: divides input into tokens
** Returns linked list of tokens for parsing
*/
t_token	*tokenize(char *input, t_shell_ctx *ctx)
{
	t_token	*tokens;
	int		i;

	tokens = NULL;
	i = 0;
	while (input[i])
	{
		skip_spaces(input, &i);
		if (!input[i])
			break ;
		if (!process_character(input, &i, &tokens, ctx))
			break ;
	}
	add_eof_token(&tokens);
	return (tokens);
}
