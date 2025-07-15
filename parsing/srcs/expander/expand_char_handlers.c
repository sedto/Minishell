/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   expand_char_handlers.c                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/07/14 00:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/14 00:00:00 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

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

int	should_process_variable(char *input, int i)
{
	return (input[i] == '$' && input[i + 1] && input[i + 1] != ' ');
}

void	process_normal_char(char *input, t_expand_data *data)
{
	if (*data->j < data->result_size - 1)
		data->result[(*data->j)++] = input[(*data->i)++];
	else
		(*data->i)++;
}
