/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   clean_input.c                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/05/26 22:23:37 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/11 16:52:35 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

// Gère les guillemets simples et doubles dans la chaîne
static int	handle_quotes(t_clean_data *data)
{
	if (data->str[*data->i] == '\'')
		return (handle_single_quote(data));
	else if (data->str[*data->i] == '"')
		return (handle_double_quote(data));
	return (0);
}

// Gère les espaces et tabulations dans la chaîne
static void	handle_spaces(t_clean_data *data)
{
	if ((data->str[*data->i] == ' ' || data->str[*data->i] == '\t')
		&& !(*data->in_squote) && !(*data->in_dquote))
	{
		data->cleaned[(*data->j)++] = ' ';
		while (data->str[*data->i] && (data->str[*data->i] == ' '
				|| data->str[*data->i] == '\t'))
			(*data->i)++;
	}
	else
		data->cleaned[(*data->j)++] = data->str[(*data->i)++];
}

// Nettoie et formate une chaîne d'entrée en gérant les espaces et guillemets
char	*clean_input(char *str)
{
	t_clean_data	data;
	int				i;
	int				j;

	if (!str)
		return (NULL);
	data.cleaned = malloc(ft_strlen(str) * 2 + 1);
	if (!data.cleaned)
		return (NULL);
	i = 0;
	j = 0;
	data = (t_clean_data){str, data.cleaned, &i, &j, &(int){0}, &(int){0}};
	while (str[i] && (str[i] == ' ' || str[i] == '\t'))
		i++;
	while (str[i])
	{
		if (!handle_quotes(&data))
			handle_spaces(&data);
	}
	if (j > 0 && data.cleaned[j - 1] == ' ')
		j--;
	data.cleaned[j] = '\0';
	return (data.cleaned);
}
