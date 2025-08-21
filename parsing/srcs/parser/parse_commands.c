/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   parse_commands.c                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/20 01:57:09 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/12 21:11:16 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

int	is_empty_command(t_cmd *cmd)
{
	if (!cmd)
		return (1);
	if (cmd->args && cmd->args[0])
		return (0);
	if (cmd->files)
		return (0);
	return (1);
}

t_cmd	*parse_tokens_to_commands(t_token *tokens, t_shell_ctx *ctx,
		t_minishell *s)
{
	t_cmd			*commands;
	t_cmd			*current_cmd;
	t_process_data	data;

	if (!validate_initial_syntax(tokens, ctx))
		return (NULL);
	commands = NULL;
	current_cmd = new_command();
	if (!current_cmd)
		return (NULL);
	data.commands = &commands;
	data.current_cmd = &current_cmd;
	data.ctx = ctx;
	data.s = s;
	while (tokens && tokens->type != TOKEN_EOF)
	{
		if (!process_single_token(&tokens, &data))
			return (handle_syntax_error(commands, current_cmd));
	}
	if (current_cmd)
		add_command_to_list(&commands, current_cmd);
	return (commands);
}
