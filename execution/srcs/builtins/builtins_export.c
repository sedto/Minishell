/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   builtins_export.c                                  :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/08/18 14:20:52 by dibsejra          #+#    #+#             */
/*   Updated: 2025/08/18 14:24:28 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../libft/libft.h"
#include "minishell.h"

static void	print_export_env(t_env *env)
{
	while (env)
	{
		printf("declare -x %s=\"%s\"\n", env->key, env->value);
		env = env->next;
	}
}

static void	process_export_arg(t_minishell **s, char *arg)
{
	char	*equal_pos;
	char	*key;
	char	*value;

	if (export_with_error(arg))
	{
		(*s)->exit_status = 1;
		return ;
	}
	equal_pos = ft_strchr(arg, '=');
	if (equal_pos)
	{
		key = ft_substr(arg, 0, equal_pos - arg);
		value = ft_strdup(equal_pos + 1);
		if (key && value)
			set_env_value(s, key, value);
		free(key);
		free(value);
	}
}

/* Builtin: export - exporte des variables */
int	builtin_export(t_minishell **s)
{
	int	i;

	if (!(*s)->commands->args[1])
	{
		print_export_env((*s)->env);
		return (0);
	}
	(*s)->exit_status = 0;
	i = 1;
	while ((*s)->commands->args[i])
	{
		process_export_arg(s, (*s)->commands->args[i]);
		i++;
	}
	return ((*s)->exit_status);
}

/* Builtin: unset - supprime des variables */
int	builtin_unset(t_minishell **s)
{
	int		i;
	char	**args;

	args = (*s)->commands->args;
	if (!args[1])
		return (0);
	i = 1;
	while (args[i])
	{
		unset_env_value(s, args[i]);
		i++;
	}
	return (0);
}
