/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   create_commande.c                                  :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/20 01:57:16 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/10 11:04:33 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

t_cmd	*new_command(void)
{
	t_cmd	*cmd;

	cmd = malloc(sizeof(t_cmd));
	if (!cmd)
		return (NULL);
	cmd->args = NULL;
	cmd->files = NULL;
	cmd->next = NULL;
	return (cmd);
}

void	add_argument(t_cmd *cmd, char *arg)
{
	char	**new_args;
	char	*arg_copy;
	int		count;

	if (!cmd || !arg)
		return ;
	count = count_args(cmd->args);
	arg_copy = ft_strdup(arg);
	if (!arg_copy)
		return ;
	new_args = create_new_args_array(count, arg_copy);
	if (!new_args)
		return ;
	copy_existing_args(new_args, cmd->args, count);
	new_args[count] = arg_copy;
	new_args[count + 1] = NULL;
	free(cmd->args);
	cmd->args = new_args;
}

int	count_args(char **args)
{
	int	count;

	count = 0;
	if (!args)
		return (0);
	while (args[count])
		count++;
	return (count);
}

void	add_command_to_list(t_cmd **commands, t_cmd *new_cmd)
{
	t_cmd	*current;

	if (!commands || !new_cmd)
		return ;
	if (!*commands)
	{
		*commands = new_cmd;
		return ;
	}
	current = *commands;
	while (current->next)
		current = current->next;
	current->next = new_cmd;
}
