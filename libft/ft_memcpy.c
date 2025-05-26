/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_memcpy.c                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/10/03 16:51:10 by dibsejra          #+#    #+#             */
/*   Updated: 2024/10/14 18:47:18 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "libft.h"

// La fonction ft_memcpy copie n octets depuis 
// un bloc de mémoire source (src) vers un bloc de mémoire destination (dest).
// Elle retourne un pointeur vers la destination.
void	*ft_memcpy(void *dst, const void *src, size_t n)
{
	size_t				i;
	unsigned char		*dest;
	const unsigned char	*src_ptr;

	i = 0;
	if (dst == NULL && src == NULL)
	{
		return (NULL);
	}
	dest = (unsigned char *) dst;
	src_ptr = (const unsigned char *) src;
	while (i < n)
	{
		dest[i] = src_ptr[i];
		i++;
	}
	return (dst);
}
/*int	main(void)
{
	char src[] = "Hello, World!";
	char dest[20];
	
	ft_memcpy(dest, src, strlen(src) + 1);

	printf("Source: %s\n", src);
	printf("Destination: %s\n", dest);

	int src_int[] = {1, 2, 3, 4, 5};
	int dest_int[5];
	int i = 0;

	ft_memcpy(dest_int, src_int, 5 * sizeof(int));
	printf("Tableau source: ");
	while (i < 5)
	{
		printf("%d ", src_int[i]);
		i++;
	}
	printf("\n");
	i = 0;
	printf("Tableau destination: ");
	while (i < 5)
	{
		printf("%d ", dest_int[i]);
		i++;
	}
	printf("\n");
	return (0);
}*/