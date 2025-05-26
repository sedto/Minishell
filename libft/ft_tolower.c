/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_tolower.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/10/03 10:44:42 by dibsejra          #+#    #+#             */
/*   Updated: 2024/10/14 18:38:31 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "libft.h"

// Mets le caractère en minuscule
int	ft_tolower(int c)
{
	if (c >= 'A' && c <= 'Z')
	{
		return (c + 32);
	}
	return (c);
}

/*#include <stdio.h>
int	main(void)
{
	printf("Valeur:%d\n", ft_toupper(98));
	printf("Valeur:%d\n", ft_toupper(66));
}*/