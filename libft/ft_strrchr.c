/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_strrchr.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/10/06 14:55:56 by dibsejra          #+#    #+#             */
/*   Updated: 2024/10/14 18:37:21 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "libft.h"

// Trouve le dernière occurence d'un caractère dans une chaine de caractère.
char	*ft_strrchr(const char *s, int c)
{
	unsigned int	i;
	char			*occ;

	occ = NULL;
	i = 0;
	while (s[i])
	{
		if (s[i] == (char) c)
		{
			occ = (char *) &s[i];
		}
		i++;
	}
	if (s[i] == (char) c)
	{
		occ = (char *) &s[i];
	}
	return (occ);
}
