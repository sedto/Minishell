/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/05/26 22:24:01 by dibsejra          #+#    #+#             */
/*   Updated: 2025/05/26 22:27:38 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

// Variable globale pour les signaux (obligatoire selon le sujet)
volatile sig_atomic_t	g_signal = 0;

// Traite une ligne d'input
static int	process_input(char *input)
{
	char	*cleaned_input;

	cleaned_input = clean_input(input);
	if (!cleaned_input)
	{
		printf("Erreur: allocation mémoire\n");
		return (1);
	}
	printf("Original: %s\n", input);
	printf("Cleaned : %s\n", cleaned_input);
	free(cleaned_input);
	return (0);
}

// Boucle principale du shell
int	main(void)
{
	char	*input;

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
		process_input(input);
		free(input);
	}
	return (0);
}