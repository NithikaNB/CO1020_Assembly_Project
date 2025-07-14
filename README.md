# CO1020_Assembly_Project
=======
# ARM32 Assembly Command-Line Shell

## Project Information

**Course**: CO1020 - Computer Systems Programming  
**Department**: Computer Engineering, University of Peradeniya  
**Project Type**: Group Project  
**Duration**: 2 Weeks  
**Language**: ARM32 Assembly  

## Group Details

**Group Number**: 36

**Members**:
- D.M.N.N. Bandara (E/22/044)
- K.B.A.D.G.C. Kapurubandara (E/22/180)

## Project Specifications

### Objective
Build a minimal interactive command-line shell in ARM32 assembly language that can handle basic commands and custom operations.

### Requirements
- Single `shell.s` file implementation
- Proper memory section organization (`.data`, `.bss`, `.text`)
- Continuous shell loop with user input handling
- Basic command set implementation
- Two custom commands with complexity beyond basic operations
- Proper stack usage and register preservation

## Implementation Details

### Code Architecture

#### Memory Sections
- **`.data` Section**: Contains all string literals, prompts, messages, and command definitions
- **`.bss` Section**: Uninitialized memory buffers for runtime data storage (input_buffer, token_buffer, reverse_buffer)
- **`.text` Section**: Executable code with main entry point and function definitions

#### Core Functions

##### System Interface Functions
- `print_string`: Outputs text to stdout using system calls (sys_write)
- `read_input`: Reads user input from stdin using system calls (sys_read)
- `strlen`: Calculates string length by iterating through characters
- `remove_newline`: Removes newline and carriage return characters from input

##### String Processing Functions
- `strcmp`: Compares two strings for equality using byte-by-byte comparison
- `extract_token`: Tokenizes input string for command parsing with bounds checking
- `parse_command`: Main command parser and dispatcher with special handling for complex commands
- `check_reverse_command`: Direct string matching for reverse command to avoid parsing issues

##### Command Handler Functions
- `cmd_hello_handler`: Handles hello command
- `cmd_help_handler`: Displays available commands
- `cmd_exit_handler`: Terminates shell using sys_exit system call
- `cmd_clear_handler`: Clears screen using ANSI escape sequences
- `cmd_reverse_handler`: Advanced text reversal implementation
- `cmd_echo_handler`: Echo command with argument processing

#### Stack Management
- All functions properly save and restore registers using stack operations
- `lr` register preservation for function returns
- Temporary register management across function calls using push/pop operations
- Proper stack alignment and cleanup

### Implemented Features

#### Basic Commands
| Command | Function | Description |
|---------|----------|-------------|
| `hello` | `cmd_hello_handler` | Prints "Hello World!" |
| `help` | `cmd_help_handler` | Lists all available commands |
| `exit` | `cmd_exit_handler` | Terminates the shell |
| `clear` | `cmd_clear_handler` | Clears the terminal screen |

#### Custom Commands
| Command | Function | Description |
|---------|----------|-------------|
| `reverse` | `cmd_reverse_handler` | Reverses input text using string manipulation |
| `echo` | `cmd_echo_handler` | Echoes user input back to terminal |

#### Reverse Command Features
- **Syntax**: `reverse <text>`
- **Example**: `reverse Hello World!` → Reversed: !dlroW olleH
- **Processing**: 
  - Finds start and end of input text
  - Copies characters in reverse order to dedicated buffer
  - Handles empty input gracefully
  - Prevents buffer overflow with bounds checking

#### Echo Command Features
- **Syntax**: `echo <message>`
- **Example**: `echo Hello Assembly!` → Echo: Hello Assembly!
- **Processing**: 
  - Skips command name and leading spaces
  - Handles multiple words and special characters
  - Preserves original spacing in output

### Technical Implementation

#### Input Processing
- 256-byte input buffer allocation in `.bss` section
- Newline and carriage return character removal
- Bounds checking to prevent buffer overflow
- Safe string termination with null characters

#### Command Parsing
- **Two-tier parsing system**:
  1. Direct string matching for complex commands (reverse, echo)
  2. Token-based parsing for simple commands (hello, help, exit, clear)
- String comparison-based command matching using `strcmp`
- Conditional branching for command routing
- Unknown command handling with helpful error messages

#### String Manipulation
- **Reverse Algorithm**:
  - Linear scan to find string boundaries
  - Backward iteration through source string
  - Forward writing to destination buffer
  - Character-by-character copying with bounds checking
- **Memory Safety**: All string operations include buffer overflow protection

#### Error Handling
- Invalid command recognition with helpful messages
- Empty input handling
- Buffer overflow prevention
- Graceful error message display
- Safe termination on system call failures

#### Memory Management
- Static buffer allocation in `.bss` section for predictable memory usage
- Proper memory addressing with load effective address operations
- Buffer reuse across command executions
- No dynamic memory allocation (embedded-friendly approach)

### System Calls Used
- **sys_write (4)**: For output operations to stdout
- **sys_read (3)**: For input operations from stdin  
- **sys_exit (1)**: For program termination

### Register Usage
- **r0-r3**: Parameter passing and return values (ARM calling convention)
- **r4-r8**: Local variables in complex functions (callee-saved)
- **r7**: System call number for Linux system calls
- **lr**: Link register for function returns
- **sp**: Stack pointer for register preservation

### Assembly Techniques Demonstrated
- **Addressing Modes**: Immediate, register, and memory addressing
- **Conditional Execution**: Branch instructions with condition codes
- **String Operations**: Byte-level string manipulation
- **Loop Constructs**: Counter-controlled and condition-controlled loops
- **Function Calls**: Proper linkage and parameter passing
- **System Integration**: Linux system call interface

## Build and Execution

### Compilation
```bash
arm-linux-gnueabi-gcc -Wall shell.s -o shell
```

### Execution
```bash
qemu-arm -L /usr/arm-linux-gnueabi shell
```

### Usage Examples
```
shell> hello
Hello World!

shell> reverse Programming is fun!
Reversed: !nuf si gnimmargorP

shell> echo Welcome to our ARM32 shell!
Echo: Welcome to our ARM32 shell!

shell> help
Available commands:
  hello - Prints Hello World!
  help - Lists all commands
  exit - Terminates the shell
  clear - Clears the screen
  reverse - Reverses your text
  echo - Echo back your message

shell> clear
[screen clears]

shell> exit
Goodbye!
```

## Individual Contributions

### D.M.N.N. Bandara (E/22/044)
- 


### K.B.A.D.G.C. Kapurubandara (E/22/180)
- 

## Project Challenges and Solutions

### Challenge 1: Command Parsing Complexity
**Problem**: Initial implementation had complex token-based parsing that caused segmentation faults with multi-word commands.

**Solution**: Implemented a two-tier parsing system with direct string matching for complex commands and simplified token extraction for basic commands.

### Challenge 2: Memory Management
**Problem**: Buffer overflow issues during string manipulation operations.

**Solution**: Added comprehensive bounds checking throughout all string operations and implemented safe buffer termination.

### Challenge 3: Register Conflicts
**Problem**: ARM32 multiply instruction register constraints causing compilation errors.

**Solution**: Used intermediate registers and proper register allocation to satisfy ARM32 instruction requirements.

