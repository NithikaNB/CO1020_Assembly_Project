# 🛠️ CO1020\_Assembly\_Project

## 🖥️ ARM32 Assembly Command-Line Shell

---

## 📘 Project Information

* **Course**: CO1020 - Computer Systems Programming
* **Department**: Computer Engineering, University of Peradeniya
* **Project Type**: Group Project
* **Duration**: 2 Weeks
* **Language**: ARM32 Assembly

---

## 👥 Group Details

* **Group Number**: 36
* **Members**:

  * 👤 D.M.N.N. Bandara (E/22/044)
  * 👤 K.B.A.D.G.C. Kapurubandara (E/22/180)

---

## 🎯 Project Objective

Build a minimal **interactive command-line shell** in ARM32 assembly that can handle basic commands and complex custom operations using direct memory and system call manipulation, demonstrating advanced programming concepts including cryptography and data analysis.

---

## ✅ Requirements

* 📝 Single `shell.s` file
* 📦 Proper memory section usage: `.data`, `.bss`, `.text`
* 🔁 Continuous shell loop with user input
* 🧠 Basic command set implementation
* 🧩 Two advanced custom commands demonstrating complex algorithms
* 📐 Stack and register management with correct conventions

---

## 🧱 Implementation Details

### 🗂️ Code Architecture

#### 📍 Memory Sections

* **`.data`**: String literals, prompts, messages, command names, help text
* **`.bss`**: Runtime data buffers (`input_buffer`, `token_buffer`, `cipher_buffer`, `freq_counts`, `freq_buffer`)
* **`.text`**: Main shell logic and function implementations

#### 🔧 Core Functions

##### 🔌 System Interface

* `print_string`: Uses `sys_write` for output
* `read_input`: Reads input with `sys_read`
* `strlen`: Calculates string length
* `remove_newline`: Trims newline/CR from inputs

##### 🧹 String Utilities

* `strcmp`: Compares two strings for equality
* `extract_token`: Parses input into command/arguments with bounds checking
* `parse_command`: Routes commands to appropriate handlers

##### ⚙️ Command Handlers

* `cmd_hello_handler`: Prints "Hello World!"
* `cmd_help_handler`: Lists available commands with descriptions
* `cmd_exit_handler`: Exits shell gracefully
* `cmd_clear_handler`: Clears screen using ANSI escape sequences
* `cmd_cipher_handler`: Caesar cipher encryption implementation
* `cmd_freq_handler`: Character frequency analysis

##### 🔐 Advanced Algorithm Support

* `simple_parse_shift_number`: Parses decimal shift values for cipher
* `apply_caesar_cipher`: Core encryption logic with alphabet wraparound
* Character frequency counting with array operations

#### 📚 Stack & Register Usage

* All functions **push/pop** necessary registers
* `lr` saved/restored properly for nested function calls
* Temporary registers (r4–r8) managed correctly
* Stack pointer (`sp`) maintained throughout execution

---

## 🧪 Implemented Features

### 🧾 Basic Commands

| 🔤 Command | 🧠 Function         | 📄 Description                    |
| ---------- | ------------------- | --------------------------------- |
| `hello`    | `cmd_hello_handler` | Prints "Hello World!"             |
| `help`     | `cmd_help_handler`  | Shows all supported commands      |
| `exit`     | `cmd_exit_handler`  | Exits the shell                   |
| `clear`    | `cmd_clear_handler` | Clears the screen                 |

### 💡 Advanced Custom Commands

| 🔤 Command | 🧠 Function           | 📄 Description                           |
| ---------- | --------------------- | ---------------------------------------- |
| `cipher`   | `cmd_cipher_handler`  | Caesar cipher encryption                 |
| `freq`     | `cmd_freq_handler`    | Character frequency analysis             |

#### 🔐 Caesar Cipher Command

* **Usage**: `cipher <text> <shift>`
* **Example**: `cipher hello 3` → `khoor`
* **Features**:
  * Preserves case (uppercase/lowercase)
  * Handles alphabet wraparound (z+1 = a)
  * Non-alphabetic characters remain unchanged
  * Supports shift values 0-25
  * Input validation and error handling

#### 📊 Character Frequency Analysis

* **Usage**: `freq <text>`
* **Example**: `freq hello` → `'h':1 'e':1 'l':2 'o':1`
* **Features**:
  * Counts printable ASCII characters (32-126)
  * Displays results in format `'char':count`
  * Handles multi-character counting efficiently
  * Array-based frequency storage
  * Formatted output with proper spacing

---

## ⚙️ Technical Implementation

### 🧾 Input Processing

* 256-byte buffer in `.bss` section
* Robust newline/CR character removal
* Null-terminated string handling
* Overflow-safe read operations

### 🧠 Command Parsing

