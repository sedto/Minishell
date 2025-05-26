/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ft_lstadd_front.c                                  :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/10/09 21:25:37 by dibsejra          #+#    #+#             */
/*   Updated: 2024/10/15 15:24:36 by dibsejra         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "libft.h"

// Ajoute un nouvel emplacement en debut de liste en modifiant lancien(addresse)
void	ft_lstadd_front(t_list **lst, t_list *new_element)
{
	if (lst == NULL || new_element == NULL)
		return ;
	new_element->next = *lst;
	*lst = new_element;
}
