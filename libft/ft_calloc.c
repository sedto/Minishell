/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_calloc.c                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/10/06 16:45:29 by dibsejra          #+#    #+#             */
/*   Updated: 2024/10/13 18:01:33 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "libft.h"

// Alloue la mémoire et initialise chaque octect à 0
// Dans son fonctionnement contient bzero
void	*ft_calloc(size_t count, size_t size)
{
	void			*ptr;
	size_t			i;
	unsigned char	*char_ptr;

	ptr = malloc(count * size);
	if (!ptr)
	{
		return (NULL);
	}
	char_ptr = (unsigned char *) ptr;
	i = 0;
	while (i < count * size)
	{
		char_ptr[i] = 0;
		i++;
	}
	return (ptr);
}
