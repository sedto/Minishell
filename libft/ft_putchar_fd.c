/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_putchar_fd.c                                    :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/10/07 23:32:58 by dibsejra          #+#    #+#             */
/*   Updated: 2024/10/14 18:49:03 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "libft.h"

// ecris des lettres dans des endroits variés, comme l'écran ou un fichier
void	ft_putchar_fd(char c, int fd)
{
	write(fd, &c, 1);
}
