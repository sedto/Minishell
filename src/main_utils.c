/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main_utils.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/20 16:41:33 by dibsejra          #+#    #+#             */
/*   Updated: 2025/08/15 17:38:00 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

void	shell_exit(int val, t_minishell *s)
{
	cleanup_shell(s);
	exit(val);
}

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
	t_cmd	*original_commands;

	(void)envp;
	shell->commands = parse_tokens(input, shell, ctx);
	if (!shell->commands)
	{
		if (ctx->syntax_error == 2)
			return (1);
		if (ctx->syntax_error)
			return (2);
		return (1);
	}
	original_commands = shell->commands;
	execute_commands(&shell);
	shell->commands = original_commands;
	if (shell->commands)
	{
		free_commands(shell->commands);
		shell->commands = NULL;
	}
	return (shell->exit_status);
}

int	process_multiline_input(char *input, char **envp, t_shell_ctx *ctx,
		t_minishell *shell)
{
	int		exit_code;
	int		i;

	shell->parsed = ft_split(input, '\n');
	if (!shell->parsed)
		return (1);
	exit_code = 0;
	i = 0;
	while (shell->parsed[i])
	{
		exit_code = process_input(shell->parsed[i], envp, ctx, shell);
		i++;
	}
	return (exit_code);
}
