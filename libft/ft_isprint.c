/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_isprint.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/10/02 17:52:24 by dibsejra          #+#    #+#             */
/*   Updated: 2024/10/14 18:47:45 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "libft.h"

// Vérifie si c'est une lettre un chiffre 
// Ou un signe de ponctuation ainsi que l'espace
int	ft_isprint(int c)
{
	if (c >= 32 && c <= 126)
	{
		return (1);
	}
	return (0);
}

/*#include <stdio.h>
#include <ctype.h>

int	main(void)
{
	printf("Valeur:%d\n", ft_isprint(38));
	printf("Valeur:%d\n", isprint(38));
}*/