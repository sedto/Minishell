/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   signals.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/21 10:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/12 21:11:16 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"
#include <readline/readline.h>
#include <readline/history.h>
#include <signal.h>

/* Gestionnaire pour SIGINT (Ctrl+C) */
void	handle_sigint(int sig)
{
	(void)sig;
	g_signal = SIGINT;
	write(STDOUT_FILENO, "\n", 1);
	rl_on_new_line();
	rl_replace_line("", 0);
	rl_redisplay();
}

/* Gestionnaire pour SIGQUIT (Ctrl+\) - ne fait rien (comportement bash) */
void	handle_sigquit(int sig)
{
	(void)sig;
	// Ne rien faire : pas de retour à la ligne, pas de prompt, pas d'effacement
	// Cela laisse le prompt inchangé, comme bash
}

/* Configure les gestionnaires de signaux pour le mode interactif */
void	setup_signals(void)
{
	struct sigaction	sa_int;
	struct sigaction	sa_quit;

	sigemptyset(&sa_int.sa_mask);
	sa_int.sa_flags = SA_RESTART;
	sa_int.sa_handler = handle_sigint;
	sigaction(SIGINT, &sa_int, NULL);
	sigemptyset(&sa_quit.sa_mask);
	sa_quit.sa_flags = 0;
	sa_quit.sa_handler = SIG_IGN;
	sigaction(SIGQUIT, &sa_quit, NULL);
}

/* Restaure les signaux par défaut (pour les processus enfants) */
void	reset_signals(void)
{
	signal(SIGINT, SIG_DFL);
	signal(SIGQUIT, SIG_DFL);
}

/* Plus besoin de process_signals() */
void	process_signals(void)
{
	g_signal = 0;  /* Reset le signal */
}
