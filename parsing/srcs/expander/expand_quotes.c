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

/*
** Initializes data structure for expansion
*/
void	init_expand_data(t_expand_data *data, char *input, char **envp,
			int exit_code)
{
	data->result = allocate_result_buffer(input);
	if (!data->result)
	{
		data->result_size = 0;
		return ;
	}
	data->result_size = calc_buffer_size(input);
	data->envp = envp;
	data->exit_code = exit_code;
}

/*
** Processes single quote character
*/
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

/*
** Processes double quote character
*/
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

/*
** Copies normal character to result
*/
void	process_normal_char(char *input, t_expand_data *data)
{
	if (*data->j < data->result_size - 1)
		data->result[(*data->j)++] = input[(*data->i)++];
	else
		(*data->i)++;
}
