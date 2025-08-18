# 📊 Diagrammes Architecture - Minishell

## 🎯 Vue d'ensemble du flux principal

```mermaid
flowchart TD
    A[Input: echo $HOME pipe cat] --> B[Lexer/Tokenizer]
    B --> C[Token Stream]
    C --> D[Expander]
    D --> E[Expanded Tokens]
    E --> F[Parser]
    F --> G[Command Structure]
    G --> H[Executor]
    H --> I[Output]
    
    B --> B1[WORD: echo]
    B --> B2[VAR: $HOME]
    B --> B3[PIPE: |]
    B --> B4[WORD: cat]
    
    D --> D1[WORD: echo]
    D --> D2[WORD: /Users/user]
    D --> D3[PIPE: |]
    D --> D4[WORD: cat]
    
    F --> F1[CMD1: args[echo, /Users/user]]
    F --> F2[CMD2: args[cat]]
    
    H --> H1[fork + pipe + exec]
    H --> H2[Process Management]
    
    style A fill:#e1f5fe
    style I fill:#c8e6c9
    style H fill:#fff3e0
```

## 🏗️ Architecture modulaire détaillée

```mermaid
graph TB
    subgraph "🎯 MAIN PROCESS"
        M[main.c]
        MU[main_utils.c]
        MH[main_utils_helpers.c]
    end
    
    subgraph "🔤 PARSING MODULE"
        PU[parse_utils.c]
        PH[parse_handlers.c]
        PV[parse_validation.c]
        PC[parse_commands.c]
        PCU[parse_commands_utils.c]
        QR[quote_remover.c]
    end
    
    subgraph "📝 HEREDOC MODULE"
        HU[heredoc_utils.c]
        HH[heredoc_helpers.c]
        HR[heredoc_read.c]
        HS[heredoc_support.c]
    end
    
    subgraph "🏗️ COMMAND CREATION"
        CC[create_commande.c]
        CCU[create_commande_utils.c]
        CCH[create_commande_helpers.c]
    end
    
    subgraph "⚡ EXECUTION MODULE"
        EX[executors.c]
        ER[executors_redirections.c]
        EU[executors_utils.c]
    end
    
    subgraph "📚 LIBRARY"
        LIB[libft/]
    end
    
    subgraph "📄 HEADERS"
        H[minishell.h]
    end
    
    M --> PU
    M --> EX
    PU --> PH
    PH --> PV
    PV --> PC
    PC --> PCU
    PC --> QR
    PC --> CC
    CC --> CCU
    CC --> CCH
    PU --> HU
    HU --> HH
    HU --> HR
    HU --> HS
    EX --> ER
    EX --> EU
    
    PU -.-> LIB
    EX -.-> LIB
    CC -.-> LIB
    
    M -.-> H
    PU -.-> H
    EX -.-> H
    
    style M fill:#ffcdd2
    style EX fill:#c8e6c9
    style PU fill:#e1f5fe
    style CC fill:#fff3e0
```

## 🔄 Pipeline d'exécution des commandes

```mermaid
sequenceDiagram
    participant Main as Main Process
    participant Parser as Parser
    participant Exec as Executor
    participant Child1 as Child Process 1
    participant Child2 as Child Process 2
    
    Main->>Parser: "echo hello | cat"
    Parser->>Parser: Tokenize input
    Parser->>Parser: Expand variables
    Parser->>Parser: Build command structure
    Parser->>Main: cmd1[echo hello] -> cmd2[cat]
    
    Main->>Exec: execute_commands()
    Exec->>Exec: Setup pipe[0], pipe[1]
    
    Exec->>Child1: fork() for "echo hello"
    Child1->>Child1: dup2(pipe[1], STDOUT)
    Child1->>Child1: close(pipe[0], pipe[1])
    Child1->>Child1: execve("echo", ["echo", "hello"])
    Child1-->>Exec: exit(0)
    
    Exec->>Child2: fork() for "cat"
    Child2->>Child2: dup2(pipe[0], STDIN)
    Child2->>Child2: close(pipe[0], pipe[1])
    Child2->>Child2: execve("cat", ["cat"])
    Child2-->>Exec: exit(0)
    
    Exec->>Exec: close(pipe[0], pipe[1])
    Exec->>Exec: wait_all_children()
    Exec->>Main: execution complete
```

## 🧠 Gestion mémoire et structures de données

```mermaid
graph TD
    subgraph "📋 INPUT PARSING"
        IN[Input String] --> TOK[Token List]
        TOK --> CMD[Command List]
    end
    
    subgraph "🔗 LINKED STRUCTURES"
        TOK --> T1[Token 1]
        T1 --> T2[Token 2] 
        T2 --> T3[Token 3]
        T3 --> TNULL[NULL]
        
        CMD --> C1[Command 1]
        C1 --> C2[Command 2]
        C2 --> CNULL[NULL]
        
        C1 --> A1[args array]
        C1 --> F1[files list]
        C2 --> A2[args array]
        C2 --> F2[files list]
    end
    
    subgraph "♻️ MEMORY MANAGEMENT"
        FREE1[free_tokens]
        FREE2[free_commands] 
        FREE3[free_minishell]
        
        FREE3 --> FREE2
        FREE3 --> FREE1
        FREE2 --> FREE4[free_files]
        FREE2 --> FREE5[free_args]
    end
    
    TOK -.->|cleanup| FREE1
    CMD -.->|cleanup| FREE2
    
    style IN fill:#e3f2fd
    style FREE1 fill:#ffebee
    style FREE2 fill:#ffebee
    style FREE3 fill:#ffebee
```

## 🔧 Processus de parsing détaillé

