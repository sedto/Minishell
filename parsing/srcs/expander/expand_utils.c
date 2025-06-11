/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   expand_utils.c                                     :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/11 15:59:13 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/11 16:16:33 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

static int	extract_special_var(char *str, int start, char **var_name)
{
	if (str[start] == '?')
	{
		*var_name = ft_strdup("?");
		return (1);
	}
	if (str[start] == '$')
	{
		*var_name = ft_strdup("$");
		return (1);
	}
	return (0);
}

static int	extract_normal_var(char *str, int start, char **var_name)
{
	int	i;
	int	var_len;

	i = start;
	while (str[i] && (ft_isalnum(str[i]) || str[i] == '_'))
		i++;
	var_len = i - start;
	if (var_len == 0)
		return (0);
	*var_name = ft_substr(str, start, var_len);
	return (var_len);
}

int	extract_var_name(char *str, int start, char **var_name)
{
	int	special_len;
	int	normal_len;

	special_len = extract_special_var(str, start, var_name);
	if (special_len > 0)
		return (special_len);
	normal_len = extract_normal_var(str, start, var_name);
	if (normal_len > 0)
		return (normal_len);
	*var_name = ft_strdup("$");
	return (0);
}

char	*allocate_result_buffer(char *input)
{
	char	*result;
	int		max_expansion;
	int		input_len;

	if (!input)
		return (NULL);
	input_len = ft_strlen(input);
	max_expansion = input_len + (count_variables_in_string(input) * 1024);
	if (max_expansion < input_len * 2)
		max_expansion = input_len * 2;
	result = malloc(max_expansion + 1);
	if (!result)
		return (NULL);
	return (result);
}

void	copy_var_value_to_result(char *result, int *j, char *var_value)
{
	int	i;

	if (!var_value || !result)
		return ;
	i = 0;
	while (var_value[i])
	{
		result[*j + i] = var_value[i];
		i++;
	}
	*j += i;
}
