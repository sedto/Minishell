/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/28 01:56:46 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/12 21:11:16 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

volatile sig_atomic_t	g_signal = 0;

void	disable_echoctl(void)
{
	struct termios	term;

	if (tcgetattr(STDIN_FILENO, &term) == 0)
	{
		term.c_lflag &= ~ECHOCTL;
		tcsetattr(STDIN_FILENO, TCSANOW, &term);
	}
}

static int	process_interactive_input(char *input, char **envp,
		t_shell_ctx *ctx, t_minishell *shell)
{
	int	exit_code;

	if (!input)
	{
		printf("exit\n");
		return (-1);
	}
	if (g_signal == SIGINT)
		return (0);
	if (*input)
		add_history(input);
	exit_code = handle_input_line(input, envp, ctx, shell);
	return (exit_code);
}

static int	run_shell_loop(char **envp, t_shell_ctx *ctx, t_minishell *shell)
{
	char	*input;
	int		exit_code;

	exit_code = 0;
	while (1)
	{
		disable_echoctl();
		g_signal = 0;
		input = readline("minishell$ ");
		exit_code = process_interactive_input(input, envp, ctx, shell);
		if (exit_code == -1)
		{
			free(input);
			break ;
		}
		if (g_signal == SIGINT || exit_code == 0)
		{
			free(input);
			continue ;
		}
		free(input);
	}
	return (exit_code);
}

static int	run_interactive_mode(char **envp)
{
	int			exit_code;
	t_shell_ctx	ctx;
	t_minishell	*shell;

	ctx.syntax_error = 0;
	setup_signals();
	shell = setup_shell(envp);
	if (!shell)
		return (1);
	exit_code = run_shell_loop(envp, &ctx, shell);
	cleanup_shell(shell);
	return (exit_code);
}

int	main(int argc, char **argv, char **envp)
{
	int			exit_code;
	t_shell_ctx	ctx;
	t_minishell	*shell;

	if (argc == 3 && ft_strncmp(argv[1], "-c", 2) == 0)
	{
		ctx.syntax_error = 0;
		shell = setup_shell(envp);
		if (!shell)
			return (1);
		exit_code = process_input(argv[2], envp, &ctx, shell);
		cleanup_shell(shell);
		return (exit_code);
	}
	return (run_interactive_mode(envp));
}
