/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   signals.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/21 10:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/28 00:01:48 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

/* signals.c - VERSION CORRIGÉE */

#define _POSIX_C_SOURCE 200809L
#define _GNU_SOURCE

#include <unistd.h>
#include <signal.h>
#include <readline/readline.h>
#include <readline/history.h>
#include "../../../libft/libft.h"
#include "../../../includes/minishell.h"

extern volatile sig_atomic_t	g_signal;

/* Gestionnaire pour SIGINT (Ctrl+C) */
void	handle_sigint(int sig)
{
	(void)sig;
	g_signal = SIGINT;
	write(STDOUT_FILENO, "\n", 1);
	/* Force readline à terminer et retourner NULL */
	rl_done = 1;
}

/* Gestionnaire pour SIGQUIT (Ctrl+\) */
void	handle_sigquit(int sig)
{
	(void)sig;
	/* En mode interactif, on ignore Ctrl+\ */
}

/* Configure les gestionnaires de signaux */
void	setup_signals(void)
{
	struct sigaction	sa_int;
	struct sigaction	sa_quit;

	/* IMPORTANT: Désactiver la gestion des signaux par readline */
	rl_catch_signals = 0;
	
	/* Configurer SIGINT */
	sigemptyset(&sa_int.sa_mask);
	sa_int.sa_flags = 0;  /* Pas de SA_RESTART pour interrompre read() */
	sa_int.sa_handler = handle_sigint;
	sigaction(SIGINT, &sa_int, NULL);
	
	/* Configurer SIGQUIT (ignorer en mode interactif) */
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
