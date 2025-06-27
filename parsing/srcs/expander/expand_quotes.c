/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   expand_quotes.c                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/20 12:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/20 12:00:40 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

/* Initialise la structure de données pour l'expansion */
void	init_expand_data(t_expand_data *data, char *input, char **envp,
			int exit_code)
{
	size_t	input_len;
	int		var_count;
	size_t	expansion;

	data->result = allocate_result_buffer(input);
	if (!data->result)  /* Vérification ajoutée */
	{
		data->result_size = 0;
		return ;
	}
	
	if (input)
	{
		input_len = ft_strlen(input);
		var_count = count_variables_in_string(input);
		if (var_count > 1000)
			var_count = 1000;
		expansion = input_len + (size_t)var_count * 1024;
		if (expansion < input_len * 2)
			expansion = input_len * 2;
		if (expansion > 1048576)
			expansion = 1048576;
		data->result_size = (int)expansion;
	}
	else
		data->result_size = 1048576;
	data->envp = envp;
	data->exit_code = exit_code;
}

/* Traite un caractère de quote simple */
void	handle_single_quote_char(char *input, t_expand_data *data,
			int *in_single_quote, int in_double_quote)
{
	(void)in_double_quote;
	*in_single_quote = !(*in_single_quote);
	if (*data->j < data->result_size - 1)
		data->result[(*data->j)++] = input[(*data->i)++];
	else
		(*data->i)++;
}

/* Traite un caractère de quote double */
void	handle_double_quote_char(char *input, t_expand_data *data,
			int *in_double_quote, int in_single_quote)
{
	(void)in_single_quote;
	*in_double_quote = !(*in_double_quote);
	if (*data->j < data->result_size - 1)
		data->result[(*data->j)++] = input[(*data->i)++];
	else
		(*data->i)++;
}

/* Détermine si un caractère '$' doit déclencher l'expansion */
int	should_process_variable(char *input, int i)
{
	return (input[i] == '$' && input[i + 1] && input[i + 1] != ' ');
}

/* Copie un caractère normal vers le résultat */
void	process_normal_char(char *input, t_expand_data *data)
{
	if (*data->j < data->result_size - 1)
		data->result[(*data->j)++] = input[(*data->i)++];
	else
		(*data->i)++;
}
