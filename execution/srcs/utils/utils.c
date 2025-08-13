/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   utils.c                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/21 10:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/08/13 17:03:32 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

void	print_tbl(char **tbl)
{
	int	i;

	i = 0;
	while (tbl[i])
	{
		printf("%s\n", tbl[i]);
		i++;
	}
}

void	print_ll(t_file *ll)
{
	t_file	*tmp;

	tmp = ll;
	while (tmp)
	{
		printf("%s\n", tmp->name);
		tmp = tmp->next;
	}
}

static int	count_env_vars(t_env *env)
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

static int	fill_env_array(char **envp, t_env *env, int count)
{
	char	*temp;
	int		i;

	i = 0;
	while (env && i < count)
	{
		temp = ft_strjoin(env->key, "=");
		if (temp)
		{
			envp[i] = ft_strjoin(temp, env->value);
			free(temp);
		}
		if (!envp[i])
			return (i);
		env = env->next;
		i++;
	}
	return (-1);
}

char	**env_to_array(t_env *env)
{
	char	**envp;
	int		count;
	int		failed_at;

	count = count_env_vars(env);
	envp = malloc(sizeof(char *) * (count + 1));
	if (!envp)
		return (NULL);
	failed_at = fill_env_array(envp, env, count);
	if (failed_at >= 0)
	{
		while (--failed_at >= 0)
			free(envp[failed_at]);
		free(envp);
		return (NULL);
	}
	envp[count] = NULL;
	return (envp);
}
