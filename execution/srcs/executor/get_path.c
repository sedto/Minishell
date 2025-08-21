/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   get_path.c                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/08/18 14:23:04 by dibsejra          #+#    #+#             */
/*   Updated: 2025/08/18 14:23:52 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

static char	**extract_paths_from_env(t_env *env)
{
	while (env)
	{
		if (env->key && ft_strncmp(env->key, "PATH", 4) == 0)
		{
			if (env->value)
				return (ft_split(env->value, ':'));
			break ;
		}
		env = env->next;
	}
	return (NULL);
}

static char	*search_path(char **paths, char *cmd)
{
	char	*full;
	int		i;
	int		len1;
	int		len2;

	i = 0;
	len2 = ft_strlen(cmd);
	while (paths && paths[i])
	{
		len1 = ft_strlen(paths[i]);
		full = malloc(len1 + len2 + 2);
		if (!full)
			return (NULL);
		ft_memcpy(full, paths[i], len1);
		full[len1] = '/';
		ft_memcpy(full + len1 + 1, cmd, len2);
		full[len1 + len2 + 1] = '\0';
		if (access(full, X_OK) == 0)
			return (full);
		free(full);
		i++;
	}
	return (NULL);
}

static void	free_tab(char **tab)
{
	int	i;

	i = 0;
	while (tab && tab[i])
	{
		free(tab[i]);
		i++;
	}
	free(tab);
}

char	*get_path(char *cmd, t_env *env)
{
	char	**paths;
	char	*result;

	if (!cmd || ft_strchr(cmd, '/'))
		return (ft_strdup(cmd));
	paths = extract_paths_from_env(env);
	result = search_path(paths, cmd);
	if (paths)
		free_tab(paths);
	return (result);
}
