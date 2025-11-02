# Minishell - As Beautiful as a Shell

A minimal recreation of Bash, implementing core shell features including parsing, execution, pipes, redirections, and built-in commands. This project is part of the 42 School curriculum and represents one of the most challenging system programming projects.

**Team**: sedto (parsing) & ciso (execution)
**Lines of Code**: ~4000
**Duration**: May 2025 - August 2025

## Table of Contents
- [About](#about)
- [Features](#features)
- [Architecture Overview](#architecture-overview)
- [Parsing Pipeline (sedto)](#parsing-pipeline-sedto)
- [Execution Engine (ciso)](#execution-engine-ciso)
- [Project Structure](#project-structure)
- [Compilation & Usage](#compilation--usage)
- [What I Learned](#what-i-learned)
- [Challenges Faced](#challenges-faced)
- [Testing](#testing)

## About

Minishell is a simplified shell that mimics Bash behavior. It reads user input, parses commands, expands variables, handles redirections, manages pipes, and executes both built-in and external commands. The project requires deep understanding of:

- **Process management** (fork, execve, wait, signals)
- **File descriptors** (pipes, redirections, dup2)
- **String parsing** (lexing, tokenization, expansion)
- **Memory management** (no leaks allowed)
- **Signal handling** (Ctrl-C, Ctrl-D, Ctrl-\\)

### Mandatory Requirements

- Display prompt and maintain command history
- Execute commands using PATH or absolute/relative paths
- Handle quotes (single and double)
- Implement redirections: `<`, `>`, `>>`, `<<` (heredoc)
- Implement pipes: `|`
- Expand environment variables: `$VAR`, `$?`
- Handle signals appropriately (Ctrl-C, Ctrl-D, Ctrl-\\)
- Implement built-ins: `echo`, `cd`, `pwd`, `export`, `unset`, `env`, `exit`

## Features

### ✅ Command Parsing
- Tokenization (lexer)
- Quote handling (single `'` and double `"`)
- Variable expansion (`$USER`, `$?`, `$PATH`)
- Whitespace normalization
- Syntax validation

### ✅ Redirections
- Input redirection: `<`
- Output redirection: `>`
- Append mode: `>>`
- Heredoc: `<<`

### ✅ Pipes
- Multiple pipe support: `cmd1 | cmd2 | cmd3`
- Proper file descriptor management
- Fork/exec coordination

### ✅ Built-in Commands
| Command | Description |
|---------|-------------|
| `echo [-n]` | Print arguments with optional newline suppression |
| `cd [path]` | Change directory (relative/absolute, `~`, `-`) |
| `pwd` | Print working directory |
| `export [VAR=value]` | Set environment variables |
| `unset [VAR]` | Remove environment variables |
| `env` | Display environment variables |
| `exit [code]` | Exit shell with optional status code |

### ✅ Signal Handling
- **Ctrl-C**: Interrupt current command (SIGINT)
- **Ctrl-D**: Exit shell (EOF)
- **Ctrl-\\**: Ignored (SIGQUIT) in interactive mode
- Proper signal handling in different contexts (interactive, heredoc, command execution)

### ✅ Environment Management
- Custom environment variable linked list
- Variable expansion in strings
- Export/unset functionality
- Exit status tracking (`$?`)

## Architecture Overview

The project is divided into two main components:

```
┌─────────────────────────────────────────────────────────┐
│                      MINISHELL                          │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────────┐         ┌──────────────────┐      │
│  │   PARSING        │────────>│   EXECUTION      │      │
│  │   (sedto)        │         │   (ciso)         │      │
│  └──────────────────┘         └──────────────────┘      │
│         │                              │                │
│         │                              │                │
│    ┌────┴────┐                    ┌───┴────┐            │
│    │  Lexer  │                    │Builtins│            │
│    │ Expander│                    │ Pipes  │            │
│    │  Parser │                    │ Redirs │            │
│    └─────────┘                    │Executor│            │
│                                   └────────┘            │
└─────────────────────────────────────────────────────────┘
```

**Flow**:
1. User input → Readline
2. Input → Lexer → Tokens
3. Tokens → Expander → Expanded Tokens
4. Expanded Tokens → Parser → Command AST
5. Command AST → Executor → Fork/Exec
6. Wait for processes → Update exit status
7. Display new prompt

## Parsing Pipeline (sedto)

I was responsible for the entire parsing system, transforming raw user input into a structured command representation ready for execution.

### 1. Input Cleaning (`clean_input.c`)

**Purpose**: Normalize whitespace while preserving quoted strings

```
Input:  "echo    'hello   world'  |  grep   pattern"
Output: "echo 'hello   world' | grep pattern"
```

**Challenges**:
- Preserve whitespace inside quotes
- Add spaces around operators (`|`, `<`, `>`, `>>`, `<<`)
- Handle mixed single/double quotes

**Key functions**:
- `clean_input()`: Main entry point
- `handle_single_quote()`: Track single quote state
- `handle_double_quote()`: Track double quote state
- `add_space_if_needed()`: Insert spaces around operators

### 2. Lexer (`lexer/`)

**Purpose**: Convert cleaned input into a token stream

```
Input:  "cat file.txt | grep pattern > output"
Tokens: [WORD:cat] [WORD:file.txt] [PIPE] [WORD:grep]
        [WORD:pattern] [REDIR_OUT] [WORD:output] [EOF]
```

**Token Types** (`t_token_type`):
- `TOKEN_WORD`: Commands, arguments, filenames
- `TOKEN_PIPE`: `|`
- `TOKEN_REDIR_IN`: `<`
- `TOKEN_REDIR_OUT`: `>`
- `TOKEN_APPEND`: `>>`
- `TOKEN_HEREDOC`: `<<`
- `TOKEN_EOF`: End of input

**Key files**:
- `tokenize.c`: Main tokenization loop
- `tokenize_operators.c`: Handle `|`, `<`, `>`, `<<`, `>>`
- `tokenize_utils.c`: Helper functions (quote detection, operator chars)
- `create_tokens.c`: Token creation and linked list management

**Algorithm**:
1. Skip whitespace
2. Check for operators → Create operator token
3. Check for quotes → Extract quoted word
4. Otherwise → Extract unquoted word
5. Add token to linked list
6. Repeat until end of input

### 3. Expander (`expander/`)

**Purpose**: Expand environment variables within tokens

```
Before: [WORD:echo] [WORD:$USER] [WORD:has] [WORD:$HOME]
After:  [WORD:echo] [WORD:sedto] [WORD:has] [WORD:/home/sedto]
```

**Expansion Rules**:
- `$VAR` → Value of VAR
- `$?` → Last exit status
- `$$` → Shell PID (not implemented in mandatory)
- Variables in single quotes `'$VAR'` → Not expanded
- Variables in double quotes `"$VAR"` → Expanded

**Key files**:
- `expand_variables.c`: Variable lookup and expansion
- `expand_strings.c`: Main expansion orchestrator
- `expand_process.c`: Process individual variables
- `expand_quotes.c`: Handle quote contexts
- `expand_utils.c`: Helper functions (var name extraction)
- `expand_buffer.c`: Dynamic buffer management
- `expand_helpers.c`: Token filtering (remove empty tokens)

**Algorithm**:
1. Calculate buffer size (accounting for expansions)
2. Allocate result buffer
3. Iterate through string:
   - If `'` → Copy literally, don't expand inside
   - If `"` → Copy and expand inside
   - If `$` (outside single quotes) → Extract var name, expand, copy value
   - Otherwise → Copy character
4. Return expanded string

**Special Cases**:
- Empty expansion (`$NONEXISTENT` → removed)
- Exit status (`$?` → `"0"` or error code)
- Invalid variable names (`$123`, `$-`) → Not expanded

### 4. Parser (`parser/`)

**Purpose**: Convert token stream into command structure (`t_cmd`)

```
Tokens: [WORD:ls] [WORD:-la] [REDIR_OUT] [WORD:file] [PIPE]
        [WORD:grep] [WORD:pattern]

Commands:
  ├─ Command 1: args=["ls", "-la"], files=[{OUTPUT, "file"}]
  └─ Command 2: args=["grep", "pattern"], files=NULL
```

**Data Structures**:

```c
// Command node (linked list of commands separated by pipes)
typedef struct s_cmd
{
    char    **args;      // ["ls", "-la", NULL]
    t_file  *files;      // Redirections
    struct s_cmd *next;  // Next command in pipe
} t_cmd;

// File redirection node
typedef struct s_file
{
    char    *name;              // Filename
    char    *heredoc_content;   // For heredocs
    int     fd;                 // File descriptor
    t_redir type;               // INPUT, OUTPUT, APPEND, HEREDOC
    struct s_file *next;        // Multiple redirections
} t_file;
```

**Key files**:
- `parse_commands.c`: Main parsing logic
- `parse_handlers.c`: Handle different token types (WORD, PIPE, REDIR)
- `parse_validation.c`: Syntax error detection
- `parse_utils.c`: Redirection processing
- `create_commande.c`: Command structure creation
- `heredoc_utils.c`: Heredoc reading
- `heredoc_read.c`: Interactive heredoc input
- `heredoc_expansion.c`: Expand variables in heredoc
- `quote_remover.c`: Remove quotes from final arguments

**Parsing Algorithm**:
1. Create first command node
2. For each token:
   - **WORD** → Add to current command's args
   - **PIPE** → Create new command, add to list
   - **REDIR_IN/OUT/APPEND** → Create file node, add to current command
   - **HEREDOC** → Read heredoc content interactively
3. Validate syntax (no empty commands, no pipes at start/end)
4. Remove quotes from arguments
5. Return command list

**Heredoc Handling** (`<<`):

When encountering `<<DELIMITER`:
1. Display `heredoc>` prompt
2. Read lines until DELIMITER
3. Store content in memory (not temp file)
4. Expand variables if delimiter is unquoted
5. Attach content to file node

**Quote Removal**:

After parsing, remove surrounding quotes but preserve their effect:
- `"hello"` → `hello`
- `'world'` → `world`
- `"$USER"` → `sedto` (already expanded)

## Execution Engine (ciso)

My teammate ciso implemented the execution system, handling process management, pipes, redirections, and built-in commands.

### 1. Executor (`executor/`)

**Purpose**: Execute parsed commands with pipes and redirections

**Key files**:
- `executors.c`: Main execution loop
- `executors_helpers.c`: Pipe and fd management
- `executors_redirections.c`: Handle file redirections
- `executors_utils.c`: Path resolution
- `get_path.c`: Find executable in PATH

**Execution Flow**:

For a single command:
1. Check if built-in → Execute directly
2. Otherwise → Fork and exec

For piped commands (`cmd1 | cmd2 | cmd3`):
1. Count commands
2. For each command:
   - Create pipe (if not last)
   - Fork child process
   - In child:
     - Setup input (previous pipe or stdin)
     - Setup output (next pipe or stdout)
     - Handle redirections
     - Execute command
   - In parent:
     - Close pipe ends
     - Save pipe for next command
3. Wait for all children
4. Update exit status from last command

**Pipe Management**:
```c
int pipe_fd[2];
pipe(pipe_fd);      // Create pipe
                    // pipe_fd[0] = read end
                    // pipe_fd[1] = write end

// Child 1
dup2(pipe_fd[1], STDOUT_FILENO);  // Redirect stdout to pipe
close(pipe_fd[0]);
close(pipe_fd[1]);

// Child 2
dup2(pipe_fd[0], STDIN_FILENO);   // Redirect stdin from pipe
close(pipe_fd[0]);
close(pipe_fd[1]);
```

### 2. Redirections

**Order of Operations**:
1. Process redirections left-to-right
2. Last redirection of each type wins
3. Apply after pipe setup

**Types**:

**Input (`<`)**: Read from file
```c
int fd = open(filename, O_RDONLY);
dup2(fd, STDIN_FILENO);
close(fd);
```

**Output (`>`)**: Write to file (truncate)
```c
int fd = open(filename, O_WRONLY | O_CREAT | O_TRUNC, 0644);
dup2(fd, STDOUT_FILENO);
close(fd);
```

**Append (`>>`)**: Write to file (append)
```c
int fd = open(filename, O_WRONLY | O_CREAT | O_APPEND, 0644);
dup2(fd, STDOUT_FILENO);
close(fd);
```

**Heredoc (`<<`)**: Read from stored content
```c
// Content already stored during parsing
int pipe_fd[2];
pipe(pipe_fd);
write(pipe_fd[1], heredoc_content, strlen(heredoc_content));
close(pipe_fd[1]);
dup2(pipe_fd[0], STDIN_FILENO);
close(pipe_fd[0]);
```

### 3. Built-ins (`builtins/`)

**Why built-ins must execute in parent**:
- `cd`, `export`, `unset` modify shell state
- If executed in child, changes are lost after fork

**Implementation**:

**Single built-in** (no pipes):
- Execute directly in parent
- Return exit status

**Built-in in pipeline**:
- Execute in child (can't modify parent environment)
- Limitation: `export` in pipeline doesn't persist

**Key files**:
- `builtins.c`: Built-in dispatcher
- `builtins_basic.c`: `echo`, `pwd`, `env`, `cd`
- `builtins_export.c`: `export` with validation
- `builtins_exit.c`: `exit` with argument parsing

**echo**:
- `-n` flag: No trailing newline
- Expand variables before echo

**cd**:
- Update `PWD` and `OLDPWD` environment variables
- Handle `~` (HOME), `-` (OLDPWD), relative/absolute paths

**export**:
- Validate variable name (alphanumeric + underscore, no digit first)
- Add to environment linked list
- Print all variables if no arguments

**exit**:
- Parse numeric argument
- Exit with status code (0-255)
- Non-numeric argument → error

### 4. Environment Management (`env/`)

**Structure**:
```c
typedef struct s_env
{
    char *key;       // "USER"
    char *value;     // "sedto"
    struct s_env *next;
} t_env;
```

**Key functions**:
- `init_env()`: Convert `char **envp` to linked list
- `get_env_value()`: Lookup by key
- `set_env_value()`: Add or update variable
- `unset_env_value()`: Remove variable
- `env_to_array()`: Convert back to `char **` for execve

**Benefits of linked list**:
- Easy insertion/deletion
- No reallocation needed
- Simple iteration

### 5. Signal Handling (`signals/`)

**Interactive mode** (waiting for command):
- **Ctrl-C** (SIGINT): Display new prompt
- **Ctrl-\\** (SIGQUIT): Ignored
- **Ctrl-D** (EOF): Exit shell

**Command execution**:
- **Ctrl-C**: Terminate current foreground process
- **Ctrl-\\**: Quit with core dump (if enabled)

**Heredoc mode**:
- **Ctrl-C**: Abort heredoc, return to prompt
- **Ctrl-D**: Complete heredoc if at start of line

**Implementation**:
```c
extern volatile sig_atomic_t g_signal;

void handle_sigint(int sig)
{
    g_signal = sig;
    write(1, "\n", 1);
    rl_on_new_line();
    rl_replace_line("", 0);
    rl_redisplay();
}
```

**Setup**:
```c
signal(SIGINT, handle_sigint);
signal(SIGQUIT, SIG_IGN);
```

## Project Structure

```
minishell/
├── Makefile                    # Build system
├── includes/
│   └── minishell.h            # All structures and prototypes
│
├── libft/                      # Personal C library
│
├── src/                        # Main entry point
│   ├── main.c                 # Shell loop
│   ├── main_utils.c           # Input processing
│   └── main_utils_helpers.c   # Shell setup
│
├── parsing/                    # PARSING (sedto)
│   └── srcs/
│       ├── utils/             # Input cleaning
│       │   ├── clean_input.c
│       │   └── clean_input_utils.c
│       │
│       ├── lexer/             # Tokenization
│       │   ├── create_tokens.c
│       │   ├── tokenize.c
│       │   ├── tokenize_utils.c
│       │   └── tokenize_operators.c
│       │
│       ├── expander/          # Variable expansion
│       │   ├── expand_variables.c
│       │   ├── expand_strings.c
│       │   ├── expand_process.c
│       │   ├── expand_quotes.c
│       │   ├── expand_utils.c
│       │   ├── expand_buffer.c
│       │   ├── expand_helpers.c
│       │   └── expand_utils_extra.c
│       │
│       └── parser/            # Command structure creation
│           ├── create_commande.c
│           ├── create_commande_utils.c
│           ├── create_commande_helpers.c
│           ├── redirect_helpers.c
│           ├── parse_commands.c
│           ├── parse_commands_utils.c
│           ├── parse_handlers.c
│           ├── parse_validation.c
│           ├── parse_utils.c
│           ├── quote_remover.c
│           ├── heredoc_utils.c
│           ├── heredoc_helpers.c
│           ├── heredoc_read.c
│           ├── heredoc_support.c
│           └── heredoc_expansion.c
│
└── execution/                  # EXECUTION (ciso)
    └── srcs/
        ├── signals/           # Signal handling
        │   └── signals.c
        │
        ├── env/               # Environment management
        │   ├── env_utils.c
        │   ├── env_utils_extra.c
        │   └── env_conversion.c
        │
        ├── builtins/          # Built-in commands
        │   ├── builtins.c
        │   ├── builtins_basic.c
        │   ├── builtins_export.c
        │   └── builtins_exit.c
        │
        ├── utils/             # Execution utilities
        │   ├── utils.c
        │   ├── utils_extra.c
        │   └── utils_commands.c
        │
        └── executor/          # Process execution
            ├── executors.c
            ├── executors_helpers.c
            ├── executors_redirections.c
            ├── executors_utils.c
            ├── get_path.c
            └── errors_env.c
```

**Total**: ~4000 lines of C code across 60+ files

## Compilation & Usage

### Build

```bash
make        # Compile minishell
make clean  # Remove object files
make fclean # Remove objects and executable
make re     # Rebuild from scratch
```

**Requirements**:
- `readline` library (Ubuntu: `libreadline-dev`, macOS: via Homebrew)
- GCC with `-Wall -Wextra -Werror`

### Run

```bash
./minishell
```

### Example Session

```bash
$ ./minishell
minishell$ echo Hello, $USER!
Hello, sedto!

minishell$ export NAME=World
minishell$ echo "Hello, $NAME"
Hello, World

minishell$ ls -la | grep minishell | wc -l
1

minishell$ cat << EOF > file.txt
heredoc> Line 1
heredoc> Line 2
heredoc> EOF
minishell$ cat file.txt
Line 1
Line 2

minishell$ cd /tmp && pwd
/tmp

minishell$ exit 42
$ echo $?
42
```

## What I Learned

### Parsing & Language Design (sedto)

**Lexical Analysis**:
- Tokenization strategies (greedy matching, lookahead)
- Operator precedence (though minishell doesn't have complex precedence)
- Quote handling (state machines for context tracking)

**Syntax Validation**:
- Error detection (pipes at start/end, empty commands)
- Providing meaningful error messages
- Fail-fast vs. error recovery

**Variable Expansion**:
- String interpolation techniques
- Dynamic buffer allocation
- Context-aware expansion (quotes)
- Edge cases (empty vars, special vars)

**Parser Design**:
- Recursive descent parsing (not used here, but understood)
- Token stream processing
- AST-like structure creation (command linked list)
- Separation of concerns (lexer → expander → parser)

**Heredoc Implementation**:
- Reading multi-line input
- Delimiter matching
- In-memory storage vs. temp files
- Expansion rules

### Process Management

**fork() / exec() / wait()**:
- Understanding the fork model (copy-on-write)
- exec family differences (execve vs. execvp)
- Reaping child processes
- Zombie process prevention

**File Descriptors**:
- stdin (0), stdout (1), stderr (2)
- dup2() for redirection
- Closing unused descriptors
- File descriptor leaks

**Pipes**:
- IPC between processes
- Pipe creation and management
- Closing appropriate ends
- Avoiding deadlocks

### Signal Handling

**Signal Basics**:
- SIGINT, SIGQUIT, SIGTERM
- Signal handlers vs. default behavior
- Async-signal-safe functions

**Global Variables**:
- Why we use `volatile sig_atomic_t`
- Minimizing global state
- Signal handler limitations

**Readline Integration**:
- rl_on_new_line(), rl_replace_line()
- Clean signal interruption of readline

### Memory Management

**Leak Prevention**:
- Every malloc has a free
- Valgrind for leak detection
- Freeing on all exit paths (error handling)

**Dynamic Data Structures**:
- Linked lists (commands, files, env, tokens)
- Dynamic arrays (command arguments)
- String duplication (strdup)

**Cleanup Strategies**:
- Top-down cleanup (free commands → free files → free strings)
- Avoiding double-free
- NULL checks before free

### Debugging Complex Systems

**Tools Used**:
- `valgrind --leak-check=full`
- `gdb` for segfaults
- `strace` for system call tracing
- Print debugging (disabled in final version)

**Strategies**:
- Isolating components (test lexer independently)
- Reproducing bugs with minimal input
- Understanding where state changes

## Challenges Faced

### 1. Quote Handling During Tokenization

**Problem**: Deciding when to stop a word token when encountering quotes.

Example: `echo "hello world" | grep pattern`

Should `"hello world"` be one token or three?

**Solution**:
- Treat quoted strings as part of a word token
- Track quote state during word extraction
- Don't split on spaces inside quotes
- Remove quotes during final parsing step

### 2. Variable Expansion in Different Contexts

**Problem**: `$VAR` should expand differently based on surrounding quotes:

```bash
echo $VAR      # Expand and split on spaces
echo "$VAR"    # Expand but don't split
echo '$VAR'    # Don't expand at all
```

**Solution**:
- Track quote context (none, single, double)
- Apply expansion rules based on context
- Handle nested quotes properly

**Edge Case**: Empty expansions
```bash
echo $NONEXISTENT hello  # Should become "echo hello"
```

Removing empty tokens after expansion was crucial.

### 3. Heredoc Signal Handling

**Problem**: Pressing Ctrl-C during heredoc should abort cleanly without crashing.

**Solution**:
- Set global signal flag
- Check flag after each readline call
- Free allocated memory before returning NULL
- Restore normal signal behavior after heredoc

### 4. Pipe File Descriptor Management

**Problem**: Too many open file descriptors, causing `pipe() failed` errors.

**Solution**:
- Close all unused pipe ends immediately
- Close previous command's pipe before creating new one
- In child: close parent's saved fd
- Systematic fd audit

### 5. Built-ins in Pipes

**Problem**: `export VAR=value | cat` doesn't persist because export runs in child.

**Understanding**:
- This is correct Bash behavior!
- Built-ins in pipes can't modify parent environment
- Document this limitation

**Workaround**: Detect single built-in (no pipes) and execute in parent.

### 6. Memory Leaks on Syntax Errors

**Problem**: When syntax error detected, we returned NULL but forgot to free tokens and partially-built commands.

**Solution**:
- Create cleanup functions: `free_tokens()`, `free_commands()`
- Call cleanup in all error paths
- Centralized error handling with cleanup

### 7. PATH Resolution

**Problem**: Finding executables in PATH directories.

**Solution**:
- Split PATH by `:`
- Try each directory + `/` + command
- Use `access()` to check if executable
- Return first match or NULL

**Edge Cases**:
- Empty PATH → use default `/bin:/usr/bin`
- Absolute/relative paths → don't search PATH
- Command not found → print error

### 8. Norminette Compliance

**42's Norminette** enforces strict rules:
- Max 25 lines per function
- Max 5 functions per file
- Max 80 columns per line
- Specific formatting (indentation, spacing)

**Solution**:
- Break large functions into static helpers
- Use function pointers to reduce line count
- Refactor until compliant (painful but worthwhile)

### 9. Readline Memory Management

**Problem**: Readline allocates memory that must be freed.

```c
char *input = readline("minishell$ ");
// Must free input!
free(input);
```

**Solution**:
- Always free readline return value
- Check for NULL (Ctrl-D)
- Add to history before freeing

### 10. Parsing Ambiguities

**Problem**: How to parse `echo $VAR$VAR2`?

**Solution**:
- Expand all variables sequentially
- Concatenate results
- No word splitting between adjacent vars

**Problem**: How to parse `<<EOF`vs`<< EOF`?

**Solution**:
- Both are valid
- Tokenizer handles both cases
- Skip whitespace after operator

## Testing

### Manual Testing

```bash
# Basic commands
echo hello
ls -la
pwd

# Pipes
ls | grep minishell
cat file | grep pattern | wc -l

# Redirections
echo hello > file.txt
cat < file.txt
cat >> file.txt
cat << EOF

# Variables
export VAR=value
echo $VAR
echo "$VAR"
echo '$VAR'
unset VAR

# Quotes
echo "hello   world"
echo 'hello   world'
echo "User: $USER"

# Complex
export X=42 && echo $X | cat
ls | grep .c > files.txt

# Edge cases
echo    # Empty argument
cd      # No argument (should go HOME)
export  # No argument (print all)
```

### Automated Testing

Created test scripts:
- `test.sh`: Basic functionality tests
- `test_valgrind.sh`: Memory leak detection

**Comparison with Bash**:
```bash
# Run command in both shells, compare output
bash -c "echo \$USER"
./minishell -c "echo \$USER"
```

### Known Limitations

- No logical operators (`&&`, `||`)
- No wildcards (`*`, `?`)
- No subshells (`$(cmd)`, `` `cmd` ``)
- No background jobs (`&`)
- No job control (`fg`, `bg`, `jobs`)

These are explicitly out of scope for the mandatory part.

---

**Authors**: sedto (parsing), ciso (execution)
**School**: 42 Lausanne
**Date**: May - August 2025
**Grade**: _(pending evaluation)_
