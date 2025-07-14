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

static int	run_interactive_mode(char **envp)
{
	char		*input;
	int			exit_code;
	t_shell_ctx	ctx;

	ctx.syntax_error = 0;
	setup_signals();
	while (1)
	{
		disable_echoctl();
		g_signal = 0;
		input = readline("minishell$ ");
		if (!input)
		{
			printf("exit\n");
			break ;
		}
		/* Si l'utilisateur a tapé quelque chose, ignore g_signal car c'est une vraie commande */
		if (g_signal == SIGINT && (!input || !*input))
		{
			if (input)
				free(input);
			process_signals();
			continue ;
		}
		/* Reset g_signal car on a une vraie commande */
		if (input && *input)
		{
			g_signal = 0;
		}
		if (*input)
			add_history(input);
		exit_code = handle_input_line(input, envp, &ctx);
		free(input);
	}
	get_shell_instance(NULL);
	rl_clear_history();
	rl_cleanup_after_signal();
	return (exit_code);
}

int	main(int argc, char **argv, char **envp)
{
	int	exit_code;

	if (argc == 3 && ft_strncmp(argv[1], "-c", 2) == 0)
	{
		t_shell_ctx	ctx;
	
		ctx.syntax_error = 0;
		exit_code = process_input(argv[2], envp, &ctx);
		get_shell_instance(NULL);
		return (exit_code);
	}
	return (run_interactive_mode(envp));
}
