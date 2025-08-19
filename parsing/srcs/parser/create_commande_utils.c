/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   create_commande_utils.c                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/08/12 00:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/08/12 00:00:00 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

void	free_commands(t_cmd *commands)
{
	t_cmd	*current;
	t_cmd	*next;
	int		i;

	current = commands;
	while (current)
	{
		next = current->next;
		if (current->args)
		{
			i = 0;
			while (current->args[i])
			{
				free(current->args[i]);
				i++;
			}
			free(current->args);
		}
		free_files(current->files);
		free(current);
		current = next;
	}
}

void	handle_redirect_out(t_cmd *current_cmd, t_token **token,
			t_shell_ctx *ctx)
{
	process_redirect_token(current_cmd, token, ctx, OUTPUT);
}

void	handle_redirect_append(t_cmd *current_cmd, t_token **token,
			t_shell_ctx *ctx)
{
	process_redirect_token(current_cmd, token, ctx, APPEND);
}

void	handle_redirect_in(t_cmd *current_cmd, t_token **token,
			t_shell_ctx *ctx)
{
	process_redirect_token(current_cmd, token, ctx, INPUT);
}
