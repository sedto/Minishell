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
	t_cmd	*commands;

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
	{
		char **envp = env_to_tab(s->env);
		tokens = expand_all_tokens(tokens, envp, s->exit_status);
		free_env_tab(envp);
	}
	commands = parse_tokens_to_commands(tokens, ctx, s);
	if (!commands)
	{
		free_tokens(tokens);
		free(cleaned_input);
		return (NULL);
	}
	remove_quotes_from_commands(commands);
	free_tokens(tokens);
	free(cleaned_input);
	return (commands);
}

t_minishell	*setup_shell(char **envp)
{
	t_minishell	*s;

	s = malloc(sizeof(t_minishell));
	s->env = init_env(envp);
	s->exit_status = 0;
	s->saved_stdout = dup(STDOUT_FILENO);
	s->saved_stdin = dup(STDIN_FILENO);
	return (s);
}

static t_minishell	*g_shell = NULL;

int	process_input(char *input, char **envp, t_shell_ctx *ctx)
{
	if (!g_shell)
		g_shell = setup_shell(envp);
	g_shell->commands = parse_tokens(input, g_shell, ctx);
	if (!g_shell->commands)
	{
		if (ctx->syntax_error)
			return (2);
		return (1);
	}
	{
		t_cmd *cmd_list = g_shell->commands;
		if (g_shell->commands->args && g_shell->commands->args[0])
			execute_commands(&g_shell);
		free_commands(cmd_list);
		g_shell->commands = NULL;
		return (g_shell->exit_status);
	}
}

void	cleanup_shell(void)
{
	if (g_shell)
	{
		free_minishell(g_shell);
		g_shell = NULL;
	}
}

int	handle_input_line(char *input, char **envp, t_shell_ctx *ctx)
{
	if (*input)
		return (process_input(input, envp, ctx));
	return (0);
}
