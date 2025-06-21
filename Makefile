# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/05/26 00:00:00 by dibsejra          #+#    #+#              #
#    Updated: 2025/06/21 01:08:52 by dibsejra         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# **************************************************************************** #
#                                  VARIABLES                                   #
# **************************************************************************** #

NAME		= minishell

# Directories
SRCDIR		= parsing/srcs
OBJDIR		= parsing/objs
INCDIR		= parsing/includes
LIBFT_DIR	= libft

# Source files
SRCS		= $(SRCDIR)/utils/clean_input.c \
		  $(SRCDIR)/utils/clean_input_utils.c \
		  $(SRCDIR)/utils/main.c \
		  $(SRCDIR)/utils/main_utils.c \
		  $(SRCDIR)/lexer/create_tokens.c \
		  $(SRCDIR)/lexer/tokenize.c \
		  $(SRCDIR)/lexer/tokenize_utils.c \
		  $(SRCDIR)/lexer/tokenize_operators.c \
		  $(SRCDIR)/expander/expand_variables.c \
		  $(SRCDIR)/expander/expand_strings.c \
		  $(SRCDIR)/expander/expand_process.c \
		  $(SRCDIR)/expander/expand_quotes.c \
		  $(SRCDIR)/expander/expand_utils.c \
		  $(SRCDIR)/expander/expand_buffer.c \
		  $(SRCDIR)/parser/create_commande.c \
		  $(SRCDIR)/parser/parse_commands.c \
		  $(SRCDIR)/parser/parse_handlers.c \
		  $(SRCDIR)/parser/parse_validation.c \
		  $(SRCDIR)/parser/parse_utils.c \
		  $(SRCDIR)/parser/quote_remover.c \
		  signals.c \
		  env_utils.c \
		  builtins.c \
		  utils.c

# Object files
OBJS		= $(SRCS:$(SRCDIR)/%.c=$(OBJDIR)/%.o)

# Compiler and flags
CC			= gcc
CFLAGS		= -Wall -Wextra -Werror -g
INCLUDES	= -I$(INCDIR) -I$(LIBFT_DIR)
LIBS		= -L$(LIBFT_DIR) -lft -lreadline

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

$(LIBFT):
	@echo "$(YELLOW)Building libft...$(RESET)"
	@$(MAKE) -C $(LIBFT_DIR)
	@echo "$(GREEN)✓ libft compiled successfully!$(RESET)"

clean:
	@echo "$(RED)Cleaning object files...$(RESET)"
	@rm -rf $(OBJDIR)
	@$(MAKE) -C $(LIBFT_DIR) clean

fclean: clean
	@echo "$(RED)Cleaning $(NAME)...$(RESET)"
	@rm -f $(NAME)
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
		$(filter-out $(OBJDIR)/utils/main.o, $(OBJS)) \
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
