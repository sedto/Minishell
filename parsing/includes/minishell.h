/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   minishell.h                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/05/26 00:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/03 01:37:04 by dibsejra         ###   ########.fr       */
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
/*                                CONSTANTS                                   */
/* ************************************************************************** */

typedef enum e_token_type
{
	TOKEN_WORD = 0,
	TOKEN_PIPE = 1,
	TOKEN_REDIR_IN = 2,
	TOKEN_REDIR_OUT = 3,
	TOKEN_APPEND = 4,
	TOKEN_HEREDOC = 5,
	TOKEN_EOF = 6
}	t_token_type;

/* ************************************************************************** */
/*                                STRUCTURES                                  */
/* ************************************************************************** */

typedef struct s_token
{
	char			*value;
	t_token_type	type;
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
/*                             PARSING FUNCTIONS                             */
/* ************************************************************************** */

// clean_input.c
char		*clean_input(char *str);

// create_tokens.c
t_token		*create_token(t_token_type type, char *value);
void		add_token_to_list(t_token **tokens, t_token *new_token);
void		free_tokens(t_token *tokens);

// tokenize.c
t_token		*tokenize(char *input);
void		handle_word(char *input, int *i, t_token **tokens);

// tokenize_operators.c
void		handle_operator(char *input, int *i, t_token **tokens);
t_token		*handle_input_redir(char *input, int *i);
t_token		*handle_output_redir(char *input, int *i);

// tokenize_utils.c
int			is_quote(char c);
int			is_operator_char(char c);
void		skip_spaces(char *input, int *i);
void		add_eof_token(t_token **tokens);
void		handle_quoted_word(char *input, int *i, t_token **tokens);

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