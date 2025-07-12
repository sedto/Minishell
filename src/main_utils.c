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
	tokens = expand_all_tokens(tokens, env_to_tab(s->env), s->exit_status);
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

int	process_input(char *input, char **envp, t_shell_ctx *ctx)
{
	static t_minishell	*s = NULL;

	if (!s)
		s = setup_shell(envp);
	s->commands = parse_tokens(input, s, ctx);
	if (!s->commands)
	{
		if (ctx->syntax_error)
			return (2);
		return (1);
	}
	if (s->commands && s->commands->args && s->commands->args[0])
		execute_commands(&s);
	free_commands(s->commands);
	return (s->exit_status);
}

int	handle_input_line(char *input, char **envp, t_shell_ctx *ctx)
{
	if (*input)
		return (process_input(input, envp, ctx));
	return (0);
}
