/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   heredoc_utils.c                                    :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/07/10 10:52:38 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/10 11:09:10 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"
/* Lit le contenu du heredoc ligne par ligne */
char *read_heredoc_content(char *delimiter, int *should_exit)
{
    char    *line;
    char    *content;
    char    *temp;
    char    *with_newline;
    int     delim_len;

    if (!delimiter)
        return (NULL);
    
    *should_exit = 0;
    delim_len = ft_strlen(delimiter);
    content = ft_strdup("");
    if (!content)
        return (NULL);

    while (1)
    {
        write(STDOUT_FILENO, "> ", 2);  // Prompt heredoc
        line = readline("");
        
        // Ctrl+D pendant heredoc
        if (!line)
        {
            printf("minishell: warning: here-document delimited by end-of-file (wanted '%s')\n", delimiter);
            break;
        }
        
        // Ctrl+C pendant heredoc
        if (g_signal == SIGINT)
        {
            free(line);
            free(content);
            *should_exit = 1;
            return (NULL);
        }
        
        // Vérifier délimiteur
        if (ft_strncmp(line, delimiter, (size_t)delim_len) == 0 && ft_strlen(line) == (size_t)delim_len)
        {
            free(line);
            break;
        }
        
        // Ajouter ligne au contenu
        with_newline = ft_strjoin(line, "\n");
        if (!with_newline)
        {
            free(line);
            free(content);
            return (NULL);
        }
        
        temp = ft_strjoin(content, with_newline);
        free(content);
        free(with_newline);
        free(line);
        
        if (!temp)
            return (NULL);
        content = temp;
    }
    
    return (content);
}

/* Crée un noeud t_file pour heredoc */
t_file *create_heredoc_file(char *delimiter, char *content)
{
    t_file  *file;

    file = malloc(sizeof(t_file));
    if (!file)
        return (NULL);
    
    file->name = ft_strdup(delimiter);
    file->heredoc_content = content;
    file->fd = -1;
    file->type = HEREDOC;
    file->next = NULL;
    
    if (!file->name)
    {
        free(file->heredoc_content);
        free(file);
        return (NULL);
    }
    
    return (file);
}
/* Gère les redirections d'entrée (<) */
void	handle_redirect_in(t_cmd *current_cmd, t_token **token, t_shell_ctx *ctx)
{
	(void)ctx;
	char	*new_file;
	t_file	*node;
	t_file	*tmp;

	*token = (*token)->next;
	if (*token && (*token)->type == TOKEN_WORD)
	{
		new_file = ft_strdup((*token)->value);
		if (new_file)
		{
			node = create_t_file_node(new_file);
			node->type = INPUT;
			if (current_cmd->files)
			{
				tmp = current_cmd->files;
				while (tmp->next)
					tmp = tmp->next;
				tmp->next = node;
			}
			else
				current_cmd->files = node;
		}
	}
}

/* Gère les heredoc (<<) */
void handle_heredoc(t_cmd *current_cmd, t_token **token, t_shell_ctx *ctx)
{
    char    *delimiter;
    char    *content; 
    t_file  *node;
    t_file  *tmp;
    int     should_exit;

    *token = (*token)->next;
    if (*token && (*token)->type == TOKEN_WORD)
    {
        delimiter = (*token)->value;
        
        // LECTURE IMMÉDIATE du contenu heredoc
        content = read_heredoc_content(delimiter, &should_exit);
        
        if (should_exit)  // Ctrl+C pendant heredoc
        {
            ctx->syntax_error = 1;
            return;
        }
        
        if (!content)
        {
            ctx->syntax_error = 1;
            return;
        }
        
        // Créer le noeud avec le contenu
        node = create_heredoc_file(delimiter, content);
        if (!node)
        {
            free(content);
            return;
        }
        
        // Ajouter à la liste des fichiers
        if (current_cmd->files)
        {
            tmp = current_cmd->files;
            while (tmp->next)
                tmp = tmp->next;
            tmp->next = node;
        }
        else
            current_cmd->files = node;
    }
}