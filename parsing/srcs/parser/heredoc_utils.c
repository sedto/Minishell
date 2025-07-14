/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   heredoc_utils.c                                    :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/07/10 10:52:38 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/12 21:11:16 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../includes/minishell.h"

char	*read_heredoc_content(char *delimiter, int *should_exit, t_minishell *s, int expand)
{
	char	*line;
	char	*content;
	char	*temp;
	char	*with_newline;
	int		delim_len;

	if (!delimiter)
		return (NULL);
	*should_exit = 0;
	delim_len = ft_strlen(delimiter);
	content = ft_strdup("");
	if (!content)
		return (NULL);
	while (1)
	{
		write(STDOUT_FILENO, "> ", 2);
		line = readline("");
		if (!line)
		{
			printf("minishell: warning: here-document delimited by end-of-file (wanted '%s')\n", delimiter);
			break ;
		}
		if (g_signal == SIGINT)
		{
			free(line);
			free(content);
			*should_exit = 1;
			return (NULL);
		}
		if (ft_strncmp(line, delimiter, (size_t)delim_len) == 0 && ft_strlen(line) == (size_t)delim_len)
		{
			free(line);
			break ;
		}
		if (expand)
		{
			char **env_tab = env_to_tab(s->env);
			char *expanded_line = expand_string(line, env_tab, s->exit_status);
			free_env_tab(env_tab);
			free(line);
			line = expanded_line;
		}
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

t_file	*create_heredoc_file(char *delimiter, char *content)
{
	t_file	*file;

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

void	handle_heredoc(t_cmd *current_cmd, t_token **token, t_shell_ctx *ctx, t_minishell *s)
{
	char	*delimiter;
	char	*content;
	t_file	*node;
	t_file	*tmp;
	int		should_exit;
	int		expand;

	*token = (*token)->next;
	if (*token && (*token)->type == TOKEN_WORD)
	{
		delimiter = (*token)->value;
		expand = (ft_strchr(delimiter, '\'') == NULL && ft_strchr(delimiter, '"') == NULL);
		delimiter = remove_quotes(delimiter);
		content = read_heredoc_content(delimiter, &should_exit, s, expand);
		if (should_exit)
		{
			free(delimiter);
			ctx->syntax_error = 1;
			return ;
		}
		if (!content)
		{
			free(delimiter);
			ctx->syntax_error = 1;
			return ;
		}
		node = create_heredoc_file(delimiter, content);
		free(delimiter);  /* libérer après create_heredoc_file car il fait sa propre copie */
		if (!node)
		{
			free(content);
			return ;
		}
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
