/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   parse_commands_utils.c                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/08/12 00:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/08/12 00:00:00 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

static int	is_command_in_list(t_cmd *commands, t_cmd *target)
{
	t_cmd	*current;

	if (!commands || !target)
		return (0);
	current = commands;
	while (current)
	{
		if (current == target)
			return (1);
		current = current->next;
	}
	return (0);
}

t_cmd	*handle_syntax_error(t_cmd *commands, t_cmd *current_cmd)
{
	free_commands(commands);
	if (current_cmd && !is_command_in_list(commands, current_cmd))
		free_commands(current_cmd);
	return (NULL);
}

int	process_single_token(t_token **tokens, t_process_data *data)
{
	if (!validate_token_syntax(*tokens, *(data->commands),
			*(data->current_cmd), data->ctx))
		return (0);
	return (process_token(tokens, data));
}

static int	validate_token_syntax(t_token *tokens, t_cmd *commands,
		t_cmd *current_cmd, t_shell_ctx *ctx)
{
	if (tokens->type == TOKEN_PIPE)
		return (validate_pipe_token(tokens, commands, current_cmd, ctx));
	if (tokens->type >= TOKEN_REDIR_IN && tokens->type <= TOKEN_HEREDOC)
		return (validate_redirection_token(tokens, commands, current_cmd, ctx));
	return (validate_double_pipe(tokens, commands, current_cmd, ctx));
}

int	process_token(t_token **tokens, t_process_data *data)
{
	if ((*tokens)->type == TOKEN_WORD)
		handle_word_token(*(data->current_cmd), (*tokens), data->ctx);
	else if ((*tokens)->type == TOKEN_PIPE)
	{
		handle_pipe_token(data->commands, data->current_cmd, data->ctx);
	}
	else if ((*tokens)->type >= TOKEN_REDIR_IN
		&& (*tokens)->type <= TOKEN_HEREDOC)
	{
		process_redirection_token(*(data->current_cmd), tokens,
			data->ctx, data->s);
	}
	*tokens = (*tokens)->next;
	return (1);
}
