/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_memmove.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/10/04 13:05:11 by dibsejra          #+#    #+#             */
/*   Updated: 2024/10/14 18:50:10 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "libft.h"

// ft_memmove copie des octets d'une zone mémoire vers une autre,
// en gérant correctement les cas où les zones se chevauchent
// Pour éviter d'écraser des données non copiées.
void	*ft_memmove(void *dst, const void *src, size_t len)
{
	unsigned char	*dest1;
	unsigned char	*src1;
	size_t			i;

	dest1 = (unsigned char *)dst;
	src1 = (unsigned char *)src;
	i = 0;
	if (dst == NULL && src == NULL)
		return (NULL);
	if (dst > src)
	{
		while (len-- > 0)
			dest1[len] = src1[len];
	}
	else
	{
		while (i < len)
		{
			dest1[i] = src1[i];
			i++;
		}
	}
	return (dst);
}

/*int	main(void)
{
	char str[] = "Hello, World!";

	// Test avec chevauchement
	ft_memmove(str + 6, str, 5);
	printf("Après ft_memmove avec chevauchement: %s\n", str);

	// Test sans chevauchement
	char src[] = "Salut!";
	char dest[20];
	ft_memmove(dest, src, strlen(src) + 1);
	printf("Destination après ft_memmove sans chevauchement: %s\n", dest);

	return (0);
}*/