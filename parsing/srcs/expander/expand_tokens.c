/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   expand_tokens.c                                    :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/07/14 00:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/14 00:00:00 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

int	should_expand_token(char *value)
{
	int	len;

	if (!value)
		return (1);
	len = ft_strlen(value);
	if (len >= 2 && value[0] == '\'' && value[len - 1] == '\'')
		return (0);
	return (1);
}

static void	expand_single_token(t_token *current, char **envp, int exit_code)
{
	(void)envp;
	(void)exit_code;
	
	if (!current->value || !should_expand_token(current->value))
		return ;
	if (ft_strlen(current->value) == 0)
		return ;
	printf("DEBUG EXPAND_IN: [%s] - SKIPPED\n", current->value);
}

t_token	*expand_all_tokens(t_token *tokens, char **envp, int exit_code)
{
	t_token	*current;

	current = tokens;
	while (current)
	{
		expand_single_token(current, envp, exit_code);
		current = current->next;
	}
	return (tokens);
}
