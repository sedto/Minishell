/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   minishell.h                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/05/26 00:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/12 23:42:57 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef MINISHELL_H
# define MINISHELL_H

# define _POSIX_C_SOURCE 200809L
# define _GNU_SOURCE

# ifndef ECHOCTL
#  define ECHOCTL 0001000
# endif

# include "../libft/libft.h"
# include <errno.h>
# include <fcntl.h>
# include <signal.h>
# include <stdint.h>
# include <stdio.h>
# include <stdlib.h>
# include <string.h>
# include <stdbool.h>
# include <sys/stat.h>
# include <sys/wait.h>
# include <termios.h>
# include <unistd.h>
# include <readline/history.h>
# include <readline/readline.h>

// Déclaration du contexte AVANT tout prototype ou typedef qui l'utilise

typedef struct s_shell_ctx
{
	int				syntax_error;
	int				exit_code;
	// Tu peux ajouter d'autres flags ici plus tard
}					t_shell_ctx;

/* ************************************************************************** */
/*                                 GLOBALS                                    */
/* ************************************************************************** */

extern volatile sig_atomic_t	g_signal;

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
}					t_token_type;

/* ************************************************************************** */
/*                                STRUCTURES                                  */
/* ************************************************************************** */

typedef struct s_token
{
	char			*value;
	t_token_type	type;
	struct s_token	*next;
}					t_token;

typedef enum e_redir
{
	APPEND,
	OUTPUT,
	INPUT,
	HEREDOC
}					t_redir;

typedef struct s_file
{
	char			*name;
	char			*heredoc_content;
	int				fd;
	t_redir			type;
	struct s_file	*next;
}					t_file;

typedef struct s_cmd
{
	char			**args;
	t_file			*files;
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
	int				saved_stdout;
	int				saved_stdin;
}					t_minishell;

typedef struct s_process_data
{
	t_cmd			**commands;
	t_cmd			**current_cmd;
	t_shell_ctx		*ctx;
	t_minishell		*s;
}					t_process_data;

// Structure pour passer les données lors de l'expansion des variables
// Utilisée pour éviter de passer trop de paramètres entre les fonctions
typedef struct s_expand_data
{
	char			**envp;
	int				exit_code;
	char			*result;
	int				result_size;
	int				pos;
	int				*i;
	int				*j;
}					t_expand_data;

// Structure pour le nettoyage des entrées (clean_input)
typedef struct s_clean_data
{
	char			*str;
	char			*cleaned;
	int				*i;
	int				*j;
	int				*in_single_quote;
	int				*in_double_quote;
}					t_clean_data;

/* ************************************************************************** */
/*                             PARSING FUNCTIONS                             */
/* ************************************************************************** */

// clean_input.c
char				*clean_input(char *str);

// main_utils.c
int					is_exit_command(char *input);
t_cmd				*parse_tokens_to_commands(t_token *tokens,
						t_shell_ctx *ctx, t_minishell *s);
int					process_input(char *input, char **envp, t_shell_ctx *ctx);
int					handle_input_line(char *input, char **envp,
						t_shell_ctx *ctx);
void				cleanup_shell(void);

// clean_input_utils.c
void				add_space_if_needed(char *cleaned, int *j, char next_char,
						int closing);
int					handle_single_quote(t_clean_data *data);
int					handle_double_quote(t_clean_data *data);

// create_tokens.c
t_token				*create_token(t_token_type type, char *value);
void				add_token_to_list(t_token **tokens, t_token *new_token);
void				free_tokens(t_token *tokens);

// tokenize.c
t_token				*tokenize(char *input, t_shell_ctx *ctx);
int					handle_word(char *input, int *i, t_token **tokens,
						t_shell_ctx *ctx);

// tokenize_operators.c
int					handle_operator(char *input, int *i, t_token **tokens);
t_token				*handle_input_redir(char *input, int *i);
t_token				*handle_output_redir(char *input, int *i);

// tokenize_utils.c
int					is_quote(char c);
int					is_operator_char(char c);
void				skip_spaces(char *input, int *i);
void				add_eof_token(t_token **tokens);
int					handle_quoted_word(char *input, int *i, t_token **tokens,
						t_shell_ctx *ctx);

