/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   expand_strings.c                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/11 16:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/24 01:15:47 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

/* Traite un caractère selon son type (quote, variable, normal) */
static void	process_character(char *input, t_expand_data *data,
				int *in_single_quote, int *in_double_quote)
{
	if (input[*data->i] == '\'' && !(*in_double_quote))
		handle_single_quote_char(input, data, in_single_quote,
			*in_double_quote);
	else if (input[*data->i] == '"' && !(*in_single_quote))
		handle_double_quote_char(input, data, in_double_quote,
			*in_single_quote);
	else if (should_process_variable(input, *data->i) && !(*in_single_quote))
		handle_variable_processing(input, data);
	else
		process_normal_char(input, data);
}

/* Initialise les variables pour l'expansion */
static void	init_expansion_vars(int *i, int *j, int *in_single_quote,
				int *in_double_quote)
{
	*i = 0;
	*j = 0;
	*in_single_quote = 0;
	*in_double_quote = 0;
}

/* Traite la boucle principale d'expansion */
static void	process_expansion_loop(char *input, t_expand_data *data,
				int *in_single_quote, int *in_double_quote)
{
	int	prev_i;
	int	safety_counter;

	safety_counter = 0;
	while (input[*data->i] && safety_counter < 10000)
	{
		if (!data->result || *data->j >= data->result_size - 1)
			return ;
		prev_i = *data->i;
		process_character(input, data, in_single_quote, in_double_quote);
		if (*data->i == prev_i)
			(*data->i)++;
		safety_counter++;
	}
}

/* Fonction principale d'expansion avec tracking correct des quotes */
char	*expand_string(char *input, char **envp, int exit_code)
{
	t_expand_data	data;
	int				vars[4];

	if (!input)
		return (NULL);
	init_expand_data(&data, input, envp, exit_code);
	if (!data.result)
		return (NULL);
	init_expansion_vars(&vars[0], &vars[1], &vars[2], &vars[3]);
	data.i = &vars[0];
	data.j = &vars[1];
	process_expansion_loop(input, &data, &vars[2], &vars[3]);
	if (!data.result)
		return (NULL);
	if (*data.j >= 0 && *data.j < data.result_size)
		data.result[*data.j] = '\0';
	else if (data.result_size > 0)
		data.result[data.result_size - 1] = '\0';
	return (data.result);
}
