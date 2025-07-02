#include "minishell.h"


int	is_valid_export_key(char *s)
{
	int	i;

	if (!s || !s[0])
		return (0);
	if (!ft_isalpha(s[0]) && s[0] != '_')
		return (0);
	i = 1;
	while (s[i] && s[i] != '=')
	{
		if (!ft_isalnum(s[i]) && s[i] != '_')
			return (0);
		i++;
	}
	return (1);
}


int	export_with_error(char *arg)
{
	if (!is_valid_export_key(arg))
	{
		fprintf(stderr, "minishell: export: `%s`: not a valid identifier\n", arg);
		return (1);
	}
	return (0);
}
