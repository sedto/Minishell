/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   first_clean.c                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/05/20 15:56:08 by dibsejra          #+#    #+#             */
/*   Updated: 2025/05/20 15:56:25 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <readline/readline.h>
#include <readline/history.h>

// A supprimer quand on ajoutera libft
static size_t	ft_strlen(const char *s)
{
	size_t	i;

	i = 0;
	while (s && s[i])
		i++;
	return (i);
}

// Gère l'ouverture/fermeture des guillemets simples et doubles
// Met à jour les indicateurs de quote et copie le caractère dans cleaned
static int	handle_quotes(char *str, int *i, char *cleaned, int *j,
			int *in_squote, int *in_dquote)
{
	if (str[*i] == '\'' && !(*in_dquote))
	{
		*in_squote = !(*in_squote);
		cleaned[(*j)++] = str[(*i)++];
		return (1);
	}
	else if (str[*i] == '"' && !(*in_squote))
	{
		*in_dquote = !(*in_dquote);
		cleaned[(*j)++] = str[(*i)++];
		return (1);
	}
	return (0);
}

// Gère la copie des espaces et tabulations hors quotes
// Réduit les espaces/tabs consécutifs à un seul espace
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

// Initialise les variables et alloue la mémoire pour la chaîne nettoyée
static char	*init_clean(char *str, int *i, int *j, int *sq, int *dq)
{
	char	*cleaned;

	*i = 0;
	*j = 0;
	*sq = 0;
	*dq = 0;
	if (!str)
		return (NULL);
	cleaned = malloc(ft_strlen(str) + 1);
	if (!cleaned)
		return (NULL);
	while (str[*i] && (str[*i] == ' ' || str[*i] == '\t'))
		(*i)++;
	return (cleaned);
}

// Nettoie la chaîne en supprimant les espaces inutiles
// et en respectant les ' ' simples et " "
char	*clean(char *str)
{
	int		i;
	int		j;
	int		in_squote;
	int		in_dquote;
	char	*cleaned;

	cleaned = init_clean(str, &i, &j, &in_squote, &in_dquote);
	if (!cleaned)
		return (NULL);
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

// Lit une entrée utilisateur avec readline, applique le nettoyage et affiche le résultat
int	main(void)
{
	char	*input;
	char	*cleaned_input;
	
	// Utiliser readline au lieu de read
	input = readline("Entrez une chaîne à nettoyer: ");
	
	// Vérifier si readline a retourné NULL (Ctrl+D ou erreur)
	if (!input)
		return (1);
	
	// Nettoyer l'input et afficher le résultat
	cleaned_input = clean(input);
	printf("Original: %s\n", input);
	printf("Cleaned : %s\n", cleaned_input);
	
	// Libérer la mémoire
	free(cleaned_input);
	free(input);  // Important: readline alloue de la mémoire qu'il faut libérer
	
	return (0);
}
