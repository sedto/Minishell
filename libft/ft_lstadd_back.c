/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_lstadd_back.c                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/10/09 21:27:19 by dibsejra          #+#    #+#             */
/*   Updated: 2024/10/15 15:18:57 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "libft.h"

// Ajoute un nouvel element a la fin de la liste
void	ft_lstadd_back(t_list **lst, t_list *new_element)
{
	t_list	*last_element;

	if (lst == NULL || new_element == NULL)
		return ;
	if (*lst == NULL)
		*lst = new_element;
	else
	{
		last_element = ft_lstlast(*lst);
		last_element->next = new_element;
	}
}
