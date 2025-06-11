/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   expand_strings.c                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/11 16:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/11 16:01:42 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

static int	process_variable(char *input, t_expand_data *data)
{
	char	*var_name;
	char	*var_value;
	int		var_len;

	(*data->i)++;
	var_len = extract_var_name(input, *data->i, &var_name);
	if (var_len > 0)
	{
		var_value = expand_single_var(var_name, data->envp, data->exit_code);
		copy_var_value_to_result(data->result, data->j, var_value);
		*data->i += var_len;
		free(var_value);
		free(var_name);
		return (1);
	}
	data->result[(*data->j)++] = '$';
	if (var_len == 0 && input[*data->i])
		data->result[(*data->j)++] = input[(*data->i)++];
	free(var_name);
	return (0);
}

static int	should_process_variable(char *input, int i)
{
	return (input[i] == '$' && input[i + 1] && input[i + 1] != ' ');
}

static void	process_normal_char(char *input, t_expand_data *data)
{
	data->result[(*data->j)++] = input[(*data->i)++];
}

char	*expand_string(char *input, char **envp, int exit_code)
{
	t_expand_data	data;
	int				i;
	int				j;

	data.result = allocate_result_buffer(input);
	if (!data.result)
		return (NULL);
	i = 0;
	j = 0;
	data.envp = envp;
	data.exit_code = exit_code;
	data.i = &i;
	data.j = &j;
	while (input[i])
	{
		if (should_process_variable(input, i))
			process_variable(input, &data);
		else
			process_normal_char(input, &data);
	}
	data.result[j] = '\0';
	return (data.result);
}

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
