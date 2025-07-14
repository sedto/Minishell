#!/bin/bash

echo "Testing bash:"
echo hi >./minishell_tester/test_files/invalid_permission >./minishell_tester/outfiles/outfile01 | echo bye
echo "Bash exit code: $?"

echo
echo "Testing minishell:"
./minishell -c "echo hi >./minishell_tester/test_files/invalid_permission >./minishell_tester/outfiles/outfile01 | echo bye"
echo "Minishell exit code: $?"