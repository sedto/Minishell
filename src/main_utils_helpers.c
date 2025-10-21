/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main_utils_helpers.c                               :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/08/18 14:20:10 by dibsejra          #+#    #+#             */
/*   Updated: 2025/08/18 14:20:20 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

t_token	*process_tokens_expansion(t_token *tokens, t_minishell *s)
{
	char	**envp;

	envp = env_to_tab(s->env);
	tokens = expand_all_tokens(tokens, envp, s->exit_status);
	free_env_tab(envp);
	return (tokens);
}

t_cmd	*build_commands_from_tokens(t_token *tokens, char *cleaned_input,
		t_shell_ctx *ctx, t_minishell *s)
{
	t_cmd	*commands;

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
	if (!s)
		return (NULL);
	s->env = init_env(envp);
	s->parsed = NULL;
	s->commands = NULL;
	s->tokens = NULL;
	s->exit_status = 0;
	s->in_heredoc = 0;
	s->saved_stdout = dup(STDOUT_FILENO);
	s->saved_stdin = dup(STDIN_FILENO);
	return (s);
}

void	cleanup_shell(t_minishell *shell)
{
	if (shell)
		free_minishell(shell);
}

int	handle_input_line(char *input, char **envp, t_shell_ctx *ctx,
		t_minishell *shell)
{
	if (*input)
		return (process_input(input, envp, ctx, shell));
	return (0);
}
