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

Build a minimal **interactive command-line shell** in ARM32 assembly that can handle basic commands and complex custom operations using direct memory and system call manipulation.

---

## ✅ Requirements

* 📝 Single `shell.s` file
* 📦 Proper memory section usage: `.data`, `.bss`, `.text`
* 🔁 Continuous shell loop with user input
* 🧠 Basic command set implementation
* 🧩 Two custom commands (beyond simple operations)
* 📐 Stack and register management with correct conventions

---

## 🧱 Implementation Details

### 🗂️ Code Architecture

#### 📍 Memory Sections

* **`.data`**: String literals, prompts, messages, command names
* **`.bss`**: Runtime data buffers (`input_buffer`, `token_buffer`, `reverse_buffer`)
* **`.text`**: Main shell logic and function implementations

#### 🔧 Core Functions

##### 🔌 System Interface

* `print_string`: Uses `sys_write` for output
* `read_input`: Reads input with `sys_read`
* `strlen`: Finds length of strings
* `remove_newline`: Trims newline/CR from inputs

##### 🧹 String Utilities

* `strcmp`: Compares two strings
* `extract_token`: Parses input into command/arguments
* `parse_command`: Routes commands appropriately
* `check_reverse_command`: Direct match for `reverse` command

##### ⚙️ Command Handlers

* `cmd_hello_handler`: Prints "Hello World!"
* `cmd_help_handler`: Lists available commands
* `cmd_exit_handler`: Exits shell
* `cmd_clear_handler`: Clears screen
* `cmd_reverse_handler`: Reverses input string
* `cmd_echo_handler`: Echoes back message

#### 📚 Stack & Register Usage

* All functions **push/pop** necessary registers
* `lr` saved/restored properly
* Temporary registers (r4–r8) managed correctly
* Stack pointer (`sp`) maintained throughout

---

## 🧪 Implemented Features

### 🧾 Basic Commands

| 🔤 Command | 🧠 Function         | 📄 Description               |
| ---------- | ------------------- | ---------------------------- |
| `hello`    | `cmd_hello_handler` | Prints "Hello World!"        |
| `help`     | `cmd_help_handler`  | Shows all supported commands |
| `exit`     | `cmd_exit_handler`  | Exits the shell              |
| `clear`    | `cmd_clear_handler` | Clears the screen            |

### 💡 Custom Commands

| 🔤 Command | 🧠 Function           | 📄 Description           |
| ---------- | --------------------- | ------------------------ |
| `reverse`  | `cmd_reverse_handler` | Reverses input string    |
| `echo`     | `cmd_echo_handler`    | Echoes the input message |

#### 🔄 Reverse Command

* **Usage**: `reverse <text>`
* **Example**: `reverse Hello!` → `!olleH`
* Handles empty strings and overflow cases

#### 🗣️ Echo Command

* **Usage**: `echo <text>`
* **Example**: `echo Hello ARM!` → `Hello ARM!`
* Preserves input format and spacing

---

## ⚙️ Technical Implementation

### 🧾 Input Processing

* 256-byte buffer in `.bss`
* Removes newline/CR characters
* Null-terminated strings
* Overflow-safe reads

### 🧠 Command Parsing

* Two-tier system:

  1. Direct string match for `reverse`, `echo`
  2. Token-based for others
* Uses `strcmp` and conditional branching
* Prints error for unknown commands

### 🔣 String Manipulation

* **Reverse logic**:

  * Locates bounds of string
  * Iterates backward from end to start
  * Writes to separate buffer
  * Checks for overflow

### ⚠️ Error Handling

* Invalid command messages
* Empty input detection
* Buffer protection
* Fails gracefully on system call errors

### 🧠 Memory Management

* Static buffers = predictable usage
* `lea` used for effective addressing
* No heap/dynamic allocation

---

## 🛠️ System Calls Used

| 🧾 System Call | 🆔 Number | 🔧 Purpose        |
| -------------- | --------- | ----------------- |
| `sys_write`    | `4`       | Output to stdout  |
| `sys_read`     | `3`       | Input from stdin  |
| `sys_exit`     | `1`       | Terminate program |

---

## 📐 Register Usage Summary

| Register  | Usage                          |
| --------- | ------------------------------ |
| `r0`–`r3` | Arguments & return values      |
| `r4`–`r8` | Local variables (callee-saved) |
| `r7`      | System call identifier         |
| `lr`      | Return address for functions   |
| `sp`      | Stack pointer                  |

---

## 🔬 Assembly Concepts Demonstrated

* 📦 Addressing modes (immediate, register, memory)
* 🧠 Condition codes and branching
* 🔁 Looping and iteration
* 🧵 String manipulation at byte-level
* 🔧 Manual function call linkage
* 💻 OS-level system integration via syscall interface

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

---

## 👨‍💻 Individual Contributions

### ✍️ D.M.N.N. Bandara (E/22/044)

* *\[To be completed]*

### ✍️ K.B.A.D.G.C. Kapurubandara (E/22/180)

* *\[To be completed]*

---

## 🚧 Project Challenges and Solutions

### ⚠️ 1. Command Parsing Complexity

**Issue**: Token-based parsing broke with multi-word inputs
**Fix**: Switched to two-tier system (direct + token parsing)

### 🧠 2. Memory Management

**Issue**: Buffer overflows during string handling
**Fix**: Bounds checking and null termination everywhere

### 🔁 3. Register Conflicts

**Issue**: `mul` instruction register constraints
**Fix**: Careful register allocation and reuse


