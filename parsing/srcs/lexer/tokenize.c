/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   tokenize.c                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/10 16:49:58 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/20 05:22:44 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

static void	skip_whitespace(char *input, int *i)
{
	while (input[*i] && (input[*i] == ' ' || input[*i] == '\t'))
		(*i)++;
}

static void	skip_quoted_section(char *input, int *i, char quote)
{
	(*i)++;
	while (input[*i] && input[*i] != quote)
		(*i)++;
	if (input[*i] == quote)
		(*i)++;
}

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
			skip_quoted_section(input, i, input[*i]);
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

static int	process_character(char *input, int *i, t_token **tokens,
		t_shell_ctx *ctx)
{
	if (is_operator_char(input[*i]))
		return (handle_operator(input, i, tokens));
	else
		return (handle_word(input, i, tokens, ctx));
}

t_token	*tokenize(char *input, t_shell_ctx *ctx)
{
	t_token	*tokens;
	int		i;

	tokens = NULL;
	i = 0;
	if (!input)
		return (NULL);
	while (input[i])
	{
		skip_whitespace(input, &i);
		if (input[i])
		{
			if (!process_character(input, &i, &tokens, ctx))
			{
				free_tokens(tokens);
				return (NULL);
			}
		}
	}
	add_eof_token(&tokens);
	return (tokens);
}
