# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: dibsejra <dibsejra@student.42lausanne.c    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/05/26 00:00:00 by dibsejra          #+#    #+#              #
#    Updated: 2025/06/03 01:37:03 by dibsejra         ###   ########.fr        #
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
SRCS		= $(SRCDIR)/utils/clean_input.c $(SRCDIR)/utils/main.c \
		  $(SRCDIR)/lexer/create_tokens.c $(SRCDIR)/lexer/tokenize.c \
		  $(SRCDIR)/lexer/tokenize_utils.c $(SRCDIR)/lexer/tokenize_operators.c

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

# Run automated tests
test-auto: $(NAME)
	@echo "$(GREEN)Running automated tests...$(RESET)"
	@./test.sh

# Debug rule
debug: CFLAGS += -fsanitize=address
debug: $(NAME)

# Install readline if needed (Ubuntu/Debian)
install-readline:
	@echo "$(YELLOW)Installing readline library...$(RESET)"
	sudo apt-get update && sudo apt-get install libreadline-dev

.PHONY: all clean fclean re test test-auto debug install-readline