* Token-based command extraction
* String comparison using custom `strcmp`
* Argument parsing for complex commands
* Error handling for unknown commands

### 🔣 Advanced String Manipulation

* **Caesar Cipher Logic**:
  * Character classification (uppercase/lowercase/other)
  * Modular arithmetic for alphabet wraparound
  * Case preservation during transformation
  * Bounds checking for shift values

* **Frequency Analysis**:
  * Array initialization and clearing
  * Character-to-index mapping
  * Accumulator-based counting
  * Formatted output generation

### ⚠️ Error Handling

* Invalid command messages with help suggestions
* Input validation for cipher shift values
* Empty input detection and graceful handling
* Buffer overflow protection
* System call error detection

### 🧠 Memory Management

* Static buffer allocation for predictable usage
* Efficient addressing modes
* No dynamic memory allocation
* Safe array bounds checking

---

## 🛠️ System Calls Used

| 🧾 System Call | 🆔 Number | 🔧 Purpose                    |
| -------------- | --------- | ----------------------------- |
| `sys_write`    | `4`       | Output to stdout              |
| `sys_read`     | `3`       | Input from stdin              |
| `sys_exit`     | `1`       | Terminate program gracefully  |

---

## 📐 Register Usage Summary

| Register  | Usage                                    |
| --------- | ---------------------------------------- |
| `r0`–`r3` | Arguments, return values, syscall params |
| `r4`–`r8` | Local variables and loop counters        |
| `r7`      | System call identifier                   |
| `lr`      | Return address for function calls        |
| `sp`      | Stack pointer maintenance                |

---

## 🔬 Assembly Concepts Demonstrated

* 📦 Complex addressing modes and memory operations
* 🧠 Conditional execution and branching logic
* 🔁 Nested loops and array processing
* 🧵 Advanced string manipulation algorithms
* 🔢 Mathematical operations (modular arithmetic)
* 🎭 Character classification and transformation
* 🔧 Robust function call linkage and parameter passing
* 💻 System-level programming with direct syscalls
* 📊 Data structure manipulation (arrays, buffers)
* 🛡️ Input validation and bounds checking

---

## 🏗️ Build and Run Instructions

### 🔨 Compilation

```bash
arm-linux-gnueabi-gcc -Wall shell.s -o shell
```

### ▶️ Execution

```bash
qemu-arm -L /usr/arm-linux-gnueabi shell
```

---

## 💻 Usage Examples

```
shell> hello
Hello World!

shell> cipher hello 3
Encrypted: khoor

shell> cipher ABC 1
Encrypted: BCD

shell> freq hello world
Frequency: 'h':1 'e':1 'l':3 'o':2 ' ':1 'w':1 'r':1 'd':1 

shell> cipher "Meet me at dawn" 13
Encrypted: Zrrg zr ng qnja

shell> freq Programming
Frequency: 'P':1 'r':2 'o':1 'g':2 'a':1 'm':2 'i':1 'n':1 

shell> help
Available commands:
  hello - Prints Hello World!
  help - Lists all commands
  exit - Terminates the shell
  clear - Clears the screen
  cipher - Caesar cipher encryption
  freq - Character frequency analysis

shell> clear
[screen clears]

shell> exit
Goodbye!
```

---

## 🚧 Project Challenges and Solutions

### ⚠️ 1. Complex Command Parsing

**Issue**: Parsing commands with multiple arguments (text + shift value)
**Solution**: Implemented sophisticated token extraction with last-space detection for separating text from numeric parameters

### 🔐 2. Caesar Cipher Implementation

**Issue**: Maintaining case sensitivity and handling alphabet wraparound
**Solution**: Separate processing paths for uppercase/lowercase with modular arithmetic for wraparound

### 📊 3. Frequency Analysis Optimization

**Issue**: Efficient character counting and formatted output
**Solution**: Array-based counting with ASCII-to-index mapping and custom formatting routines

### 🧠 4. Memory Buffer Management

**Issue**: Multiple buffers for different operations without conflicts
**Solution**: Dedicated buffers in `.bss` section with careful bounds checking

### 🔁 5. Register Management in Complex Functions

**Issue**: Register conflicts in nested function calls with multiple parameters
**Solution**: Systematic push/pop of registers with clear register allocation strategy

---

## 🎓 Educational Value

This project demonstrates mastery of:

* **Low-level Programming**: Direct memory manipulation and system calls
* **Algorithm Implementation**: Cryptographic and analytical algorithms in assembly
* **Data Structures**: Array operations and string processing
* **Input/Output Handling**: Robust user interaction and error handling
* **Code Organization**: Modular design with clear separation of concerns
* **Performance Optimization**: Efficient assembly code without high-level abstractions

The implementation showcases the ability to create complex, interactive applications using only ARM32 assembly language, demonstrating deep understanding of computer architecture and systems programming principles.