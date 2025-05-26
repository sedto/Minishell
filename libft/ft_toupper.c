/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_toupper.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/10/03 10:42:20 by dibsejra          #+#    #+#             */
/*   Updated: 2024/10/14 18:38:42 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "libft.h"

// Mets le caractère en majuscule
int	ft_toupper(int c)
{
	if (c >= 'a' && c <= 'z')
	{
		return (c - 32);
	}
	return (c);
}

/*#include <stdio.h>
int	main(void)
{
	printf("Valeur:%d\n", ft_toupper(98));
	printf("Valeur:%d\n", ft_toupper(66));
}*/