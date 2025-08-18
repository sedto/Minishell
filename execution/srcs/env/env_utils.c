/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   env_utils.c                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/08/18 14:21:20 by dibsejra          #+#    #+#             */
/*   Updated: 2025/08/18 14:22:30 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../libft/libft.h"
#include "minishell.h"

/* Crée un nouveau node d'environnement */
t_env	*create_env_node(char *key, char *value)
{
	t_env	*node;

	node = malloc(sizeof(t_env));
	if (!node)
		return (NULL);
	node->key = ft_strdup(key);
	node->value = ft_strdup(value);
	if (!node->key || !node->value)
	{
		free(node->key);
		free(node->value);
		free(node);
		return (NULL);
	}
	node->next = NULL;
	return (node);
}

static t_env	*process_env_entry(char *entry, t_env *env)
{
	char	*equal_pos;
	char	*key;
	t_env	*current;

	equal_pos = ft_strchr(entry, '=');
	if (!equal_pos)
		return (env);
	key = ft_substr(entry, 0, equal_pos - entry);
	if (!key)
		return (env);
	current = create_env_node(key, equal_pos + 1);
	free(key);
	if (current)
	{
		current->next = env;
		env = current;
	}
	return (env);
}

/* Initialise l'environnement depuis envp */
t_env	*init_env(char **envp)
{
	t_env	*env;
	int		i;

	env = NULL;
	i = 0;
	while (envp[i])
	{
		env = process_env_entry(envp[i], env);
		i++;
	}
	return (env);
}

/* Trouve une variable dans l'environnement */
char	*get_env_value(t_env *env, char *key)
{
	while (env)
	{
		if (ft_strncmp(env->key, key, ft_strlen(key)) == 0
			&& ft_strlen(env->key) == ft_strlen(key))
			return (env->value);
		env = env->next;
	}
	return (NULL);
}

/* Définit ou met à jour une variable d'environnement */
void	set_env_value(t_minishell **s, char *key, char *value)
{
	t_env	*current;
	t_env	*new_node;

	current = (*s)->env;
	while (current)
	{
		if (ft_strncmp(current->key, key, ft_strlen(key)) == 0
			&& ft_strlen(current->key) == ft_strlen(key))
		{
			free(current->value);
			current->value = ft_strdup(value);
			return ;
		}
		current = current->next;
	}
	new_node = create_env_node(key, value);
	if (new_node)
	{
		new_node->next = (*s)->env;
		(*s)->env = new_node;
	}
}
