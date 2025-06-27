/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   clean_input.c                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/05/26 22:23:37 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/20 12:43:36 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

/* Gère les quotes simples et doubles */
static int	handle_quotes(t_clean_data *data)
{
	if (data->str[*data->i] == '\'' && !(*data->in_double_quote))
	{
		*data->in_single_quote = !(*data->in_single_quote);
		data->cleaned[(*data->j)++] = data->str[(*data->i)++];
		return (1);
	}
	else if (data->str[*data->i] == '"' && !(*data->in_single_quote))
	{
		*data->in_double_quote = !(*data->in_double_quote);
		data->cleaned[(*data->j)++] = data->str[(*data->i)++];
		return (1);
	}
	return (0);
}

/* Gère les espaces en préservant ceux avant les quotes */
static int	handle_spaces(t_clean_data *data)
{
	int	next_i;

	if ((data->str[*data->i] == ' ' || data->str[*data->i] == '\t')
		&& !(*data->in_single_quote) && !(*data->in_double_quote))
	{
		if (*data->j > 0 && data->cleaned[*data->j - 1] != ' ')
		{
			next_i = *data->i;
			while (data->str[next_i] && (data->str[next_i] == ' '
					|| data->str[next_i] == '\t'))
				next_i++;
			if (data->str[next_i])
				data->cleaned[(*data->j)++] = ' ';
		}
		while (data->str[*data->i] && (data->str[*data->i] == ' '
				|| data->str[*data->i] == '\t'))
			(*data->i)++;
		return (1);
	}
	return (0);
}

/* Traite un caractère dans la chaîne d'entrée en préservant les espaces */
static void	process_char(t_clean_data *data)
{
	if (handle_quotes(data))
		return ;
	if (handle_spaces(data))
		return ;
	data->cleaned[(*data->j)++] = data->str[(*data->i)++];
}

/* Initialise les données pour le nettoyage */
static void	init_clean_data(t_clean_data *data, char *str, char *cleaned,
		int *vars)
{
	data->str = str;
	data->cleaned = cleaned;
	data->i = &vars[0];
	data->j = &vars[1];
	data->in_single_quote = &vars[2];
	data->in_double_quote = &vars[3];
	vars[0] = 0;
	vars[1] = 0;
	vars[2] = 0;
	vars[3] = 0;
}

/* Nettoie l'entrée en normalisant les espaces et préservant quotes */
char	*clean_input(char *str)
{
	char			*cleaned;
	t_clean_data	data;
	int				vars[4];

	if (!str)
		return (NULL);
	cleaned = malloc(ft_strlen(str) * 2 + 1);
	if (!cleaned)
		return (NULL);
	init_clean_data(&data, str, cleaned, vars);
	while (str[*data.i] && (str[*data.i] == ' ' || str[*data.i] == '\t'))
		(*data.i)++;
	while (str[*data.i])
		process_char(&data);
	if (*data.j > 0 && cleaned[*data.j - 1] == ' ')
		(*data.j)--;
	cleaned[*data.j] = '\0';
	return (cleaned);
}
