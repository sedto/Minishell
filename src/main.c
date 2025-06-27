/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/05/26 22:24:01 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/28 01:23:03 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../includes/minishell.h"

volatile sig_atomic_t	g_signal = 0;
int						g_syntax_error = 0;  /* Flag pour erreurs de syntaxe */

/* Boucle principale du mode interactif */
static int	run_interactive_mode(char **envp)
{
	char	*input;
	int		exit_code;

	exit_code = 0;
	setup_signals();
	
	while (1)
	{
		/* Reset g_signal et rl_done avant readline */
		g_signal = 0;
		rl_done = 0;
		
		input = readline("minishell$ ");
		
		/* Si readline retourne NULL */
		if (!input)
		{
			/* Si c'est à cause de Ctrl+C */
			if (g_signal == SIGINT)
			{
				continue;     /* Retour à la boucle = nouveau prompt */
			}
			/* Sinon c'est EOF (Ctrl+D) */
			printf("exit\n");
			break;
		}
		
		/* Si ligne vide après Ctrl+C */
		if (g_signal == SIGINT)
		{
			free(input);
			continue;
		}
		
		if (*input)
			add_history(input);
			
		if (handle_input_line(input, envp, &exit_code))
		{
			free(input);
			break;
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
