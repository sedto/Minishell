/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   builtins_exit.c                                    :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/08/18 14:20:45 by dibsejra          #+#    #+#             */
/*   Updated: 2025/08/18 14:24:25 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "../../../libft/libft.h"
#include "minishell.h"

static int	is_str_num(char *str)
{
	int	i;

	i = 0;
	if (str[i] == '-' || str[i] == '+')
		i++;
	while (str[i])
	{
		if (str[i] < '0' || str[i] > '9')
			return (1);
		i++;
	}
	return (0);
}

/* Builtin: exit - quitte le shell */
int	builtin_exit(t_minishell *s)
{
	int		exit_code;
	char	**args;

	args = s->commands->args;
	if (!args[1])
		shell_exit(0, s);
	if (is_str_num(args[1]))
	{
		write(STDERR_FILENO, "minishell: exit: ", 17);
		write(STDERR_FILENO, args[1], ft_strlen(args[1]));
		write(STDERR_FILENO, ": numeric argument required\n", 28);
		shell_exit(2, s);
	}
	if (args[2])
	{
		write(STDERR_FILENO, "minishell: exit: too many arguments\n", 36);
		return (1);
	}
	exit_code = ft_atoi(args[1]);
	shell_exit(exit_code, s);
	return (0);
}
