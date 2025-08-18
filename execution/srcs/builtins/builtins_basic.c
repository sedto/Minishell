/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   builtins_basic.c                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/08/18 14:20:41 by dibsejra          #+#    #+#             */
/*   Updated: 2025/08/18 14:24:23 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../libft/libft.h"
#include "minishell.h"

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
