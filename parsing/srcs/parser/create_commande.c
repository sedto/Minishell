/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   create_commande.c                                  :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/20 01:57:16 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/08 01:04:44 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

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
void	add_argument(t_cmd *cmd, char *arg)
{
	char	**new_args;
	char	*arg_copy;
	int		count;
	int		i;

	if (!cmd || !arg)
		return ;
	count = count_args(cmd->args);
	
	/* Dupliquer l'argument d'abord */
	arg_copy = ft_strdup(arg);
	if (!arg_copy)
		return ;
		
	new_args = malloc((count + 2) * sizeof(char *));
	if (!new_args)
	{
		free(arg_copy);
		return ;
	}
	
	i = 0;
	while (i < count)
	{
		new_args[i] = cmd->args[i];
		i++;
	}
	new_args[count] = arg_copy;
	new_args[count + 1] = NULL;
	
	free(cmd->args);  /* Free seulement le tableau, pas les strings */
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

/* Gère les redirections de sortie (>) */
void	handle_redirect_out(t_cmd *current_cmd, t_token **token, t_shell_ctx *ctx)
{
	(void)ctx;
	char	*new_file;

	*token = (*token)->next;
	if (*token && (*token)->type == TOKEN_WORD)
	{
		new_file = ft_strdup((*token)->value);
		if (new_file)
		{
			if (current_cmd->output_file)
				free(current_cmd->output_file);  /* Libérer l'ancien fichier */
			current_cmd->output_file = new_file;  /* Dernière redirection l'emporte */
			current_cmd->append = 0;
		}
	}
}

/* Gère les redirections en append (>>) */
void	handle_redirect_append(t_cmd *current_cmd, t_token **token, t_shell_ctx *ctx)
{
	(void)ctx;
	char	*new_file;

	*token = (*token)->next;
	if (*token && (*token)->type == TOKEN_WORD)
	{
		new_file = ft_strdup((*token)->value);
		if (new_file)
		{
			if (current_cmd->output_file)
				free(current_cmd->output_file);  /* Libérer l'ancien fichier */
			current_cmd->output_file = new_file;  /* Dernière redirection l'emporte */
			current_cmd->append = 1;
		}
	}
}

/* Gère les redirections d'entrée (<) */
void	handle_redirect_in(t_cmd *current_cmd, t_token **token, t_shell_ctx *ctx)
{
	(void)ctx;
	char	*new_file;

	*token = (*token)->next;
	if (*token && (*token)->type == TOKEN_WORD)
	{
		new_file = ft_strdup((*token)->value);
		if (new_file)
		{
			if (current_cmd->input_file)
				free(current_cmd->input_file);
			current_cmd->input_file = new_file;
			current_cmd->heredoc = 0;
		}
	}
}

/* Gère les heredoc (<<) */
void	handle_heredoc(t_cmd *current_cmd, t_token **token, t_shell_ctx *ctx)
{
	(void)ctx;
	char	*new_file;

	*token = (*token)->next;
	if (*token && (*token)->type == TOKEN_WORD)
	{
		new_file = ft_strdup((*token)->value);
		if (new_file)
		{
			if (current_cmd->input_file)
				free(current_cmd->input_file);  /* Libérer l'ancien fichier */
			current_cmd->input_file = new_file;  /* Dernière redirection l'emporte */
			current_cmd->heredoc = 1;
		}
	}
}
