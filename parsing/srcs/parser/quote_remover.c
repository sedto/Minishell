/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   quote_remover.c                                    :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/20 01:56:55 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/12 21:11:16 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

static void	init_quote_removal(int *i, int *j, int *in_single, int *in_double)
{
	*i = 0;
	*j = 0;
	*in_single = 0;
	*in_double = 0;
}

char	*remove_quotes(char *str)
{
	char	*result;
	int		i;
	int		j;
	int		in_single_quote;
	int		in_double_quote;

	if (!str)
		return (NULL);
	result = malloc(ft_strlen(str) + 1);
	if (!result)
		return (NULL);
	init_quote_removal(&i, &j, &in_single_quote, &in_double_quote);
	while (str[i])
	{
		if (str[i] == '\'' && !in_double_quote)
			in_single_quote = !in_single_quote;
		else if (str[i] == '"' && !in_single_quote)
			in_double_quote = !in_double_quote;
		else
			result[j++] = str[i];
		i++;
	}
	result[j] = '\0';
	return (result);
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
		new_arg = remove_quotes(args[i]);
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
	new_filename = remove_quotes(*filename);
	if (new_filename)
	{
		free(*filename);
		*filename = new_filename;
	}
}

void	remove_quotes_from_commands(t_cmd *commands)
{
	t_cmd	*current;
	t_file	*tmp;

	current = commands;
	while (current)
	{
		if (current->args)
			process_args_quotes(current->args);
		tmp = current->files;
		while (tmp)
		{
			process_file_quotes(&tmp->name);
			tmp = tmp->next;
		}
		current = current->next;
	}
}
