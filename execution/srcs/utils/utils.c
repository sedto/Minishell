/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   utils.c                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/21 10:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/28 00:01:47 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

/* Convertit t_env en tableau char** pour execve */
char	**env_to_array(t_env *env)
{
	t_env	*current;
	char	**envp;
	char	*temp;
	int		count;
	int		i;

	count = 0;
	current = env;
	while (current)
	{
		count++;
		current = current->next;
	}
	envp = malloc(sizeof(char *) * (count + 1));
	if (!envp)
		return (NULL);
	current = env;
	i = 0;
	while (current && i < count)
	{
		temp = ft_strjoin(current->key, "=");
		if (temp)
		{
			envp[i] = ft_strjoin(temp, current->value);
			free(temp);
		}
		if (!envp[i])
		{
			while (--i >= 0)
				free(envp[i]);
			free(envp);
			return (NULL);
		}
		current = current->next;
		i++;
	}
	envp[i] = NULL;
	return (envp);
}

/* Libère un tableau char** */
void	free_array(char **array)
{
	int	i;

	if (!array)
		return ;
	i = 0;
	while (array[i])
	{
		free(array[i]);
		i++;
	}
	free(array);
}

/* Cherche un exécutable dans PATH */
char	*find_executable(char *cmd, t_env *env)
{
	char	*path_env;
	char	**paths;
	char	*full_path;
	char	*temp;
	int		i;

	if (ft_strchr(cmd, '/'))
	{
		if (access(cmd, F_OK | X_OK) == 0)
			return (ft_strdup(cmd));
		return (NULL);
	}
	path_env = get_env_value(env, "PATH");
	if (!path_env)
		return (NULL);
	paths = ft_split(path_env, ':');
	if (!paths)
		return (NULL);
	i = 0;
	while (paths[i])
	{
		temp = ft_strjoin(paths[i], "/");
		if (temp)
		{
			full_path = ft_strjoin(temp, cmd);
			free(temp);
			if (full_path && access(full_path, F_OK | X_OK) == 0)
			{
				free_array(paths);
				return (full_path);
			}
			free(full_path);
		}
		i++;
	}
	free_array(paths);
	return (NULL);
}

/* Compte le nombre de commandes dans un pipeline */
int	count_commands(t_cmd *commands)
{
	int	count;

	count = 0;
	while (commands)
	{
		count++;
		commands = commands->next;
	}
	return (count);
}

/* Affiche une erreur de commande non trouvée */
void	command_not_found(char *cmd)
{
	fprintf(stderr, "minishell: %s: command not found\n", cmd);
}