// expand_variables.c
char				*find_var_in_env(char *var_name, char **envp);
char				*handle_special_var(char *var_name, int exit_code);
char				*expand_single_var(char *var_name, char **envp,
						int exit_code);
int					should_expand_token(char *value);
t_token				*expand_all_tokens(t_token *tokens, char **envp,
						int exit_code);

// expand_strings.c
char				*expand_string(char *input, char **envp, int exit_code);

// expand_process.c
int					handle_valid_variable(char *var_name, t_expand_data *data,
						int var_len);
void				handle_invalid_variable(t_expand_data *data, char *var_name,
						int var_len);
int					process_variable(char *input, t_expand_data *data);
void				handle_variable_processing(char *input,
						t_expand_data *data);
int					count_variables_in_string(char *str);

// expand_quotes.c
void				init_expand_data(t_expand_data *data, char *input,
						char **envp, int exit_code);
void				handle_single_quote_char(char *input, t_expand_data *data,
						int *in_single_quote, int in_double_quote);
void				handle_double_quote_char(char *input, t_expand_data *data,
						int *in_double_quote, int in_single_quote);
int					should_process_variable(char *input, int i);
void				process_normal_char(char *input, t_expand_data *data);
int					calc_buffer_size(char *input);

// expand_utils.c
int					extract_var_name(char *input, int start, char **var_name);
void				copy_var_value_to_result(char *result, int *j,
						char *var_value, int max_size);
char				*allocate_result_buffer(char *input);

// create_commande.c
t_cmd				*new_command(void);
void				add_argument(t_cmd *cmd, char *arg);
int					count_args(char **args);
void				add_command_to_list(t_cmd **commands, t_cmd *new_cmd);

// create_commande_utils.c
void				free_commands(t_cmd *commands);
void				handle_redirect_out(t_cmd *current_cmd, t_token **token,
						t_shell_ctx *ctx);
void				handle_redirect_append(t_cmd *current_cmd, t_token **token,
						t_shell_ctx *ctx);
void				handle_redirect_in(t_cmd *current_cmd, t_token **token,
						t_shell_ctx *ctx);

// create_commande_helpers.c
char				**create_new_args_array(int count, char *arg_copy);
void				copy_existing_args(char **new_args, char **old_args,
						int count);
void				free_files(t_file *files);

// parse_commands.c
int					is_empty_command(t_cmd *cmd);

// parse_commands_utils.c
t_cmd				*handle_syntax_error(t_cmd *commands, t_cmd *current_cmd);
int					process_single_token(t_token **tokens,
						t_process_data *data);
int					process_token(t_token **tokens, t_process_data *data);

// heredoc_helpers.c
int					is_delimiter_match(char *line, char *delimiter,
						int delim_len);
char				*process_line_expansion(char *line, t_minishell *s,
						int expand);
char				*append_line_to_content(char *content, char *line);
int					handle_heredoc_signal_exit(int *should_exit, char *line,
						char *content);

// heredoc_read.c
void				print_heredoc_warning(char *delimiter);
char				*process_heredoc_line(char *line, char *delimiter,
						int delim_len, t_minishell *s);
char				*read_single_heredoc_line(char *delimiter, int *should_exit,
						char **content, t_minishell *s);
int					process_heredoc_line_content(char **content, char *line,
						t_minishell *s, int expand);

// heredoc_support.c
int					should_expand_delimiter(char *delimiter);
void				add_file_to_command(t_cmd *current_cmd, t_file *node);
int					handle_heredoc_error(char *delimiter, t_shell_ctx *ctx);
t_file				*create_and_validate_heredoc_file(char *delimiter,
						char *content);
void				process_heredoc_token(t_cmd *current_cmd, char *token_value,
						t_shell_ctx *ctx, t_minishell *s);

// parse_handlers.c
void				handle_word_token(t_cmd *current_cmd, t_token *token,
						t_shell_ctx *ctx);
void				handle_pipe_token(t_cmd **commands, t_cmd **current_cmd,
						t_shell_ctx *ctx);
int					validate_initial_syntax(t_token *tokens, t_shell_ctx *ctx);

// parse_validation.c
int					validate_pipe_token(t_token *tokens, t_cmd *commands,
						t_cmd *current_cmd, t_shell_ctx *ctx);
