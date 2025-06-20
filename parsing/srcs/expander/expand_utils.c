/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   expand_utils.c                                     :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/11 15:59:13 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/20 21:29:21 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

/* Extrait les variables spéciales ($?, $$) */
static int	extract_special_var(char *str, int start, char **var_name)
{
	if (str[start] == '?')
	{
		*var_name = ft_strdup("?");
		if (*var_name)
			return (1);
		return (0);
	}
	if (str[start] == '$')
	{
		*var_name = ft_strdup("$");
		if (*var_name)
			return (1);
		return (0);
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
	if (*var_name)
		return (i - start);
	return (0);
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
