/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   expand_variables.c                                 :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/11 15:56:09 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/20 21:32:33 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

/* Cherche une variable dans l'environnement et retourne sa valeur */
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

/* Gère les variables spéciales ($?, $$, $0) */
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

/* Expanse une variable en cherchant les spéciales puis l'environnement */
char	*expand_single_var(char *var_name, char **envp, int exit_code)
{
	char	*special_value;
	char	*env_value;
	char	*result;

	special_value = handle_special_var(var_name, exit_code);
	if (special_value)
		return (special_value);
	env_value = find_var_in_env(var_name, envp);
	if (env_value)
	{
		result = ft_strdup(env_value);
		if (!result)
			return (NULL);
		return (result);
	}
	result = ft_strdup("");
	if (!result)
		return (NULL);
	return (result);
}

/* Détermine si un token doit être expansé (gère les quotes complexes) */
int	should_expand_token(char *value)
{
	int	len;
	int	i;

	if (!value)
		return (1);
	len = ft_strlen(value);
	if (len < 2)
		return (1);
	if (value[0] == '\'' && value[len - 1] == '\'')
	{
		i = 1;
		while (i < len - 1)
		{
			if (value[i] == '\'')
				return (1);
			i++;
		}
		return (0);
	}
	return (1);
}

/* Expanse toutes les variables dans une liste de tokens */
t_token	*expand_all_tokens(t_token *tokens, char **envp, int exit_code)
{
	t_token	*current;
	char	*expanded_value;
	char	*old_value;

	current = tokens;
	while (current)
	{
		if (current->type == TOKEN_WORD && current->value)
		{
			if (should_expand_token(current->value))
			{
				old_value = current->value;
				expanded_value = expand_string(current->value, envp, exit_code);
				if (expanded_value)
				{
					current->value = expanded_value;
					free(old_value);
				}
			}
		}
		current = current->next;
	}
	return (tokens);
}
