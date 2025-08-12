/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   builtins.c                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/21 10:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/12 21:06:45 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../libft/libft.h"
#include "minishell.h"

int	builtin_cd(t_minishell *s)
{
	t_cmd	*cmd;
	char	*target;

	cmd = s->commands;
	if (cmd->args[1] && cmd->args[2])
	{
		write(STDERR_FILENO, "cd: too many arguments\n", 24);
		return (1);
	}
	if (!cmd->args[1])
	{
		target = get_env_value(s->env, "HOME");
		if (!target)
			write(STDERR_FILENO, "cd: HOME not set\n", 17);
		if (!target)
			return (1);
	}
	else
		target = cmd->args[1];
	if (chdir(target) != 0)
	{
		perror("cd");
		return (1);
	}
	return (0);
}

int	builtin_pwd(t_minishell *s)
{
	char	*cwd;

	(void)s;
	cwd = getcwd(NULL, 0);
	if (!cwd)
	{
		perror("pwd");
		return (1);
	}
	printf("%s\n", cwd);
	free(cwd);
	return (0);
}

int	builtin_echo(t_minishell *s)
{
	int		i;
	int		newline;
	char	**args;

	args = s->commands->args;
	newline = 1;
	i = 1;
	if (args[1] && ft_strncmp(args[1], "-n", 2) == 0 && ft_strlen(args[1]) == 2)
	{
		newline = 0;
		i = 2;
	}
	while (args[i])
	{
		write(1, args[i], ft_strlen(args[i]));
		if (args[i + 1])
			write(1, " ", 1);
		i++;
	}
	if (newline)
		write(1, "\n", 1);
	return (0);
}

int	builtin_env(t_minishell *s)
{
	t_env	*env;

	env = s->env;
	while (env)
	{
		printf("%s=%s\n", env->key, env->value);
		env = env->next;
	}
	return (0);
}

static int	render_export(t_minishell **s)
{
	t_env	*current;

	current = (*s)->env;
	while (current)
	{
		printf("declare -x %s=\"%s\"\n", current->key, current->value);
		current = current->next;
	}
	return (0);
}

static void	set_env_from_command(t_minishell **s, int i, char *equal_pos)
{
	char	*key;
	char	*value;

	key = ft_substr((*s)->commands->args[i], 0, equal_pos
			- (*s)->commands->args[i]);
	value = ft_strdup(equal_pos + 1);
	if (key && value)
		set_env_value(s, key, value);
	free(key);
	free(value);
}

int	builtin_export(t_minishell **s)
{
	char	*equal_pos;
	int		i;

	if (!(*s)->commands->args[1])
		return (render_export(s));
	(*s)->exit_status = 0;
	i = 1;
	while ((*s)->commands->args[i])
	{
		if (export_with_error((*s)->commands->args[i]))
		{
			(*s)->exit_status = 1;
			i++;
			continue ;
		}
		equal_pos = ft_strchr((*s)->commands->args[i], '=');
		if (equal_pos)
			set_env_from_command(s, i, equal_pos);
		else
			set_env_value(s, (*s)->commands->args[i], "");
		i++;
	}
	return ((*s)->exit_status);
}

int	builtin_unset(t_minishell **s)
{
	int		i;
	char	**args;

	args = (*s)->commands->args;
	if (!args[1])
		return (0);
	i = 1;
	while (args[i])
	{
		unset_env_value(s, args[i]);
		i++;
	}
	return (0);
}

static int	is_str_num(char *str)
{
	int	i;

	i = 0;
	if (!str || !str[0])
		return (1);
	if (str[i] == '-' || str[i] == '+')
		i++;
	if (!str[i])
		return (1);
	while (str[i])
	{
		if (str[i] < '0' || str[i] > '9')
			return (1);
		i++;
	}
	return (0);
}

int	builtin_exit(t_minishell *s)
{
	int		exit_code;
	char	**args;

	args = s->commands->args;
	printf("exit\n");
	if (!args[1])
		exit(0);
	if (is_str_num(args[1]))
	{
		write(STDERR_FILENO, "minishell: exit: ", 17);
		write(STDERR_FILENO, args[1], ft_strlen(args[1]));
		write(STDERR_FILENO, ": numeric argument required\n", 28);
		exit(2);
	}
	if (args[2])
	{
		write(STDERR_FILENO, "minishell: exit: too many arguments\n", 37);
		return (1);
	}
	exit_code = ft_atoi(args[1]);
	exit(exit_code);
}
/* Exécute un builtin */

int	execute_builtin(t_minishell **s)
{
	t_cmd	*cmd;

	cmd = (*s)->commands;
	if (!cmd || !cmd->args || !cmd->args[0])
		return (1);
	if (ft_strncmp(cmd->args[0], "exit", 5) == 0)
		(*s)->exit_status = builtin_exit(*s);
	else if (ft_strncmp(cmd->args[0], "cd", 3) == 0)
		(*s)->exit_status = builtin_cd(*s);
	else if (ft_strncmp(cmd->args[0], "echo", 5) == 0)
		(*s)->exit_status = builtin_echo(*s);
	else if (ft_strncmp(cmd->args[0], "pwd", 4) == 0)
		(*s)->exit_status = builtin_pwd(*s);
	else if (ft_strncmp(cmd->args[0], "env", 4) == 0)
		(*s)->exit_status = builtin_env(*s);
	else if (ft_strncmp(cmd->args[0], "export", 7) == 0)
		(*s)->exit_status = builtin_export(s);
	else if (ft_strncmp(cmd->args[0], "unset", 6) == 0)
		(*s)->exit_status = builtin_unset(s);
	else
		(*s)->exit_status = 1;
	return ((*s)->exit_status);
}
