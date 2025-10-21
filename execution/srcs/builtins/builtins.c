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

static char	*get_cd_target(t_minishell *s)
{
	char	*target;

	if (!s->commands->args[1])
	{
		target = get_env_value(s->env, "HOME");
		if (!target)
		{
			write(STDERR_FILENO, "cd: HOME not set\n", 17);
			return (NULL);
		}
		return (target);
	}
	return (s->commands->args[1]);
}

static void	update_pwd_vars(t_minishell *s, char *old_pwd)
{
	char	*new_pwd;

	new_pwd = getcwd(NULL, 0);
	if (old_pwd)
		set_env_value(&s, "OLDPWD", old_pwd);
	if (new_pwd)
		set_env_value(&s, "PWD", new_pwd);
	free(new_pwd);
}

int	builtin_cd(t_minishell *s)
{
	t_cmd	*cmd;
	char	*target;
	char	*old_pwd;

	cmd = s->commands;
	if (cmd->args[1] && cmd->args[2])
	{
		write(STDERR_FILENO, "minishell: cd: too many arguments\n", 34);
		return (1);
	}
	target = get_cd_target(s);
	if (!target)
		return (1);
	old_pwd = getcwd(NULL, 0);
	if (chdir(target) != 0)
	{
		perror("cd");
		free(old_pwd);
		return (1);
	}
	update_pwd_vars(s, old_pwd);
	free(old_pwd);
	return (0);
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