```mermaid
stateDiagram-v2
    [*] --> Reading_Input
    
    Reading_Input --> Tokenizing : Input received
    
    Tokenizing --> Word_Token : Regular character
    Tokenizing --> Quote_State : Quote found
    Tokenizing --> Special_Token : Special char (|, <, >)
    
    Quote_State --> Word_Token : Quote closed
    Quote_State --> Quote_State : Inside quotes
    
    Word_Token --> Variable_Expansion : $ found
    Word_Token --> Tokenizing : Token complete
    
    Variable_Expansion --> Word_Token : Variable expanded
    
    Special_Token --> Tokenizing : Special token complete
    
    Tokenizing --> Parsing : All tokens ready
    
    Parsing --> Command_Building : Valid syntax
    Parsing --> Syntax_Error : Invalid syntax
    
    Command_Building --> Execution : Commands built
    
    Execution --> [*] : Process complete
    Syntax_Error --> [*] : Error exit
    
    note right of Quote_State
        Handles both single (') 
        and double (") quotes
        Different expansion rules
    end note
    
    note right of Variable_Expansion
        Expands $VAR, $?, $$
        Handles environment variables
    end note
```

## 🚀 Architecture des processus et pipes

```mermaid
graph LR
    subgraph "🔄 MAIN PROCESS"
        M[Main Shell]
        P[Parser]
        E[Executor]
    end
    
    subgraph "⚡ CHILD PROCESSES"
        C1[Child 1: echo hello]
        C2[Child 2: cat]
        C3[Child 3: grep test]
    end
    
    subgraph "🔗 PIPES"
        P1[pipe1[0,1]]
        P2[pipe2[0,1]]
    end
    
    M --> P
    P --> E
    
    E --> C1
    E --> C2
    E --> C3
    
    C1 -->|stdout| P1
    P1 -->|stdin| C2
    
    C2 -->|stdout| P2
    P2 -->|stdin| C3
    
    E -.->|wait()| C1
    E -.->|wait()| C2
    E -.->|wait()| C3
    
    style M fill:#e1f5fe
    style C1 fill:#c8e6c9
    style C2 fill:#c8e6c9
    style C3 fill:#c8e6c9
    style P1 fill:#fff3e0
    style P2 fill:#fff3e0
```

## 📊 Cycle de vie d'une commande

```mermaid
journey
    title Cycle de vie : echo $HOME | cat
    
    section Input
        Saisie utilisateur: 1: User
        Lecture ligne: 3: Main
    
    section Parsing
        Tokenisation: 4: Lexer
        Expansion variables: 4: Expander
        Construction AST: 5: Parser
        Validation syntaxe: 4: Validator
    
    section Execution
        Création pipes: 5: Executor
        Fork processus: 5: Executor
        Setup redirections: 4: Child
        Exec commandes: 5: Child
        Attente enfants: 3: Executor
    
    section Cleanup
        Fermeture FDs: 4: Executor
        Libération mémoire: 5: Main
        Retour prompt: 5: Main
```

## 🎯 Diagramme des responsabilités

```mermaid
mindmap
    root((MINISHELL))
        Input Processing
            Readline integration
            History management
            Signal handling
        
        Parsing Engine
            Lexical analysis
                Token recognition
                Quote handling
                Escape sequences
            Syntax analysis
                Command validation
                Pipe validation
                Redirection validation
            Semantic analysis
                Variable expansion
                Path resolution
                Builtin detection
        
        Execution Engine
            Process management
                Fork handling
                Wait coordination
                Exit code management
            Pipe management
                FD coordination
                Buffer management
                Error propagation
            Redirection handling
                File operations
                Heredoc processing
                Error handling
        
        Memory Management
            Structure allocation
                Token structures
                Command structures
                Environment handling
            Cleanup coordination
                Parent cleanup
                Child cleanup
                Error cleanup
```

## 🔍 Diagramme de classes (structures C)

```mermaid
classDiagram
    class t_minishell {
        +t_env *env
        +t_cmd *commands
        +char **envp
        +int exit_code
        +int in_heredoc
    }
    
    class t_cmd {
        +char **args
        +char *path
        +t_file *files
        +t_cmd *next
        +int builtin_type
    }
    
    class t_token {
        +char *value
        +t_token_type type
        +t_token *next
        +int quoted
    }
    
    class t_file {
        +char *filename
        +t_file_type type
        +t_file *next
        +int fd
    }
    
    class t_env {
        +char *key
        +char *value
        +t_env *next
        +int exported
    }
    
    class t_process_data {
        +t_minishell *shell
        +t_shell_ctx *ctx
        +char *input
        +int flags
    }
    
    t_minishell ||--o{ t_cmd : contains
    t_minishell ||--o{ t_env : manages
    t_cmd ||--o{ t_file : has
    t_token ||--o| t_token : next
    t_cmd ||--o| t_cmd : next
    t_file ||--o| t_file : next
    t_env ||--o| t_env : next
    
    t_process_data ||--|| t_minishell : uses
```

## 📈 Métriques et performance

```mermaid
xychart-beta
    title "Performance Parsing (en microsecondes)"
    x-axis [1-token, 5-tokens, 10-tokens, 20-tokens, 50-tokens]
    y-axis "Temps (μs)" 0 --> 1000
    line [80, 200, 420, 850, 2100]
```

```mermaid
pie title Répartition du temps d'exécution
    "Parsing" : 15
    "Expansion" : 10
    "Fork/Exec" : 60
    "Wait/Cleanup" : 10
    "I/O" : 5
```

Ces diagrammes Mermaid peuvent être intégrés directement dans la documentation GitHub ou visualisés sur des plateformes supportant Mermaid comme GitLab, Notion, ou des éditeurs comme VS Code avec l'extension Mermaid.