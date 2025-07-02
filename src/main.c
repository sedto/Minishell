/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/28 01:56:46 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/28 02:12:08 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

volatile sig_atomic_t	g_signal = 0;

/* Disable ECHOCTL to prevent control characters from being echoed to the terminal */
void	disable_echoctl(void)
{
	struct termios term;

	if (tcgetattr(STDIN_FILENO, &term) == 0)
	{
		term.c_lflag &= ~ECHOCTL;
		tcsetattr(STDIN_FILENO, TCSANOW, &term);
	}
}


/* Boucle principale du mode interactif */
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
		/* Ctrl+D (EOF) */
		if (!input)
		{
			printf("exit\n");
			break;
		}
		/* Ctrl+C - affichage déjà géré par handle_sigint */
		if (g_signal == SIGINT)
		{
			free(input);
			continue;
		}
		if (*input)
			add_history(input);
		exit_code = handle_input_line(input, envp, &ctx);
		free(input);
	}
	return (exit_code);
}

/* Point d'entrée principal du minishell */
int	main(int argc, char **argv, char **envp)
{
	if (argc == 3 && ft_strncmp(argv[1], "-c", 2) == 0)
	{
		t_shell_ctx ctx;

		ctx.syntax_error = 0;
		return(process_input(argv[2], envp, &ctx));
	}
	return (run_interactive_mode(envp));
}
