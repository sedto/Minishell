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

#include "minishell.h"

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

static char	**create_new_args_array(char **args, char *arg_copy, int count)
{
	char	**new_args;
	int		i;

	new_args = malloc((count + 2) * sizeof(char *));
	if (!new_args)
	{
		free(arg_copy);
		return (NULL);
	}
	i = 0;
	while (i < count)
	{
		new_args[i] = ft_strdup(args[i]);
		if (!new_args[i])
		{
			while (--i >= 0)
				free(new_args[i]);
			free(new_args);
			free(arg_copy);
			return (NULL);
		}
		i++;
	}
	new_args[count] = arg_copy;
	new_args[count + 1] = NULL;
	return (new_args);
}

void	add_argument(t_cmd *cmd, char *arg)
{
	char	**new_args;
	char	*arg_copy;
	int		count;

	if (!cmd || !arg)
		return ;
	printf("DEBUG ADD_ARG: [%s]\n", arg);
	count = count_args(cmd->args);
	arg_copy = ft_strdup(arg);
	if (!arg_copy)
		return ;
	printf("DEBUG ARG_COPY: [%s]\n", arg_copy);
	new_args = create_new_args_array(cmd->args, arg_copy, count);
	if (!new_args)
		return ;
	if (cmd->args)
		free(cmd->args);
	cmd->args = new_args;
	printf("DEBUG CMD_ARGS_AFTER: [%s]\n", cmd->args[0]);
}
