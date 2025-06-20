/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   quote_remover.c                                    :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/20 01:56:55 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/20 03:30:14 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

/* Vérifie si une chaîne a des quotes externes (début et fin identiques) */
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

/* Supprime les quotes externes d'une chaîne si elles existent */
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

/* Traite tous les arguments d'une commande pour supprimer les quotes */
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

/* Traite un nom de fichier pour supprimer les quotes externes */
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

/* Supprime les quotes de toutes les commandes dans la liste chaînée */
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
