/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   env_utils.c                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/21 10:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/28 00:01:45 by dibsejra         ###   ########.fr       */
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

/* Initialise l'environnement depuis envp */
t_env	*init_env(char **envp)
{
	t_env	*env;
	t_env	*current;
	char	*equal_pos;
	char	*key;
	int		i;

	env = NULL;
	i = 0;
	while (envp[i])
	{
		equal_pos = ft_strchr(envp[i], '=');
		if (equal_pos)
		{
			key = ft_substr(envp[i], 0, equal_pos - envp[i]);
			if (key)
			{
				current = create_env_node(key, equal_pos + 1);
				free(key);
				if (current)
				{
					current->next = env;
					env = current;
				}
			}
		}
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

char	**env_to_tab(t_env *env)
{
	char	**tab;
	char	*entry;
	int		count;
	int		i;
	t_env	*current;

	// Compter le nombre d'éléments
	count = 0;
	current = env;
	while (current)
	{
		count++;
		current = current->next;
	}
	tab = malloc(sizeof(char *) * (count + 1));
	current = env;
	i = 0;
	while (current)
	{
		entry = ft_strjoin(current->key, "=");
		if (entry)
		{
			tab[i] = ft_strjoin(entry, current->value);
			free(entry);
		}
		current = current->next;
		i++;
	}
	tab[i] = NULL;
	return (tab);
}