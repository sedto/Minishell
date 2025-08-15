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
		t_shell_ctx *ctx)
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
	exit_code = handle_input_line(input, envp, ctx);
	return (exit_code);
}

static int	run_shell_loop(char **envp, t_shell_ctx *ctx)
{
	char	*input;
	int		exit_code;

	exit_code = 0;
	while (1)
	{
		disable_echoctl();
		g_signal = 0;
		input = readline("minishell$ ");
		exit_code = process_interactive_input(input, envp, ctx);
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

	ctx.syntax_error = 0;
	setup_signals();
	exit_code = run_shell_loop(envp, &ctx);
	cleanup_shell();
	return (exit_code);
}

int	main(int argc, char **argv, char **envp)
{
	int			exit_code;
	t_shell_ctx	ctx;

	if (argc == 3 && ft_strncmp(argv[1], "-c", 2) == 0)
	{
		ctx.syntax_error = 0;
		exit_code = process_input(argv[2], envp, &ctx);
		cleanup_shell();
		return (exit_code);
	}
	return (run_interactive_mode(envp));
}
