/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   clean_input.c                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/05/26 22:23:37 by dibsejra          #+#    #+#             */
/*   Updated: 2025/06/11 17:27:46 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minishell.h"

// Traite un caractère dans la chaîne d'entrée
static void	process_char(char *str, char *cleaned, int *i, int *j)
{
	static int	in_single_quote = 0;
	static int	in_double_quote = 0;

	if (str[*i] == '\'' && !in_double_quote)
	{
		in_single_quote = !in_single_quote;
		cleaned[(*j)++] = str[(*i)++];
	}
	else if (str[*i] == '"' && !in_single_quote)
	{
		in_double_quote = !in_double_quote;
		cleaned[(*j)++] = str[(*i)++];
	}
	else if ((str[*i] == ' ' || str[*i] == '\t')
		&& !in_single_quote && !in_double_quote)
	{
		cleaned[(*j)++] = ' ';
		while (str[*i] && (str[*i] == ' ' || str[*i] == '\t'))
			(*i)++;
	}
	else
		cleaned[(*j)++] = str[(*i)++];
}

// Version simplifiée qui préserve mieux les quotes
char	*clean_input(char *str)
{
	char	*cleaned;
	int		i;
	int		j;

	if (!str)
		return (NULL);
	cleaned = malloc(ft_strlen(str) * 2 + 1);
	if (!cleaned)
		return (NULL);
	i = 0;
	j = 0;
	while (str[i] && (str[i] == ' ' || str[i] == '\t'))
		i++;
	while (str[i])
		process_char(str, cleaned, &i, &j);
	if (j > 0 && cleaned[j - 1] == ' ')
		j--;
	cleaned[j] = '\0';
	return (cleaned);
}
