# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/05/26 00:00:00 by dibsejra          #+#    #+#              #
#    Updated: 2025/07/10 10:56:26 by dibsejra         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# **************************************************************************** #
#                                  VARIABLES                                   #
# **************************************************************************** #

NAME		= minishell

# Directories
SRCDIR		= src
PARSING_SRCDIR	= parsing/srcs
EXEC_SRCDIR	= execution/srcs
OBJDIR		= objs
PARSING_OBJDIR	= parsing/objs
EXEC_OBJDIR	= execution/objs
INCDIR		= includes
LIBFT_DIR	= libft

# Source files - Main
MAIN_SRCS	= $(SRCDIR)/main.c \
		  $(SRCDIR)/main_utils.c

# Source files - Parsing
PARSING_SRCS	= $(PARSING_SRCDIR)/utils/clean_input.c \
		  $(PARSING_SRCDIR)/utils/clean_input_utils.c \
		  $(PARSING_SRCDIR)/lexer/create_tokens.c \
		  $(PARSING_SRCDIR)/lexer/tokenize.c \
		  $(PARSING_SRCDIR)/lexer/tokenize_utils.c \
		  $(PARSING_SRCDIR)/lexer/tokenize_operators.c \
		  $(PARSING_SRCDIR)/expander/expand_variables.c \
		  $(PARSING_SRCDIR)/expander/expand_strings.c \
		  $(PARSING_SRCDIR)/expander/expand_process.c \
		  $(PARSING_SRCDIR)/expander/expand_quotes.c \
		  $(PARSING_SRCDIR)/expander/expand_utils.c \
		  $(PARSING_SRCDIR)/expander/expand_buffer.c \
		  $(PARSING_SRCDIR)/expander/expand_helpers.c \
		  $(PARSING_SRCDIR)/expander/expand_utils_extra.c \
		  $(PARSING_SRCDIR)/parser/create_commande.c \
		  $(PARSING_SRCDIR)/parser/parse_commands.c \
		  $(PARSING_SRCDIR)/parser/parse_commands_utils.c \
		  $(PARSING_SRCDIR)/parser/parse_handlers.c \
		  $(PARSING_SRCDIR)/parser/parse_validation.c \
		  $(PARSING_SRCDIR)/parser/parse_utils.c \
		  $(PARSING_SRCDIR)/parser/quote_remover.c \
		  $(PARSING_SRCDIR)/parser/heredoc_utils.c

# Source files - Execution
EXEC_SRCS	= $(EXEC_SRCDIR)/signals/signals.c \
		  $(EXEC_SRCDIR)/env/env_utils.c \
		  $(EXEC_SRCDIR)/builtins/builtins.c \
		  $(EXEC_SRCDIR)/utils/utils.c \
		  $(EXEC_SRCDIR)/executor/executor.c \
		  $(EXEC_SRCDIR)/executor/get_path.c \
			$(EXEC_SRCDIR)/executor/errors_env.c \

# All source files
SRCS		= $(MAIN_SRCS) $(PARSING_SRCS) $(EXEC_SRCS)

# Object files
MAIN_OBJS	= $(MAIN_SRCS:$(SRCDIR)/%.c=$(OBJDIR)/%.o)
PARSING_OBJS	= $(PARSING_SRCS:$(PARSING_SRCDIR)/%.c=$(PARSING_OBJDIR)/%.o)
EXEC_OBJS	= $(EXEC_SRCS:$(EXEC_SRCDIR)/%.c=$(EXEC_OBJDIR)/%.o)
OBJS		= $(MAIN_OBJS) $(PARSING_OBJS) $(EXEC_OBJS)

# Compiler and flags
CC			= gcc
CFLAGS		= -Wall -Wextra -Werror -g

# OS-specific Readline flags
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
    # macOS (Homebrew)
    RL_INC		= -I/opt/homebrew/opt/readline/include
    RL_LIB		= -L/opt/homebrew/opt/readline/lib
else
    # Linux (Ubuntu) - standard paths
    RL_INC		= -I/usr/include/readline 
    RL_LIB		= 
endif

INCLUDES	= -I$(INCDIR) -I$(LIBFT_DIR) $(RL_INC)
LIBS		= -L$(LIBFT_DIR) -lft -lreadline $(RL_LIB)

# Libft
LIBFT		= $(LIBFT_DIR)/libft.a

# Colors for pretty output
GREEN		= \033[32m
YELLOW		= \033[33m
RED			= \033[31m
RESET		= \033[0m

# **************************************************************************** #
#                                   RULES                                      #
# **************************************************************************** #

all: $(NAME)

$(NAME): $(LIBFT) $(OBJS)
	@echo "$(YELLOW)Linking $(NAME)...$(RESET)"
	@$(CC) $(OBJS) $(LIBS) -o $(NAME)
	@echo "$(GREEN)✓ $(NAME) compiled successfully!$(RESET)"

$(OBJDIR)/%.o: $(SRCDIR)/%.c
	@mkdir -p $(dir $@)
	@echo "$(YELLOW)Compiling $<...$(RESET)"
	@$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

$(PARSING_OBJDIR)/%.o: $(PARSING_SRCDIR)/%.c
	@mkdir -p $(dir $@)
	@echo "$(YELLOW)Compiling $<...$(RESET)"
	@$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

$(EXEC_OBJDIR)/%.o: $(EXEC_SRCDIR)/%.c
	@mkdir -p $(dir $@)
	@echo "$(YELLOW)Compiling $<...$(RESET)"
	@$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

$(LIBFT):
	@echo "$(YELLOW)Building libft...$(RESET)"
	@$(MAKE) -C $(LIBFT_DIR)
	@echo "$(GREEN)✓ libft compiled successfully!$(RESET)"

clean:
	@echo "$(RED)Cleaning object files...$(RESET)"
	@rm -rf $(OBJDIR) $(PARSING_OBJDIR) $(EXEC_OBJDIR)
	@$(MAKE) -C $(LIBFT_DIR) clean

fclean: clean
	@echo "$(RED)Cleaning $(NAME)...$(RESET)"
	@rm -f $(NAME)
	@find . -name '*.o' -delete
	@$(MAKE) -C $(LIBFT_DIR) fclean

re: fclean all

# Test rule to run the program
test: $(NAME)
	@echo "$(GREEN)Running $(NAME)...$(RESET)"
	@./$(NAME)

# Unit tests
test-units: $(LIBFT)
	@echo "$(YELLOW)Building unit tests...$(RESET)"
	@$(CC) $(CFLAGS) $(INCLUDES) test_units.c \
		$(filter-out $(OBJDIR)/main.o, $(OBJS)) \
		$(LIBS) -o test_units
	@echo "$(GREEN)Running unit tests...$(RESET)"
	@./test_units

# Quick test (requires compiled minishell)
test-quick:
	@echo "$(GREEN)Running quick tests...$(RESET)"
	@chmod +x test_express.sh && ./test_express.sh

# Complete test suite (requires compiled minishell)
test-complete:
	@echo "$(GREEN)Running complete tests...$(RESET)"
	@chmod +x test_simple_adapted.sh && ./test_simple_adapted.sh

.PHONY: all clean fclean re test test-units test-quick test-complete
