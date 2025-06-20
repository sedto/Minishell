/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/05/26 22:24:01 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/20 21:29:18 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

volatile sig_atomic_t	g_signal = 0;

/* Boucle principale du mode interactif */
static int	run_interactive_mode(char **envp)
{
	char	*input;
	int		exit_code;

	exit_code = 0;
	while (1)
	{
		input = readline("minishell$ ");
		if (!input)
		{
			printf("exit\n");
			break ;
		}
		if (*input)
			add_history(input);
		if (handle_input_line(input, envp, &exit_code))
		{
			free(input);
			break ;
		}
		free(input);
	}
	return (exit_code);
}

/* Point d'entrée principal du minishell */
int	main(int argc, char **argv, char **envp)
{
	int	exit_code;

	exit_code = 0;
	if (argc == 3 && ft_strncmp(argv[1], "-c", 2) == 0)
	{
		exit_code = process_input(argv[2], envp, exit_code);
		return (exit_code);
	}
	return (run_interactive_mode(envp));
}
