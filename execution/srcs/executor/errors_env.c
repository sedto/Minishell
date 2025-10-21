/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   errors_env.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/08/18 14:22:45 by dibsejra          #+#    #+#             */
/*   Updated: 2025/08/18 14:23:43 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

int	is_valid_export_key(char *s)
{
	int	i;

	if (!s || !s[0])
		return (0);
	if (!ft_isalpha(s[0]) && s[0] != '_')
		return (0);
	i = 1;
	while (s[i] && s[i] != '=')
	{
		if (!ft_isalnum(s[i]) && s[i] != '_')
			return (0);
		i++;
	}
	return (1);
}

int	export_with_error(char *arg)
{
	if (!is_valid_export_key(arg))
	{
		write(STDERR_FILENO, "minishell: export: `", 20);
		write(STDERR_FILENO, arg, ft_strlen(arg));
		write(STDERR_FILENO, "`: not a valid identifier\n", 26);
		return (1);
	}
	return (0);
}
