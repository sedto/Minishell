/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_memchr.c                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/10/06 15:56:29 by dibsejra          #+#    #+#             */
/*   Updated: 2024/10/14 18:48:23 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "libft.h"

// ft_memchr est utilisée pour rechercher une occurrence d'un caractère (c) 
// dans un bloc de mémoire (s) sur une certaine longueur (n).
// Elle retourne un pointeur vers la première occurrence trouvée
// ou NULL si le caractère n'est pas présent.
void	*ft_memchr(const void *s, int c, size_t n)
{
	unsigned char	*s1;
	size_t			i;

	s1 = (unsigned char *) s;
	i = 0;
	while (i < n)
	{
		if (s1[i] == (unsigned char) c)
		{
			return ((void *) &s1[i]);
		}
		i++;
	}
	return (NULL);
}
