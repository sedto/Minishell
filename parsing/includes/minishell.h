/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   minishell.h                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/05/26 00:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/05/26 22:37:45 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef MINISHELL_H
# define MINISHELL_H

# include <stdlib.h>
# include <stdio.h>
# include <unistd.h>
# include <readline/readline.h>
# include <readline/history.h>
# include <signal.h>
# include <sys/wait.h>
# include <sys/stat.h>
# include <fcntl.h>
# include <errno.h>
# include <string.h>
# include "libft.h"

/* ************************************************************************** */
/*                                STRUCTURES                                  */
/* ************************************************************************** */

typedef struct s_token
{
	char			*value;
	int				type;
	struct s_token	*next;
}					t_token;

typedef struct s_cmd
{
	char			**args;
	char			*input_file;
	char			*output_file;
	int				append;
	int				heredoc;
	struct s_cmd	*next;
}					t_cmd;

typedef struct s_env
{
	char			*key;
	char			*value;
	struct s_env	*next;
}					t_env;

typedef struct s_minishell
{
	t_env			*env;
	t_token			*tokens;
	t_cmd			*commands;
	int				exit_status;
	int				in_heredoc;
}					t_minishell;

/* ************************************************************************** */
/*                                CONSTANTS                                   */
/* ************************************************************************** */

# define TOKEN_WORD		1
# define TOKEN_PIPE		2
# define TOKEN_REDIR_IN	3
# define TOKEN_REDIR_OUT 4
# define TOKEN_APPEND	5
# define TOKEN_HEREDOC	6

/* ************************************************************************** */
/*                             PARSING FUNCTIONS                             */
/* ************************************************************************** */

// clean_input.c
char		*clean_input(char *str);

// Autres fonctions de parsing à ajouter plus tard
// t_token		*tokenize(char *input);
// t_cmd		*parse_commands(t_token *tokens);
// int			validate_syntax(t_token *tokens);

/* ************************************************************************** */
/*                            BUILTIN FUNCTIONS                              */
/* ************************************************************************** */

// À implémenter plus tard
// int			builtin_echo(char **args);
// int			builtin_cd(char **args, t_env *env);
// int			builtin_pwd(void);
// int			builtin_export(char **args, t_env **env);
// int			builtin_unset(char **args, t_env **env);
// int			builtin_env(t_env *env);
// int			builtin_exit(char **args);

/* ************************************************************************** */
/*                           EXECUTION FUNCTIONS                             */
/* ************************************************************************** */

// À implémenter plus tard
// int			execute_command(t_cmd *cmd, t_env *env);
// int			execute_pipeline(t_cmd *cmds, t_env *env);

/* ************************************************************************** */
/*                             UTILS FUNCTIONS                               */
/* ************************************************************************** */

// À implémenter plus tard
// t_env		*init_env(char **envp);
// void		free_env(t_env *env);
// void		free_tokens(t_token *tokens);
// void		free_commands(t_cmd *commands);
// char		*get_env_value(t_env *env, char *key);

/* ************************************************************************** */
/*                             SIGNAL HANDLING                               */
/* ************************************************************************** */

// À implémenter plus tard
// void		setup_signals(void);
// void		handle_sigint(int sig);
// void		handle_sigquit(int sig);

#endif