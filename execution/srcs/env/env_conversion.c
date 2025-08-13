/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   env_conversion.c                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: user <user@student.42.fr>                  +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by user              #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by user             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../libft/libft.h"
#include "minishell.h"

static int	count_env_entries(t_env *env)
{
	int	count;

	count = 0;
	while (env)
	{
		count++;
		env = env->next;
	}
	return (count);
}

static int	fill_env_tab(char **tab, t_env *env)
{
	char	*entry;
	int		i;

	i = 0;
	while (env)
	{
		entry = ft_strjoin(env->key, "=");
		if (!entry)
			return (i);
		tab[i] = ft_strjoin(entry, env->value);
		free(entry);
		if (!tab[i])
			return (i);
		env = env->next;
		i++;
	}
	return (-1);
}

char	**env_to_tab(t_env *env)
{
	char	**tab;
	int		count;
	int		failed_at;

	count = count_env_entries(env);
	tab = malloc(sizeof(char *) * (count + 1));
	if (!tab)
		return (NULL);
	failed_at = fill_env_tab(tab, env);
	if (failed_at >= 0)
	{
		free_env_tab(tab);
		return (NULL);
	}
	tab[count] = NULL;
	return (tab);
}

void	free_env_tab(char **tab)
{
	int	i;

	if (!tab)
		return ;
	i = 0;
	while (tab[i])
	{
		free(tab[i]);
		i++;
	}
	free(tab);
}
