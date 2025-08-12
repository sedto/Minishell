/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   create_commande_helpers.c                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/08/12 00:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/08/12 00:00:00 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

char	**create_new_args_array(int count, char *arg_copy)
{
	char	**new_args;

	new_args = malloc((count + 2) * sizeof(char *));
	if (!new_args)
	{
		free(arg_copy);
		return (NULL);
	}
	return (new_args);
}

void	copy_existing_args(char **new_args, char **old_args, int count)
{
	int	i;

	i = 0;
	while (i < count)
	{
		new_args[i] = old_args[i];
		i++;
	}
}

void	free_files(t_file *files)
{
	t_file	*current;
	t_file	*next;

	current = files;
	while (current)
	{
		next = current->next;
		if (current->name)
			free(current->name);
		if (current->heredoc_content)
			free(current->heredoc_content);
		free(current);
		current = next;
	}
}
