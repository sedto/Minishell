/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   expand_helpers.c                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/07/07 17:20:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/25 11:11:36 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

/*
** Checks if string contains only spaces or tabs
*/
int	is_only_spaces(char *str)
{
	int	i;

	i = 0;
	if (!str)
		return (1);
	while (str[i])
	{
		if (str[i] != ' ' && str[i] != '\t')
			return (0);
		i++;
	}
	return (1);
}

/*
** Helper function to check if token should be removed
*/
static int	should_remove_token(t_token *token)
{
	if (token->type == TOKEN_EOF)
		return (0);
	if (!token->value || ft_strlen(token->value) == 0
		|| is_only_spaces(token->value))
		return (1);
	return (0);
}

/*
** Removes a single token from the list
*/
static t_token	*remove_single_token(t_token *tokens, t_token *current,
						t_token *prev, t_token *next)
{
	if (prev)
		prev->next = next;
	else
		tokens = next;
	free(current->value);
	free(current);
	return (tokens);
}

/*
** Removes empty tokens from linked list
*/
t_token	*remove_empty_tokens(t_token *tokens)
{
	t_token	*current;
	t_token	*prev;
	t_token	*next;

	current = tokens;
	prev = NULL;
	while (current)
	{
		next = current->next;
		if (current->type == TOKEN_EOF)
		{
			prev = current;
			current = next;
			continue ;
		}
		if (should_remove_token(current))
			tokens = remove_single_token(tokens, current, prev, next);
		else
			prev = current;
		current = next;
	}
	return (tokens);
}
