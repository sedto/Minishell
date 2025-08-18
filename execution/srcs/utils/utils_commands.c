/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   utils_commands.c                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/08/18 14:23:17 by dibsejra          #+#    #+#             */
/*   Updated: 2025/08/18 14:24:07 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

/* Compte le nombre de commandes dans un pipeline */
int	count_commands(t_cmd *commands)
{
	int	count;

	count = 0;
	while (commands)
	{
		count++;
		commands = commands->next;
	}
	return (count);
}

/* Affiche une erreur de commande non trouvée */
void	command_not_found(char *cmd)
{
	write(STDERR_FILENO, "minishell: ", 11);
	write(STDERR_FILENO, cmd, ft_strlen(cmd));
	write(STDERR_FILENO, ": command not found\n", 20);
}
