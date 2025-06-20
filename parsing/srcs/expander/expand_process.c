/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   expand_process.c                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/20 12:30:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/20 17:05:43 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

/* Traite une variable valide trouvée */
int	handle_valid_variable(char *var_name, t_expand_data *data, int var_len)
{
	char	*var_value;

	var_value = expand_single_var(var_name, data->envp, data->exit_code);
	if (!var_value)
	{
		free(var_name);
		/* En cas d'échec d'allocation, on met juste le $ */
		data->result[(*data->j)++] = '$';
		return (0);
	}
	copy_var_value_to_result(data->result, data->j, var_value);
	*data->i += var_len;
	free(var_value);
	free(var_name);
	return (1);
}

/* Traite le cas où aucune variable valide n'est trouvée */
void	handle_invalid_variable(t_expand_data *data, char *var_name, int var_len)
{
	data->result[(*data->j)++] = '$';
	/* Note: dans process_variable, on a déjà fait (*data->i)++ pour passer le $
	   Donc *data->i pointe sur le caractère APRÈS le $ */
	if (var_len > 0)
	{
		/* Variable invalide de longueur var_len, on avance de cette longueur */
		*data->i += var_len;
	}
	if (var_name)
		free(var_name);
}

/* Traite une variable $VAR et la remplace par sa valeur */
int	process_variable(char *input, t_expand_data *data)
{
	char	*var_name;
	int		var_len;

	(*data->i)++;
	var_len = extract_var_name(input, *data->i, &var_name);
	if (var_len > 0)
		return (handle_valid_variable(var_name, data, var_len));
	handle_invalid_variable(data, var_name, var_len);
	return (0);
}

/* Gère le traitement d'une variable dans l'expansion */
void	handle_variable_processing(char *input, t_expand_data *data)
{
	process_variable(input, data);
}

/* Compte le nombre de variables ($) dans une chaîne */
int	count_variables_in_string(char *str)
{
	int	count;
	int	i;

	count = 0;
	i = 0;
	while (str[i])
	{
		if (str[i] == '$' && str[i + 1] && str[i + 1] != ' ')
			count++;
		i++;
	}
	return (count);
}
