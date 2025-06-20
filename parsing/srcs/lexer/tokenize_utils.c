/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   tokenize_utils.c                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/03 01:20:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/20 03:38:07 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

/* Vérifie si le caractère est un guillemet */
int	is_quote(char c)
{
	return (c == '\'' || c == '"');
}

/* Vérifie si le caractère est un opérateur */
int	is_operator_char(char c)
{
	return (c == '|' || c == '<' || c == '>');
}

/* Ignore les espaces et tabulations */
void	skip_spaces(char *input, int *i)
{
	while (input[*i] == ' ' || input[*i] == '\t')
		(*i)++;
}

/* Ajoute un token EOF à la fin de la liste */
void	add_eof_token(t_token **tokens)
{
	t_token	*eof_token;

	eof_token = create_token(TOKEN_EOF, "");
	if (eof_token)
		add_token_to_list(tokens, eof_token);
}

/* Gère les mots entre guillemets */
int	handle_quoted_word(char *input, int *i, t_token **tokens)
{
	char	quote_type;
	int		start;
	char	*content;
	t_token	*new_token;

	quote_type = input[*i];
	start = *i;
	(*i)++;
	while (input[*i] && input[*i] != quote_type)
		(*i)++;
	if (input[*i] == quote_type)
		(*i)++;
	content = ft_substr(input, start, *i - start);
	if (!content)
		return (0);
	new_token = create_token(TOKEN_WORD, content);
	free(content);
	if (!new_token)
		return (0);
	add_token_to_list(tokens, new_token);
	return (1);
}
