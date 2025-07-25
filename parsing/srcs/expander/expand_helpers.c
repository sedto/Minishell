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

/* Vérifie si une chaîne ne contient que des espaces ou tabulations */
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

/* Supprime les tokens vides de la liste chaînée */
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
			continue;
		}
		if (!current->value || ft_strlen(current->value) == 0
			|| is_only_spaces(current->value))
		{
			if (prev)
				prev->next = next;
			else
				tokens = next;
			free(current->value);
			free(current);
		}
		else
			prev = current;
		current = next;
	}
	return (tokens);
}
