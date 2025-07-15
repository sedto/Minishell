/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   parse_main.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/07/14 00:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/14 00:00:00 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

static int	process_token(t_token **tokens, t_parse_data *data)
{
	if ((*tokens)->type == TOKEN_WORD || (*tokens)->type == TOKEN_PIPE)
		return (handle_token_type(tokens, data->commands,
				data->current_cmd, data->ctx));
	else if ((*tokens)->type >= TOKEN_REDIR_IN
		&& (*tokens)->type <= TOKEN_HEREDOC)
		return (handle_redirection_type(tokens, *data->current_cmd,
				data->ctx, data->s));
	*tokens = (*tokens)->next;
	return (1);
}

static void	cleanup_on_error(t_cmd *commands, t_cmd *current_cmd)
{
	free_commands(commands);
	if (current_cmd && !is_command_in_list(commands, current_cmd))
		free_commands(current_cmd);
}

static t_cmd	*finalize_commands(t_cmd *commands, t_cmd *current_cmd)
{
	if (current_cmd)
	{
		if (!is_empty_command(current_cmd))
			add_command_to_list(&commands, current_cmd);
		else
			free_commands(current_cmd);
	}
	return (commands);
}

static int	process_main_loop(t_token *tokens, t_parse_data *data,
		t_cmd *commands, t_cmd *current_cmd)
{
	while (tokens && tokens->type != TOKEN_EOF)
	{
		if (!validate_token_syntax(tokens, commands, current_cmd, data->ctx))
		{
			cleanup_on_error(commands, current_cmd);
			return (0);
		}
		if (!process_token(&tokens, data))
		{
			cleanup_on_error(commands, current_cmd);
			return (0);
		}
	}
	return (1);
}

t_cmd	*parse_tokens_to_commands(t_token *tokens, t_shell_ctx *ctx,
		t_minishell *s)
{
	t_cmd			*commands;
	t_cmd			*current_cmd;
	t_parse_data	data;

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
	if (!process_main_loop(tokens, &data, commands, current_cmd))
		return (NULL);
	return (finalize_commands(commands, current_cmd));
}
