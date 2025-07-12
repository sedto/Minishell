/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   expand_buffer.c                                    :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/20 20:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/21 02:42:13 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"
#include <stdint.h>

/* Calcule la taille d'expansion pour l'allocation */
static size_t	calculate_expansion_size(size_t input_len, int var_count)
{
	size_t	max_expansion;
	size_t	var_expansion;

	if (var_count > 1000)
		var_count = 1000;
	var_expansion = (size_t)var_count * 1024;
	if (var_expansion > SIZE_MAX - input_len)
		max_expansion = SIZE_MAX;
	else
		max_expansion = input_len + var_expansion;
	if (max_expansion < input_len * 2)
		max_expansion = input_len * 2;
	if (max_expansion > 1048576)
		max_expansion = 1048576;
	return (max_expansion);
}

/* Alloue un buffer pour le résultat avec une taille estimée */
char	*allocate_result_buffer(char *input)
{
	char	*result;
	size_t	max_expansion;
	size_t	input_len;
	int		var_count;

	if (!input)
		return (NULL);
	input_len = ft_strlen(input);
	var_count = count_variables_in_string(input);
	max_expansion = calculate_expansion_size(input_len, var_count);
	result = malloc(max_expansion + 1);
	if (!result)
		return (NULL);
	return (result);
}

/* Copie la valeur d'une variable dans le buffer résultat avec protection */
void	copy_var_value_to_result(char *result, int *j, char *var_value,
			int max_size)
{
	int	i;
	int	value_len;

	if (!var_value || !result || !j || max_size <= 0)
		return ;
	if (*j >= max_size - 1)
		return ;
	value_len = ft_strlen(var_value);
	i = 0;
	while (var_value[i] && i < value_len && (*j + i) < max_size - 1)
	{
		result[*j + i] = var_value[i];
		i++;
	}
	*j += i;
}
