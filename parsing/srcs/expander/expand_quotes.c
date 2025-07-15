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

static size_t	calculate_expansion_size(char *input)
{
	size_t	input_len;
	int		var_count;
	size_t	expansion;

	if (!input)
		return (1048576);
	input_len = ft_strlen(input);
	var_count = count_variables_in_string(input);
	if (var_count > 1000)
		var_count = 1000;
	expansion = input_len + (size_t)var_count * 1024;
	if (expansion < input_len * 2)
		expansion = input_len * 2;
	if (expansion > 1048576)
		expansion = 1048576;
	return (expansion);
}

void	init_expand_data(t_expand_data *data, char *input, char **envp,
		int exit_code)
{
	size_t	expansion_size;
	
	if (!input)
	{
		data->result = NULL;
		data->result_size = 0;
		return ;
	}
	expansion_size = calculate_expansion_size(input);
	data->result = malloc(expansion_size + 1);
	if (!data->result)
	{
		data->result_size = 0;
		return ;
	}
	data->result_size = (int)expansion_size;
	data->envp = envp;
	data->exit_code = exit_code;
}
