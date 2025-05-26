/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   clean_input.c                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/05/26 22:23:37 by dibsejra          #+#    #+#             */
/*   Updated: 2025/05/26 22:28:49 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */


#include "minishell.h"

// Ajoute un espace si nécessaire avant/après les quotes
static void	add_space_if_needed(char *cleaned, int *j, char next_char, int closing)
{
	if (closing && next_char && next_char != ' ' && next_char != '\t')
		cleaned[(*j)++] = ' ';
	else if (!closing && *j > 0 && cleaned[*j - 1] != ' ')
		cleaned[(*j)++] = ' ';
}

// Gère l'ouverture/fermeture des guillemets simples et doubles
static int	handle_quotes(char *str, int *i, char *cleaned, int *j,
			int *in_squote, int *in_dquote)
{
	if (str[*i] == '\'' && !(*in_dquote))
	{
		add_space_if_needed(cleaned, j, str[*i + 1], 0);
		*in_squote = !(*in_squote);
		cleaned[(*j)++] = str[(*i)++];
		if (!(*in_squote))
			add_space_if_needed(cleaned, j, str[*i], 1);
		return (1);
	}
	else if (str[*i] == '"' && !(*in_squote))
	{
		add_space_if_needed(cleaned, j, str[*i + 1], 0);
		*in_dquote = !(*in_dquote);
		cleaned[(*j)++] = str[(*i)++];
		if (!(*in_dquote))
			add_space_if_needed(cleaned, j, str[*i], 1);
		return (1);
	}
	return (0);
}

// Gère la copie des espaces et tabulations hors quotes
static void	handle_spaces(char *str, int *i, char *cleaned, int *j,
			int in_squote, int in_dquote)
{
	if ((str[*i] == ' ' || str[*i] == '\t') && !in_squote && !in_dquote)
	{
		cleaned[(*j)++] = ' ';
		while (str[*i] && (str[*i] == ' ' || str[*i] == '\t'))
			(*i)++;
	}
	else
		cleaned[(*j)++] = str[(*i)++];
}

// Nettoie la chaîne en supprimant les espaces inutiles
char	*clean_input(char *str)
{
	int		i;
	int		j;
	int		in_squote;
	int		in_dquote;
	char	*cleaned;

	if (!str)
		return (NULL);
	cleaned = malloc(ft_strlen(str) * 2 + 1);
	if (!cleaned)
		return (NULL);
	i = 0;
	j = 0;
	in_squote = 0;
	in_dquote = 0;
	while (str[i] && (str[i] == ' ' || str[i] == '\t'))
		i++;
	while (str[i])
	{
		if (!handle_quotes(str, &i, cleaned, &j, &in_squote, &in_dquote))
			handle_spaces(str, &i, cleaned, &j, in_squote, in_dquote);
	}
	if (j > 0 && cleaned[j - 1] == ' ')
		j--;
	cleaned[j] = '\0';
	return (cleaned);
}