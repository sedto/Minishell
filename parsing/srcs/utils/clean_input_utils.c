/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   clean_input_utils.c                                :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/11 16:50:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/11 17:27:45 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

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
	if (!(*data->in_dquote))
	{
		if (!(*data->in_squote))
			add_space_if_needed(data->cleaned, data->j,
				data->str[*data->i + 1], 0);
		*data->in_squote = !(*data->in_squote);
		data->cleaned[(*data->j)++] = data->str[(*data->i)++];
		if (!(*data->in_squote))
			add_space_if_needed(data->cleaned, data->j,
				data->str[*data->i], 1);
		return (1);
	}
	return (0);
}

int	handle_double_quote(t_clean_data *data)
{
	if (!(*data->in_squote))
	{
		if (!(*data->in_dquote))
			add_space_if_needed(data->cleaned, data->j,
				data->str[*data->i + 1], 0);
		*data->in_dquote = !(*data->in_dquote);
		data->cleaned[(*data->j)++] = data->str[(*data->i)++];
		if (!(*data->in_dquote))
			add_space_if_needed(data->cleaned, data->j,
				data->str[*data->i], 1);
		return (1);
	}
	return (0);
}
