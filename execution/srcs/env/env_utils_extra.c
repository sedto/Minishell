/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   env_utils_extra.c                                  :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by user              #+#    #+#             */
/*   Updated: 2025/08/15 17:38:07 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../libft/libft.h"
#include "minishell.h"

/* Supprime une variable d'environnement */
void	unset_env_value(t_minishell **s, char *key)
{
	t_env	*current;
	t_env	*prev;

	current = (*s)->env;
	prev = NULL;
	while (current)
	{
		if (ft_strncmp(current->key, key, ft_strlen(key)) == 0
			&& ft_strlen(current->key) == ft_strlen(key))
		{
			if (prev)
				prev->next = current->next;
			else
				(*s)->env = current->next;
			free(current->key);
			free(current->value);
			free(current);
			return ;
		}
		prev = current;
		current = current->next;
	}
}

/* Libère toute la liste d'environnement */
void	free_env(t_env *env)
{
	t_env	*next;

	while (env)
	{
		next = env->next;
		free(env->key);
		free(env->value);
		free(env);
		env = next;
	}
}

void	free_minishell(t_minishell *s)
{
	if (!s)
		return ;
	free_env(s->env);
	if (s->commands)
	{
		free_commands(s->commands);
		s->commands = NULL;
	}
	if (s->tokens)
	{
		free_tokens(s->tokens);
		s->tokens = NULL;
	}
	if (s->saved_stdout > 0)
		close(s->saved_stdout);
	if (s->saved_stdin > 0)
		close(s->saved_stdin);
	free(s);
}
