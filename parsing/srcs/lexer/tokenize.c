/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   tokenize.c                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/03 00:09:49 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/03 02:08:26 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

// Gère les mots simples (commandes, arguments, fichiers)
int	handle_word(char *input, int *i, t_token **tokens)
{
	int		start;
	char	*word;
	t_token	*new_token;

	start = *i;
	while (input[*i] && input[*i] != ' ' && input[*i] != '\t'
		&& input[*i] != '|' && input[*i] != '<' && input[*i] != '>'
		&& input[*i] != '\'' && input[*i] != '"')
		(*i)++;
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

// Traite un caractère selon son type (quote, opérateur, ou mot)
static int	process_character(char *input, int *i, t_token **tokens)
{
	if (is_quote(input[*i]))
		return (handle_quoted_word(input, i, tokens));
	else if (is_operator_char(input[*i]))
		return (handle_operator(input, i, tokens));
	else
		return (handle_word(input, i, tokens));
}

t_token	*tokenize(char *input)
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
		if (!process_character(input, &i, &tokens))
		{
			free_tokens(tokens);
			return (NULL);
		}
	}
	add_eof_token(&tokens);
	return (tokens);
}
