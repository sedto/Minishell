/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   tokenize_utils.c                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/10 16:50:01 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/15 00:49:16 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

int	is_operator_char(char c)
{
	return (c == '|' || c == '<' || c == '>');
}

static int	handle_unclosed_quote(t_shell_ctx *ctx)
{
	ctx->syntax_error = 1;
	printf("minishell: syntax error: unclosed quote\n");
	return (0);
}

static int	create_quoted_token(char *input, int start, int end,
		t_token **tokens)
{
	char	*content;
	t_token	*new_token;

	content = ft_substr(input, start + 1, end - start - 1);
	if (!content)
		return (0);
	new_token = create_token(TOKEN_WORD, content);
	free(content);
	if (!new_token)
		return (0);
	add_token_to_list(tokens, new_token);
	return (1);
}

int	handle_quoted_word(char *input, int *i, t_token **tokens,
		t_shell_ctx *ctx)
{
	char	quote_type;
	int		start;

	quote_type = input[*i];
	start = *i;
	(*i)++;
	while (input[*i] && input[*i] != quote_type)
		(*i)++;
	if (!input[*i])
		return (handle_unclosed_quote(ctx));
	if (!create_quoted_token(input, start, *i, tokens))
		return (0);
	(*i)++;
	return (1);
}
