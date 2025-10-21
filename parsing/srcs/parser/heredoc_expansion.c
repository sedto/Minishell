/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   heredoc_expansion.c                                :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/08/24 00:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/08/24 15:56:27 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

char	*prepare_heredoc_line(char *line)
{
	char	*temp_line;
	int		i;

	temp_line = ft_strdup(line);
	if (!temp_line)
		return (NULL);
	i = 0;
	while (temp_line[i])
	{
		if (temp_line[i] == '\'')
			temp_line[i] = ' ';
		i++;
	}
	return (temp_line);
}

void	restore_heredoc_quotes(char *original, char *expanded)
{
	int	i;

	i = 0;
	while (expanded[i] && original[i])
	{
		if (original[i] == '\'' && expanded[i] == ' ')
			expanded[i] = '\'';
		i++;
	}
}
