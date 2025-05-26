/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_isascii.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/10/01 16:59:15 by dibsejra          #+#    #+#             */
/*   Updated: 2024/10/13 18:13:12 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "libft.h"

// Vérifie si c'est un charactère dans la table ASCII
int	ft_isascii(int c)
{
	if (c >= 0 && c <= 127)
	{
		return (1);
	}
	return (0);
}

/*#include <stdio.h>
#include <ctype.h>
int	main (void)
{
	printf("Valeur: %d\n", ft_isascii(612));
	printf("Valeur: %d\n", isascii(612));
}*/