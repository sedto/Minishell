/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   signals.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/21 10:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/21 01:08:53 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../libft/libft.h"
#include "parsing/includes/minishell.h"

extern volatile sig_atomic_t	g_signal;

/* Gestionnaire pour SIGINT (Ctrl+C) */
void	handle_sigint(int sig)
{
	(void)sig;
	g_signal = SIGINT;
	printf("\n");
	rl_on_new_line();
	rl_replace_line("", 0);
	rl_redisplay();
}

/* Gestionnaire pour SIGQUIT (Ctrl+\) - ne fait rien en mode interactif */
void	handle_sigquit(int sig)
{
	(void)sig;
	g_signal = SIGQUIT;
	/* En mode interactif, on ignore Ctrl+\ */
}

/* Configure les gestionnaires de signaux */
void	setup_signals(void)
{
	signal(SIGINT, handle_sigint);   /* Ctrl+C */
	signal(SIGQUIT, handle_sigquit); /* Ctrl+\ */
}

/* Restaure les signaux par défaut (pour les processus enfants) */
void	reset_signals(void)
{
	signal(SIGINT, SIG_DFL);
	signal(SIGQUIT, SIG_DFL);
}
