/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   expand_utils_extra.c                               :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/07/28 00:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/28 22:46:18 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

/*
** Determines if '$' character should trigger expansion
*/
int	should_process_variable(char *input, int i)
{
	return (input[i] == '$' && input[i + 1] && input[i + 1] != ' ');
}

/*
** Calculates buffer size for variable expansion
*/
int	calc_buffer_size(char *input)
{
	size_t	input_len;
	int		var_count;
	size_t	expansion;

	if (!input)
		return (1048576);
	input_len = ft_strlen(input);
	var_count = count_variables_in_string(input);
	if (var_count > 100)
		var_count = 100;
	expansion = input_len + (size_t)var_count * 256;
	if (expansion < input_len * 4)
		expansion = input_len * 4;
	if (expansion > 1048576)
		expansion = 1048576;
	return ((int)expansion);
}
