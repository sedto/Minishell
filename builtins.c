/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   builtins.c                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/06/21 10:00:00 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/21 01:55:12 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../libft/libft.h"
#include "parsing/includes/minishell.h"

/* Builtin: pwd - affiche le répertoire courant */
int	builtin_pwd(void)
{
	char	*cwd;

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
int	builtin_echo(char **args)
{
	int	i;
	int	newline;

	if (!args[1])
	{
		printf("\n");
		return (0);
	}
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
int	builtin_env(t_env *env)
{
	while (env)
	{
		printf("%s=%s\n", env->key, env->value);
		env = env->next;
	}
	return (0);
}

/* Builtin: export - exporte des variables */
int	builtin_export(char **args, t_env **env)
{
	char	*equal_pos;
	int		i;

	if (!args[1])
	{
		/* Afficher toutes les variables exportées */
		t_env *current = *env;
		while (current)
		{
			printf("declare -x %s=\"%s\"\n", current->key, current->value);
			current = current->next;
		}
		return (0);
	}
	i = 1;
	while (args[i])
	{
		equal_pos = ft_strchr(args[i], '=');
		if (equal_pos)
		{
			*equal_pos = '\0';
			set_env_value(env, args[i], equal_pos + 1);
			*equal_pos = '=';
		}
		else
		{
			/* Variable sans valeur - juste l'exporter si elle existe */
			char *value = get_env_value(*env, args[i]);
			if (value)
				set_env_value(env, args[i], value);
			else
				set_env_value(env, args[i], "");
		}
		i++;
	}
	return (0);
}

/* Builtin: unset - supprime des variables */
int	builtin_unset(char **args, t_env **env)
{
	int	i;

	if (!args[1])
		return (0);
	i = 1;
	while (args[i])
	{
		unset_env_value(env, args[i]);
		i++;
	}
	return (0);
}

/* Builtin: exit - quitte le shell */
int	builtin_exit(char **args)
{
	int	exit_code;

	printf("exit\n");
	if (!args[1])
		exit(0);
	exit_code = ft_atoi(args[1]);
	exit(exit_code);
}

/* Vérifie si une commande est un builtin */
int	is_builtin(char *cmd)
{
	if (ft_strncmp(cmd, "echo", 4) == 0 && ft_strlen(cmd) == 4)
		return (1);
	if (ft_strncmp(cmd, "cd", 2) == 0 && ft_strlen(cmd) == 2)
		return (1);
	if (ft_strncmp(cmd, "pwd", 3) == 0 && ft_strlen(cmd) == 3)
		return (1);
	if (ft_strncmp(cmd, "export", 6) == 0 && ft_strlen(cmd) == 6)
		return (1);
	if (ft_strncmp(cmd, "unset", 5) == 0 && ft_strlen(cmd) == 5)
		return (1);
	if (ft_strncmp(cmd, "env", 3) == 0 && ft_strlen(cmd) == 3)
		return (1);
	if (ft_strncmp(cmd, "exit", 4) == 0 && ft_strlen(cmd) == 4)
		return (1);
	return (0);
}

/* Exécute un builtin */
int	execute_builtin(char **args, t_env **env)
{
	if (ft_strncmp(args[0], "echo", 4) == 0)
		return (builtin_echo(args));
	if (ft_strncmp(args[0], "pwd", 3) == 0)
		return (builtin_pwd());
	if (ft_strncmp(args[0], "env", 3) == 0)
		return (builtin_env(*env));
	if (ft_strncmp(args[0], "export", 6) == 0)
		return (builtin_export(args, env));
	if (ft_strncmp(args[0], "unset", 5) == 0)
		return (builtin_unset(args, env));
	if (ft_strncmp(args[0], "exit", 4) == 0)
		return (builtin_exit(args));
	/* cd sera implémenté par l'exécuteur (besoin de changer PWD) */
	return (1);
}
