CC = gcc
CFLAGS = -Wall -Wextra -std=c99 -O2 -I./includes
LDFLAGS = -lrt

# Directories
SRC_DIR = src
OBJ_DIR = obj
BIN_DIR = bin

# Target executable
TARGET = $(BIN_DIR)/alarm

# Source Files
SRCS = ${SRC_DIR}/main.c \
		  ${SRC_DIR}/hal/hal-api.c \
		  ${SRC_DIR}/peripherals/fpga-hex.c

# Object files
OBJS = $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SRCS))

# Default Target
all: directories $(TARGET)

# Create necessary directories
directories:
	@mkdir -p $(OBJ_DIR)
	@mkdir -p $(OBJ_DIR)/peripherals
	@mkdir -p $(OBJ_DIR)/hal
	@mkdir -p $(BIN_DIR)

# Link object files to create executable
$(TARGET): $(OBJS)
	@echo "Linking $@..."
	$(CC) $(OBJS) -o $@ $(LDFLAGS)
	@echo "Build complete: $@"

# Compile source files from src directory
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@echo "Compiling $<..."
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

# (Removed unused DEP_DIR dependency rule)
# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(OBJ_DIR) $(BIN_DIR)
	@echo "Clean complete"

# Run the program
run: $(TARGET)
	@echo "Running LCD demo..."
	sudo ./$(TARGET)

# Phony targets
.PHONY: all clean run directories