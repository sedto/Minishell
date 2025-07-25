/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   tokenize_utils.c                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/03 01:20:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/28 02:09:49 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

/*
** Checks if character is an operator (|, <, >)
*/
int	is_operator_char(char c)
{
	return (c == '|' || c == '<' || c == '>');
}

/*
** Skips spaces and tabs in input string
*/
void	skip_spaces(char *input, int *i)
{
	while (input[*i] == ' ' || input[*i] == '\t')
		(*i)++;
}

/*
** Adds EOF token at the end of token list
*/
void	add_eof_token(t_token **tokens)
{
	t_token	*eof_token;

	eof_token = create_token(TOKEN_EOF, "");
	if (eof_token)
		add_token_to_list(tokens, eof_token);
}

/*
** Processes content between quotes, handles unclosed quotes
*/
static int	process_quote_content(char *input, int *i, char quote_type,
						t_shell_ctx *ctx)
{
	(*i)++;
	while (input[*i] && input[*i] != quote_type)
		(*i)++;
	if (!input[*i])
	{
		ctx->syntax_error = 1;
		printf("minishell: syntax error: unclosed quote\n");
		return (0);
	}
	return (1);
}

/*
** Handles words between quotes, creates corresponding token
*/
int	handle_quoted_word(char *input, int *i, t_token **tokens, t_shell_ctx *ctx)
{
	char	quote_type;
	int		start;
	char	*content;
	t_token	*new_token;

	quote_type = input[*i];
	start = *i;
	if (!process_quote_content(input, i, quote_type, ctx))
		return (0);
	content = ft_substr(input, start + 1, *i - start - 1);
	if (!content)
		return (0);
	new_token = create_token(TOKEN_WORD, content);
	free(content);
	if (!new_token)
		return (0);
	add_token_to_list(tokens, new_token);
	(*i)++;
	return (1);
}
