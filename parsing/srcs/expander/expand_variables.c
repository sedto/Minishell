/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   expand_variables.c                                 :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/11 15:56:09 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/07 17:23:40 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

char	*find_var_in_env(char *var_name, char **envp)
{
	int	i;
	int	name_len;

	if (!var_name || !envp)
		return (NULL);
	i = 0;
	name_len = ft_strlen(var_name);
	while (envp[i])
	{
		if (ft_strncmp(envp[i], var_name, name_len) == 0
			&& envp[i][name_len] == '=')
			return (envp[i] + name_len + 1);
		i++;
	}
	return (NULL);
}

char	*handle_special_var(char *var_name, int exit_code)
{
	if (ft_strncmp(var_name, "?", 1) == 0 && ft_strlen(var_name) == 1)
		return (ft_itoa(exit_code));
	if (ft_strncmp(var_name, "$", 1) == 0 && ft_strlen(var_name) == 1)
		return (ft_itoa(getpid()));
	if (ft_strncmp(var_name, "0", 1) == 0 && ft_strlen(var_name) == 1)
		return (ft_strdup("minishell"));
	return (NULL);
}

char	*get_variable_value(char *var_name, char **envp, int exit_code)
{
	char	*special_value;
	char	*env_value;

	if (!var_name)
		return (ft_strdup(""));
	special_value = handle_special_var(var_name, exit_code);
	if (special_value)
		return (special_value);
	env_value = find_var_in_env(var_name, envp);
	if (env_value)
		return (ft_strdup(env_value));
	return (ft_strdup(""));
}

char	*expand_single_var(char *var_name, char **envp, int exit_code)
{
	return (get_variable_value(var_name, envp, exit_code));
}
