---
applyTo: "**"
---
# Minishell Project Guidelines
Apply the [general coding instructions] from minishell.instructions.md to all requests.

## Target public
I am a C programmer working on the 42 Minishell project. I need to understand Unix system programming fundamentals: processes, file descriptors, signals, and shell internals.

## Main instruction repeated
I repeat: Show me concrete examples and working code snippets to illustrate concepts. When explaining system calls or shell behavior, demonstrate with actual code that I can test. If something doesn't work, provide the corrected code immediately with a brief explanation of what was wrong.

## Coding style: 42 Norm
When providing C code for Minishell, you MUST enforce these rules:
- **C99 standard**: compile with `gcc -Wall -Wextra -Werror`
- **42 Norm compliance**: max 25 lines per function, max 80 chars per line, no more than 5 functions per file
- **Allowed functions only**: Use ONLY the functions listed in the subject (readline, fork, execve, pipe, dup2, etc.)
- **Single global variable**: Only one global variable allowed (for signal handling)
- **Memory management**: Every malloc() needs a corresponding free(). No memory leaks tolerated
- **Error handling**: Check return values of ALL system calls

## Project-specific requirements
- **Shell behavior**: When in doubt about expected behavior, reference bash as the standard
- **Process management**: Explain fork/exec patterns with concrete examples
- **File descriptor manipulation**: Show actual dup2/pipe usage, not just theory  
- **Signal handling**: Demonstrate signal setup with sigaction, not just signal()
- **Parsing strategy**: Show tokenization and AST building with real input examples
- **Built-ins vs external commands**: Clearly distinguish when to exec vs handle internally

## Key concepts to always explain with examples
- **Tokenization**: Show how `echo "hello world" | wc -l` becomes tokens
- **Redirection mechanics**: Demonstrate file descriptor manipulation step-by-step
- **Pipeline creation**: Show the fork/pipe/dup2 dance with actual code
- **Environment variables**: Show expansion of `$HOME` and `$?` in practice
- **Quote handling**: Demonstrate difference between `'$HOME'` and `"$HOME"`

## Testing approach
- Provide test commands I can run immediately: `echo "test" | cat > file.txt`
- Show edge cases: `cat << EOF`, `export VAR=""`, `cd ""`
- Compare output with bash: `bash -c 'command'` vs `./minishell`

## When providing code
1. Start with a minimal working example
2. Show the exact compilation command
3. Include error handling from the beginning
4. Explain WHY each system call is needed, not just WHAT it does
5. Point out common pitfalls (zombie processes, fd leaks, etc.)