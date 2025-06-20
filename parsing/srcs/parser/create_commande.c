/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   create_commande.c                                  :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/20 01:57:16 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/20 17:15:22 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

/* Crée une nouvelle structure de commande initialisée à zéro */
t_cmd	*new_command(void)
{
	t_cmd	*cmd;

	cmd = malloc(sizeof(t_cmd));
	if (!cmd)
		return (NULL);
	cmd->args = NULL;
	cmd->input_file = NULL;
	cmd->output_file = NULL;
	cmd->append = 0;
	cmd->heredoc = 0;
	cmd->next = NULL;
	return (cmd);
}

/* Ajoute un argument au tableau d'arguments d'une commande */
void add_argument(t_cmd *cmd, char *arg)
{
    char **new_args;
    int   count;
    int   i;

    if (!cmd || !arg)
        return;
    count = count_args(cmd->args);
    new_args = malloc((count + 2) * sizeof(char *));
    if (!new_args)
        return;
    
    // Copier les anciens arguments
    i = 0;
    while (i < count)
    {
        new_args[i] = cmd->args[i];
        i++;
    }
    
    // Ajouter le nouvel argument
    new_args[count] = ft_strdup(arg);
    if (!new_args[count])  // Vérifier ft_strdup
    {
        free(new_args);
        return;
    }
    new_args[count + 1] = NULL;
    
    free(cmd->args);  // Libérer l'ancien tableau
    cmd->args = new_args;
}


/* Compte le nombre d'arguments dans un tableau */
int	count_args(char **args)
{
	int	count;

	count = 0;
	if (!args)
		return (0);
	while (args[count])
		count++;
	return (count);
}

/* Ajoute une commande à la fin de la liste chaînée de commandes */
void	add_command_to_list(t_cmd **commands, t_cmd *new_cmd)
{
	t_cmd	*current;

	if (!commands || !new_cmd)
		return ;
	if (!*commands)
	{
		*commands = new_cmd;
		return ;
	}
	current = *commands;
	while (current->next)
		current = current->next;
	current->next = new_cmd;
}

/* Libère toute la mémoire allouée pour la liste de commandes */
void	free_commands(t_cmd *commands)
{
	t_cmd	*current;
	t_cmd	*next;
	int		i;

	current = commands;
	while (current)
	{
		next = current->next;
		if (current->args)
		{
			i = 0;
			while (current->args[i])
				free(current->args[i++]);
			free(current->args);
		}
		if (current->input_file)
			free(current->input_file);
		if (current->output_file)
			free(current->output_file);
		free(current);
		current = next;
	}
}