int					validate_redirection_token(t_token *tokens, t_cmd *commands,
						t_cmd *current_cmd, t_shell_ctx *ctx);
int					validate_double_pipe(t_token *tokens, t_cmd *commands,
						t_cmd *current_cmd, t_shell_ctx *ctx);

// parse_utils.c
void				handle_heredoc(t_cmd *current_cmd, t_token **token,
						t_shell_ctx *ctx, t_minishell *s);
void				process_redirection_token(t_cmd *current_cmd,
						t_token **tokens, t_shell_ctx *ctx, t_minishell *s);
t_file				*create_t_file_node(char *str);

// quote_remover.c
void				remove_quotes_from_commands(t_cmd *commands);
char				*remove_quotes(char *str);

// heredoc_utils.c
char				*read_heredoc_content(char *delimiter, int *should_exit,
						t_minishell *s, int expand);
t_file				*create_heredoc_file(char *delimiter, char *content);

/* ************************************************************************** */
/*                             BUILTIN FUNCTIONS                              */
/* ************************************************************************** */

// builtins.c
int					is_builtin(t_cmd *cmd);
int					builtin_echo(t_minishell *s);
int					builtin_pwd(t_minishell *s);
int					builtin_env(t_minishell *s);
int					builtin_export(t_minishell **s);
int					builtin_cd(t_minishell *s);
int					builtin_unset(t_minishell **s);
int					builtin_exit(t_minishell *s);
int					execute_builtin(t_minishell **s);
int					export_with_error(char *arg);
int					is_valid_export_key(char *s);

/* ************************************************************************** */
/*                          ENVIRONMENT FUNCTIONS                            */
/* ************************************************************************** */

// env_utils.c
t_env				*create_env_node(char *key, char *value);
t_env				*init_env(char **envp);
char				*get_env_value(t_env *env, char *key);
void				set_env_value(t_minishell **s, char *key, char *value);
void				unset_env_value(t_minishell **s, char *key);
void				free_env(t_env *env);
void				free_minishell(t_minishell *s);
char				**env_to_tab(t_env *env);
void				free_env_tab(char **tab);

/* ************************************************************************** */
/*                             SIGNAL HANDLING                               */
/* ************************************************************************** */

// signals.c
void				setup_signals(void);
void				reset_signals(void);
void				handle_sigint(int sig);
void				handle_sigquit(int sig);
void				process_signals(void);

/* ************************************************************************** */
/*                           UTILITY FUNCTIONS                               */
/* ************************************************************************** */

// utils.c
char				**env_to_array(t_env *env);
void				free_array(char **array);
char				*find_executable(char *cmd, t_env *env);
int					count_commands(t_cmd *commands);
void				command_not_found(char *cmd);
void				print_tbl(char **tbl);
void				print_ll(t_file *ll);

/* ************************************************************************** */
/*                           EXECUTION FUNCTIONS                             */
/* ************************************************************************** */

// get_path.c
char				*get_path(char *cmd, t_env *env);

/* ************************************************************************** */
/*                            EXECUTORS FUNCTIONS                            */
/* ************************************************************************** */

// executors_redirections.c
int					handle_heredoc_execution(t_file *file);
int					handle_redir_in(t_file *f);
int					handle_redir_out(t_file *f);
int					handle_redirections(t_cmd *cmd);

// executors_utils.c
int					prepare_pipe(t_cmd *cmd, int *pipe_fd);
int					has_pipe_or_input(t_cmd *cmd, int prev_fd);
int					has_access(const char *path, int mode);
void				path_stat(char *path);

// executors.c
void				execute_commands(t_minishell **s);
void				exec_in_child(t_minishell **s, t_cmd *cmd, int *pipe_fd,
						int prev_fd);
void				wait_all_children(t_minishell **s, int prev_fd,
						int last_pid);
void				run_builtin(t_minishell **s);
void				run_in_fork(t_minishell **s, int *pipe_fd, int *prev_fd,
						int *last);

/* ************************************************************************** */
/*                             HELPERS FUNCTIONS                             */
/* ************************************************************************** */

// expand_helpers.c
int					is_only_spaces(char *str);
t_token				*remove_empty_tokens(t_token *tokens);

#endif
