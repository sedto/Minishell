/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   create_tokens.c                                    :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/02 23:45:06 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/03 01:32:29 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

t_token	*create_token(t_token_type type, char *value)
{
	t_token	*token;

	token = malloc(sizeof(t_token));
	if (!token)
		return (NULL);
	token->value = ft_strdup(value);
	if (!token->value)
	{
		free(token);
		return (NULL);
	}
	token->type = type;
	token->next = NULL;
	return (token);
}

// Ajoute un token à la fin de la liste chaînée
void	add_token_to_list(t_token **tokens, t_token *new_token)
{
	t_token	*current;

	if (!new_token)
		return ;
	if (!*tokens)
	{
		*tokens = new_token;
		return ;
	}
	current = *tokens;
	while (current->next)
		current = current->next;
	current->next = new_token;
}

// Libère tous les tokens d'une liste
void	free_tokens(t_token *tokens)
{
	t_token	*current;
	t_token	*next;

	current = tokens;
	while (current)
	{
		next = current->next;
		if (current->value)
			free(current->value);
		free(current);
		current = next;
	}
}