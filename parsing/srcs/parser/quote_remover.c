/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   quote_remover.c                                    :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/20 01:56:55 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/20 02:18:08 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

static int	has_outer_quotes(char *str, char quote_char)
{
	int	len;

	if (!str)
		return (0);
	len = ft_strlen(str);
	if (len < 2)
		return (0);
	return (str[0] == quote_char && str[len - 1] == quote_char);
}

static char	*remove_outer_quotes(char *str)
{
	char	*result;
	int		len;

	if (!str)
		return (NULL);
	if (has_outer_quotes(str, '"') || has_outer_quotes(str, '\''))
	{
		len = ft_strlen(str);
		result = ft_substr(str, 1, len - 2);
		return (result);
	}
	return (ft_strdup(str));
}

static void	process_args_quotes(char **args)
{
	char	*new_arg;
	int		i;

	if (!args)
		return ;
	i = 0;
	while (args[i])
	{
		new_arg = remove_outer_quotes(args[i]);
		if (new_arg)
		{
			free(args[i]);
			args[i] = new_arg;
		}
		i++;
	}
}

static void	process_file_quotes(char **filename)
{
	char	*new_filename;

	if (!filename || !*filename)
		return ;
	new_filename = remove_outer_quotes(*filename);
	if (new_filename)
	{
		free(*filename);
		*filename = new_filename;
	}
}

void	remove_quotes_from_commands(t_cmd *commands)
{
	t_cmd	*current;

	current = commands;
	while (current)
	{
		if (current->args)
			process_args_quotes(current->args);
		if (current->input_file)
			process_file_quotes(&current->input_file);
		if (current->output_file)
			process_file_quotes(&current->output_file);
		current = current->next;
	}
}
