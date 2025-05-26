/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_strjoin.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/10/07 23:12:41 by dibsejra          #+#    #+#             */
/*   Updated: 2024/10/14 18:22:22 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "libft.h"

// Concaténer deux chaines de caractères dans la mémoire.
char	*ft_strjoin(char const *s1, char const *s2)
{
	int		i;
	int		j;
	char	*tab;

	i = 0;
	j = 0;
	tab = ft_calloc((ft_strlen(s1) + ft_strlen(s2) + 1), sizeof(char));
	if (!tab)
	{
		return (NULL);
	}
	while (s1[i] != '\0')
	{
		tab[j++] = s1[i++];
	}
	i = 0;
	while (s2[i])
	{
		tab[j++] = s2[i++];
	}
	return (tab);
}
