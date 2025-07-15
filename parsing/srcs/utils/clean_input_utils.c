/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   clean_input_utils.c                                :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/11 16:50:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/20 05:06:02 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

static int	should_add_space_before(char *cleaned, int j)
{
	return (j > 0 && cleaned[j - 1] != ' ' && cleaned[j - 1] != '\t');
}

static int	should_add_space_after(char next_char)
{
	return (next_char && next_char != ' ' && next_char != '\t'
		&& next_char != '\0' && next_char != '|' && next_char != '<'
		&& next_char != '>' && next_char != '"' && next_char != '\'');
}

void	add_space_if_needed(char *cleaned, int *j, char next_char, int closing)
{
	if (closing && should_add_space_after(next_char))
		cleaned[(*j)++] = ' ';
	else if (!closing && should_add_space_before(cleaned, *j))
		cleaned[(*j)++] = ' ';
}

int	handle_single_quote(t_clean_data *data)
{
	if (!(*data->in_double_quote))
	{
		if (!(*data->in_single_quote))
			add_space_if_needed(data->cleaned, data->j,
				data->str[*data->i + 1], 0);
		*data->in_single_quote = !(*data->in_single_quote);
		data->cleaned[(*data->j)++] = data->str[(*data->i)++];
		if (!(*data->in_single_quote))
			add_space_if_needed(data->cleaned, data->j,
				data->str[*data->i], 1);
		return (1);
	}
	return (0);
}

int	handle_double_quote(t_clean_data *data)
{
	if (!(*data->in_single_quote))
	{
		if (!(*data->in_double_quote))
			add_space_if_needed(data->cleaned, data->j,
				data->str[*data->i + 1], 0);
		*data->in_double_quote = !(*data->in_double_quote);
		data->cleaned[(*data->j)++] = data->str[(*data->i)++];
		if (!(*data->in_double_quote))
			add_space_if_needed(data->cleaned, data->j,
				data->str[*data->i], 1);
		return (1);
	}
	return (0);
}
