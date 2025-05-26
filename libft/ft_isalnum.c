/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_isalnum.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/10/03 13:20:33 by dibsejra          #+#    #+#             */
/*   Updated: 2024/10/13 18:12:24 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "libft.h"

// Vérifie si c'est alphanumérique entre 0 > 9 et a > z et A > Z
int	ft_isalnum(int c)
{
	if ((c >= 65 && c <= 90) || (c >= 97 && c <= 122) || (c >= 48 && c <= 57))
	{
		return (1);
	}
	return (0);
}

/*#include <stdio.h>

int	main (void)
{
	printf("Valeur:%d\n", ft_isalnum(78));
	printf("Valeur:%d\n", ft_isalnum(58));
}*/