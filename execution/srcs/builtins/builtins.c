/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   builtins.c                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: ciso <ciso@student.42.fr>                  +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/21 10:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/07/02 16:50:44 by ciso             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../libft/libft.h"
#include "minishell.h"

//marche pas
/*int	builtin_cd(t_minishell *s)
{
	t_cmd	*cmd;

	cmd = s->commands;
	if (!cmd->args[1])
		return (perror("cd"), 1);
	if (chdir(cmd->args[1]) != 0)
		return (perror("cd"), 1);
	return (0);
}*/
int	builtin_cd(t_minishell *s)
{
	t_cmd	*cmd;
	char	*target;

	cmd = s->commands;
	if (!cmd->args[1])
	{
		target = get_env_value(s->env, "HOME");
		if (!target)
		{
			fprintf(stderr, "cd: HOME not set\n");
			return (1);
		}
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

/* Builtin: pwd - affiche le répertoire courant */
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

/* Builtin: echo - affiche les arguments */
int	builtin_echo(t_minishell *s)
{
	int	i;
	int	newline;
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
		printf("%s", args[i]);
		if (args[i + 1])
			printf(" ");
		i++;
	}
	if (newline)
		printf("\n");
	return (0);
}

/* Builtin: env - affiche l'environnement */
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

/* Builtin: export - exporte des variables */
//TODO check avec s->env
//marche pas
int	builtin_export(t_minishell **s)
{
	char	*equal_pos;
	char	*key;
	char	*value;
	int		i;
	t_env	*current;

	if (!(*s)->commands->args[1])
	{
		current = (*s)->env;
		while (current)
		{
			printf("declare -x %s=\"%s\"\n", current->key, current->value);
			current = current->next;
		}
		return (0);
	}
	
	i = 1;
	while ((*s)->commands->args[i])
	{
		equal_pos = ft_strchr((*s)->commands->args[i], '=');
		if (equal_pos)
		{
			/* Extraire key et value sans modifier args[i] */
			key = ft_substr((*s)->commands->args[i], 0, equal_pos - (*s)->commands->args[i]);
			value = ft_strdup(equal_pos + 1);
			if (key && value)
			{
				set_env_value(s, key, value);
				free(key);
				free(value);
			}
			else
			{
				free(key);
				free(value);
			}
		}
		else
		{
			char *existing = get_env_value((*s)->env, (*s)->commands->args[i]);
			if (existing)
				set_env_value(s, (*s)->commands->args[i], existing);
			else
				set_env_value(s, (*s)->commands->args[i], "");
		}
		i++;
	}
	return (0);
}

/* Builtin: unset - supprime des variables */
//marche pas
int	builtin_unset(t_minishell **s)
{
	int	i;
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

/* Builtin: exit - quitte le shell */
int	builtin_exit(t_minishell *s)
{
	int	exit_code;
	char	**args;

	args = s->commands->args;
	printf("exit\n");
	if (!args[1])
		exit(0);
	exit_code = ft_atoi(args[1]);
	exit(exit_code);
}
/* Exécute un builtin */

int execute_builtin(t_minishell **s) //plan de fonction pour les commandes builtin
{
    t_cmd *cmd;

    cmd = (*s)->commands;
    if (!cmd || !cmd->args || !cmd->args[0])
        return (1);
    if (ft_strncmp(cmd->args[0], "exit", 4) == 0)
    	return (builtin_exit(*s));
    if (ft_strncmp(cmd->args[0], "cd", 2) == 0)
        return (builtin_cd(*s));
    if (ft_strncmp(cmd->args[0], "echo", 4) == 0)
        return (builtin_echo(*s));
    if (ft_strncmp(cmd->args[0], "pwd", 3) == 0)
        return (builtin_pwd(*s));
    if (ft_strncmp(cmd->args[0], "env", 3) == 0)
        return (builtin_env(*s));
    if (ft_strncmp(cmd->args[0], "export", 6) == 0)
        return (builtin_export(s));
    if (ft_strncmp(cmd->args[0], "unset", 5) == 0)
        return (builtin_unset(s));
    return (1);
}

