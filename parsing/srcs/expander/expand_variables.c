/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   expand_variables.c                                 :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/11 15:56:09 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/11 16:08:18 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

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
	if (ft_strncmp(var_name, "?", 2) == 0)
		return (ft_itoa(exit_code));
	if (ft_strncmp(var_name, "$", 2) == 0)
		return (ft_itoa(getpid()));
	if (ft_strncmp(var_name, "0", 2) == 0)
		return (ft_strdup("minishell"));
	return (NULL);
}

char	*expand_single_var(char *var_name, char **envp, int exit_code)
{
	char	*special_value;
	char	*env_value;

	special_value = handle_special_var(var_name, exit_code);
	if (special_value)
		return (special_value);
	env_value = find_var_in_env(var_name, envp);
	if (env_value)
		return (ft_strdup(env_value));
	return (ft_strdup(""));
}

int	should_expand_token(char *value)
{
	if (value && value[0] == '\'' && value[ft_strlen(value) - 1] == '\'')
		return (0);
	return (1);
}

t_token	*expand_all_tokens(t_token *tokens, char **envp, int exit_code)
{
	t_token	*current;
	char	*expanded_value;

	current = tokens;
	while (current)
	{
		if (current->type == TOKEN_WORD && current->value)
		{
			if (should_expand_token(current->value))
			{
				expanded_value = expand_string(current->value, envp, exit_code);
				if (expanded_value)
				{
					free(current->value);
					current->value = expanded_value;
				}
			}
		}
		current = current->next;
	}
	return (tokens);
}
