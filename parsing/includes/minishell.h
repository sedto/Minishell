/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   minishell.h                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/05/26 00:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/21 01:55:12 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef MINISHELL_H
# define MINISHELL_H

# include <stdlib.h>
# include <stdio.h>
# include <unistd.h>
# include <stdint.h>
# include <readline/readline.h>
# include <readline/history.h>
# include <signal.h>
# include <sys/wait.h>
# include <sys/stat.h>
# include <fcntl.h>
# include <errno.h>
# include <string.h>
# include "../../libft/libft.h"

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

// Structure pour passer les données lors de l'expansion des variables
// Utilisée pour éviter de passer trop de paramètres entre les fonctions
typedef struct s_expand_data
{
	char	**envp;
	int		exit_code;
	char	*result;
	int		result_size;
	int		pos;
	int		*i;
	int		*j;
}	t_expand_data;

// Structure pour le nettoyage des entrées (clean_input)
typedef struct s_clean_data
{
	char	*str;
	char	*cleaned;
	int		*i;
	int		*j;
	int		*in_single_quote;
	int		*in_double_quote;
}	t_clean_data;

/* ************************************************************************** */
/*                             PARSING FUNCTIONS                             */
/* ************************************************************************** */

// clean_input.c
char		*clean_input(char *str);

// main_utils.c
int			is_exit_command(char *input);
t_cmd		*parse_tokens(char *input, char **envp, int exit_code);
int			process_input(char *input, char **envp, int exit_code);
int			handle_input_line(char *input, char **envp, int *exit_code);

// clean_input_utils.c
void		add_space_if_needed(char *cleaned, int *j, char next_char,
				int closing);
int			handle_single_quote(t_clean_data *data);
int			handle_double_quote(t_clean_data *data);

// create_tokens.c
t_token		*create_token(t_token_type type, char *value);
void		add_token_to_list(t_token **tokens, t_token *new_token);
void		free_tokens(t_token *tokens);

// tokenize.c
t_token		*tokenize(char *input);
int			handle_word(char *input, int *i, t_token **tokens);

// tokenize_operators.c
int			handle_operator(char *input, int *i, t_token **tokens);
t_token		*handle_input_redir(char *input, int *i);
t_token		*handle_output_redir(char *input, int *i);

// tokenize_utils.c
int			is_quote(char c);
int			is_operator_char(char c);
void		skip_spaces(char *input, int *i);
void		add_eof_token(t_token **tokens);
int			handle_quoted_word(char *input, int *i, t_token **tokens);

// expand_variables.c
char		*find_var_in_env(char *var_name, char **envp);
char		*handle_special_var(char *var_name, int exit_code);
char		*expand_single_var(char *var_name, char **envp, int exit_code);
int			should_expand_token(char *value);
t_token		*expand_all_tokens(t_token *tokens, char **envp, int exit_code);

// expand_strings.c
char		*expand_string(char *input, char **envp, int exit_code);

// expand_process.c
int			handle_valid_variable(char *var_name, t_expand_data *data,
				int var_len);
void		handle_invalid_variable(t_expand_data *data, char *var_name,
				int var_len);
int			process_variable(char *input, t_expand_data *data);
void		handle_variable_processing(char *input, t_expand_data *data);
int			count_variables_in_string(char *str);

// expand_quotes.c
void		init_expand_data(t_expand_data *data, char *input, char **envp,
				int exit_code);
void		handle_single_quote_char(char *input, t_expand_data *data,
				int *in_single_quote, int in_double_quote);
void		handle_double_quote_char(char *input, t_expand_data *data,
				int *in_double_quote, int in_single_quote);
int			should_process_variable(char *input, int i);
void		process_normal_char(char *input, t_expand_data *data);

// expand_utils.c
int			extract_var_name(char *input, int start, char **var_name);
void		copy_var_value_to_result(char *result, int *j, char *var_value);
char		*allocate_result_buffer(char *input);

// create_commande.c
t_cmd		*new_command(void);
void		add_argument(t_cmd *cmd, char *arg);
int			count_args(char **args);
void		add_command_to_list(t_cmd **commands, t_cmd *new_cmd);
void		free_commands(t_cmd *commands);

// parse_commands.c
t_cmd		*parse_tokens_to_commands(t_token *tokens);
int			is_empty_command(t_cmd *cmd);

// parse_handlers.c
void		handle_word_token(t_cmd *current_cmd, t_token *token);
void		handle_pipe_token(t_cmd **commands, t_cmd **current_cmd);
int			validate_initial_syntax(t_token *tokens);

// parse_validation.c
int			validate_pipe_token(t_token *tokens, t_cmd *commands,
				t_cmd *current_cmd);
int			validate_redirection_token(t_token *tokens, t_cmd *commands,
				t_cmd *current_cmd);
int			validate_double_pipe(t_token *tokens, t_cmd *commands,
				t_cmd *current_cmd);

// parse_utils.c
void		handle_redirect_out(t_cmd *current_cmd, t_token **token);
void		handle_redirect_append(t_cmd *current_cmd, t_token **token);
void		handle_redirect_in(t_cmd *current_cmd, t_token **token);
void		handle_heredoc(t_cmd *current_cmd, t_token **token);
void		process_redirection_token(t_cmd *current_cmd, t_token **tokens);

// quote_remover.c
void		remove_quotes_from_commands(t_cmd *commands);

/* ************************************************************************** */
/*                             BUILTIN FUNCTIONS                              */
/* ************************************************************************** */

// builtins.c
int			builtin_echo(char **args);
int			builtin_pwd(void);
int			builtin_env(t_env *env);
int			builtin_export(char **args, t_env **env);
int			builtin_unset(char **args, t_env **env);
int			builtin_exit(char **args);
int			is_builtin(char *cmd);
int			execute_builtin(char **args, t_env **env);

/* ************************************************************************** */
/*                          ENVIRONMENT FUNCTIONS                            */
/* ************************************************************************** */

// env_utils.c
t_env		*create_env_node(char *key, char *value);
t_env		*init_env(char **envp);
char		*get_env_value(t_env *env, char *key);
void		set_env_value(t_env **env, char *key, char *value);
void		unset_env_value(t_env **env, char *key);
void		free_env(t_env *env);

/* ************************************************************************** */
/*                             SIGNAL HANDLING                               */
/* ************************************************************************** */

// signals.c
void		setup_signals(void);
void		reset_signals(void);
void		handle_sigint(int sig);
void		handle_sigquit(int sig);

/* ************************************************************************** */
/*                           UTILITY FUNCTIONS                               */
/* ************************************************************************** */

// utils.c
char		**env_to_array(t_env *env);
void		free_array(char **array);
char		*find_executable(char *cmd, t_env *env);
int			count_commands(t_cmd *commands);
void		command_not_found(char *cmd);

/* ************************************************************************** */
/*                           EXECUTION FUNCTIONS                             */
/* ************************************************************************** */

// À implémenter par l'exécuteur
// int			execute_command(t_cmd *cmd, t_env *env);
// int			execute_pipeline(t_cmd *cmds, t_env *env);
// int			builtin_cd(char **args, t_env **env);

/* ************************************************************************** */
/*                             UTILS FUNCTIONS                               */
/* ************************************************************************** */

/* ************************************************************************** */
/*                             SIGNAL HANDLING                               */
/* ************************************************************************** */

// signals.c
void		setup_signals(void);
void		reset_signals(void);
void		handle_sigint(int sig);
void		handle_sigquit(int sig);

#endif