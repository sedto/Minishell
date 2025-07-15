/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   cmd_cleanup.c                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/07/14 00:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/14 00:00:00 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

static void	free_cmd_args(t_cmd *cmd)
{
	int	i;

	if (cmd->args)
	{
		i = 0;
		while (cmd->args[i])
			free(cmd->args[i++]);
		free(cmd->args);
	}
}

static void	free_cmd_files(t_cmd *cmd)
{
	t_file	*fcurrent;
	t_file	*fnext;

	if (cmd->files)
	{
		fcurrent = cmd->files;
		while (fcurrent)
		{
			fnext = fcurrent->next;
			free(fcurrent->name);
			if (fcurrent->heredoc_content)
				free(fcurrent->heredoc_content);
			free(fcurrent);
			fcurrent = fnext;
		}
	}
}

void	free_commands(t_cmd *commands)
{
	t_cmd	*current;
	t_cmd	*next;

	current = commands;
	while (current)
	{
		next = current->next;
		free_cmd_args(current);
		free_cmd_files(current);
		free(current);
		current = next;
	}
}
