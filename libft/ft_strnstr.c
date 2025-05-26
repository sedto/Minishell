/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_strnstr.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/10/06 16:28:39 by dibsejra          #+#    #+#             */
/*   Updated: 2024/10/14 18:45:48 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "libft.h"

// Trouver une sous chaine dans une chaine en limitant la longeur
// pour plus de securite et controle.
char	*ft_strnstr(const char *haystack, const char *needle, size_t len)
{
	size_t	i;
	size_t	j;

	i = 0;
	j = 0;
	if (needle[0] == '\0')
	{
		return ((char *) haystack);
	}
	while (haystack[i] != '\0' && i < len)
	{
		j = 0;
		while (haystack [i + j] == needle[j]
			&& haystack [i + j] && (i + j) < len)
		{
			j++;
			if (needle[j] == '\0')
			{
				return ((char *) &haystack[i]);
			}
		}
		i++;
	}
	return (0);
}
