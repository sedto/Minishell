/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   expand_utils.c                                     :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/11 15:59:13 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/20 17:15:42 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

/* Extrait les variables spéciales ($?, $$) */
static int	extract_special_var(char *str, int start, char **var_name)
{
	if (str[start] == '?')
	{
		*var_name = ft_strdup("?");
		return (*var_name ? 1 : 0);
	}
	if (str[start] == '$')
	{
		*var_name = ft_strdup("$");
		return (*var_name ? 1 : 0);
	}
	return (0);
}

/* Extrait les variables normales (lettres, chiffres, underscore) */
static int	extract_normal_var(char *str, int start, char **var_name)
{
	int	i;

	i = start;
	if (!ft_isalpha(str[i]) && str[i] != '_')
		return (0);
	while (str[i] && (ft_isalnum(str[i]) || str[i] == '_'))
		i++;
	*var_name = ft_substr(str, start, i - start);
	return (*var_name ? i - start : 0);
}


/* Extrait le nom d'une variable en gérant spéciales et normales */
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
	*var_name = NULL;
	return (0);
}

/* Alloue un buffer pour le résultat avec une taille estimée */
char	*allocate_result_buffer(char *input)
{
	char	*result;
	size_t	max_expansion;
	size_t	input_len;
	int		var_count;
	size_t	var_expansion;

	if (!input)
		return (NULL);
	input_len = ft_strlen(input);
	var_count = count_variables_in_string(input);
	if (var_count > 1000)
		var_count = 1000;
	/* Protection contre overflow */
	var_expansion = (size_t)var_count * 1024;
	if (var_expansion > SIZE_MAX - input_len)
		max_expansion = SIZE_MAX;
	else
		max_expansion = input_len + var_expansion;
	if (max_expansion < input_len * 2)
		max_expansion = input_len * 2;
	/* Protection finale contre les tailles excessives */
	if (max_expansion > 1048576)  /* 1MB max */
		max_expansion = 1048576;
	result = malloc(max_expansion + 1);
	if (!result)
		return (NULL);
	return (result);
}

/* Copie la valeur d'une variable dans le buffer résultat avec protection */
void	copy_var_value_to_result(char *result, int *j, char *var_value)
{
	int	i;
	int	value_len;
	int	max_buffer;

	if (!var_value || !result || !j)
		return ;
	value_len = ft_strlen(var_value);
	max_buffer = 1048576;  /* Limite buffer 1MB */
	
	i = 0;
	while (var_value[i] && i < value_len && (*j + i) < max_buffer - 1)
	{
		result[*j + i] = var_value[i];
		i++;
	}
	*j += i;
}
