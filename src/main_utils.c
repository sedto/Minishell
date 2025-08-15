/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main_utils.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/20 16:41:33 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/12 21:11:16 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

int	is_exit_command(char *input)
{
	return (ft_strncmp(input, "exit", 4) == 0 && (input[4] == '\0'
			|| input[4] == ' ' || input[4] == '\t'));
}

t_cmd	*parse_tokens(char *input, t_minishell *s, t_shell_ctx *ctx)
{
	char	*cleaned_input;
	t_token	*tokens;

	ctx->syntax_error = 0;
	cleaned_input = clean_input(input);
	if (!cleaned_input)
		return (NULL);
	tokens = tokenize(cleaned_input, ctx);
	if (!tokens)
	{
		free(cleaned_input);
		return (NULL);
	}
	tokens = process_tokens_expansion(tokens, s);
	return (build_commands_from_tokens(tokens, cleaned_input, ctx, s));
}

int	process_input(char *input, char **envp, t_shell_ctx *ctx,
		t_minishell *shell)
{
	(void)envp;
	shell->commands = parse_tokens(input, shell, ctx);
	if (!shell->commands)
	{
		if (ctx->syntax_error)
			return (2);
		return (1);
	}
	if (shell->commands->args && shell->commands->args[0])
		execute_commands(&shell);
	free_commands(shell->commands);
	shell->commands = NULL;
	return (shell->exit_status);
}
