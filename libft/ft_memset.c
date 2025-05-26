/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_memset.c                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/10/03 13:34:15 by dibsejra          #+#    #+#             */
/*   Updated: 2024/10/14 18:49:16 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "libft.h"

// C'est une manière simple et rapide de remplir 
// une zone mémoire avec une valeur donnée
// Généralement utilisée pour l'initialisation
void	*ft_memset(void *b, int c, size_t len)
{
	size_t			i;
	unsigned char	*ptr;

	i = 0;
	ptr = (unsigned char *) b;
	while (i < len)
	{
		ptr[i] = (unsigned char) c;
		i++;
	}
	return (b);
}

/*int	main(void)
{
	int c = 68;
	char str[] = "Texte";
	char *ptr = str;

	printf("Exemple:%s\n", str);
	printf("Exemple apres:%s\n", (char*) ft_memset(ptr, c, 3));
}*/