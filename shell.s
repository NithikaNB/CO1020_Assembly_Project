@===============================================================================
@ ARM32 Assembly Command-Line Shell Project
@ 
@ Authors: Group 36
@   - D.M.N.N. Bandara (E/22/044)  
@   - K.B.A.D.G.C. Kapurubandara (E/22/180)
@
@ Course: CO1020 - Computer Systems Programming
@ Department: Computer Engineering, University of Peradeniya  
@
@ Description: A minimal interactive shell implementing basic commands and
@              two advanced custom commands demonstrating complex programming
@              concepts in ARM32 assembly language.
@===============================================================================

.data
    @---------------------------------------------------------------------------
    @ String literals and messages used by the shell
    @---------------------------------------------------------------------------
    prompt:         .asciz "shell> "           @ Command prompt displayed to user
    hello_msg:      .asciz "Hello World!\n"    @ Output for hello command
    
    @ Help message listing all available commands with descriptions
    help_msg:       .asciz "Available commands:\n  hello - Prints Hello World!\n  help - Lists all commands\n  exit - Terminates the shell\n  clear - Clears the screen\n  cipher - Caesar cipher encryption\n  freq - Character frequency analysis\n\n"
    
    exit_msg:       .asciz "Goodbye!\n"        @ Message displayed when exiting shell
    clear_seq:      .asciz "\033[2J\033[H"     @ ANSI escape sequence to clear screen and move cursor to home
    unknown_cmd:    .asciz "Unknown command. Type 'help' for available commands.\n"
    newline:        .asciz "\n"                @ Newline character for formatting output
    
    @---------------------------------------------------------------------------
    @ Caesar cipher command strings and messages  
    @---------------------------------------------------------------------------
    cipher_msg:     .asciz "Encrypted: "       @ Label for cipher output
    cipher_help:    .asciz "Usage: cipher <text> <shift>\nExample: cipher hello 3\n"
    
    @---------------------------------------------------------------------------
    @ Character frequency analysis command strings and messages
    @---------------------------------------------------------------------------
    freq_msg:       .asciz "Frequency: "       @ Label for frequency analysis output
    freq_help:      .asciz "Usage: freq <text>\nExample: freq hello\n"
    
    @---------------------------------------------------------------------------
    @ Command name strings used for string comparison during parsing
    @---------------------------------------------------------------------------
    cmd_hello:      .asciz "hello"             @ String to match for hello command
    cmd_help:       .asciz "help"              @ String to match for help command  
    cmd_exit:       .asciz "exit"              @ String to match for exit command
    cmd_clear:      .asciz "clear"             @ String to match for clear command
    cmd_cipher:     .asciz "cipher"            @ String to match for cipher command
    cmd_freq:       .asciz "freq"              @ String to match for frequency command

.bss
    @---------------------------------------------------------------------------
    @ Uninitialized memory buffers for runtime data storage
    @---------------------------------------------------------------------------
    input_buffer:   .space 256                 @ Buffer to store user input (255 chars + null terminator)
    token_buffer:   .space 64                  @ Buffer for tokenizing commands (63 chars + null terminator)
    cipher_buffer:  .space 256                 @ Buffer to store encrypted text output
    freq_counts:    .space 256                 @ Array for character frequency counting (one byte per ASCII character)
    freq_buffer:    .space 32                  @ Buffer for formatting frequency output strings

.text
.global main

@===============================================================================
@ MAIN PROGRAM ENTRY POINT
@===============================================================================

main:
    @---------------------------------------------------------------------------
    @ Main shell loop - continuously prompts user for input and processes commands
    @ This loop runs until the user enters the 'exit' command
    @---------------------------------------------------------------------------
    shell_loop:
        @ Display command prompt to user
        ldr r0, =prompt                       @ Load address of prompt string
        bl print_string                       @ Call function to print the prompt
        
        @ Read user input from standard input
        ldr r0, =input_buffer                 @ Load address of input buffer
        mov r1, #255                          @ Set maximum read size (leave room for null terminator)
        bl read_input                         @ Call function to read user input
        
        @ Check if read operation was successful
        cmp r0, #0                            @ Compare return value with 0
        ble shell_loop                        @ If read failed or empty, restart loop
        
        @ Clean up the input by removing newline characters
        ldr r0, =input_buffer                 @ Load address of input buffer
        bl remove_newline                     @ Remove trailing newline/carriage return
        
        @ Parse the command and execute appropriate handler
        ldr r0, =input_buffer                 @ Load address of input buffer
        bl parse_command                      @ Call command parser and dispatcher
        
        @ Continue the shell loop (exit command terminates program directly)
        b shell_loop                          @ Branch back to start of loop

@===============================================================================
@ SYSTEM INTERFACE FUNCTIONS
@ These functions handle low-level system calls for I/O operations
@===============================================================================

@-------------------------------------------------------------------------------
@ Function: print_string
@ Purpose:  Print a null-terminated string to standard output
@ Input:    r0 = pointer to null-terminated string
@ Output:   None
@ Uses:     Linux sys_write system call (syscall #4)
@-------------------------------------------------------------------------------
print_string:
    push {r1, r2, r7, lr}                      @ Save registers that will be modified
    mov r1, r0                                 @ Move string pointer to r1 for sys_write
    bl strlen                                  @ Calculate length of string
    mov r2, r0                                 @ Move length to r2 for sys_write
    mov r0, #1                                 @ File descriptor 1 (stdout)
    mov r7, #4                                 @ System call number for sys_write
    svc #0                                     @ Invoke system call
    pop {r1, r2, r7, lr}                       @ Restore saved registers
    bx lr                                      @ Return to caller

@-------------------------------------------------------------------------------
@ Function: read_input  
@ Purpose:  Read input from standard input into a buffer
@ Input:    r0 = pointer to buffer, r1 = maximum bytes to read
@ Output:   r0 = number of bytes read
@ Uses:     Linux sys_read system call (syscall #3)
@-------------------------------------------------------------------------------
read_input:
    push {r2, r7, lr}                          @ Save registers that will be modified
    mov r2, r1                                 @ Move buffer size to r2 for sys_read
    mov r1, r0                                 @ Move buffer pointer to r1 for sys_read
    mov r0, #0                                 @ File descriptor 0 (stdin)
    mov r7, #3                                 @ System call number for sys_read
    svc #0                                     @ Invoke system call
    pop {r2, r7, lr}                           @ Restore saved registers
    bx lr                                      @ Return to caller (r0 contains bytes read)

@===============================================================================
@ STRING PROCESSING UTILITY FUNCTIONS
@ These functions provide essential string manipulation capabilities
@===============================================================================

@-------------------------------------------------------------------------------
@ Function: strlen
@ Purpose:  Calculate the length of a null-terminated string
@ Input:    r0 = pointer to null-terminated string
@ Output:   r0 = length of string (not including null terminator)
@ Algorithm: Iterate through string counting bytes until null terminator found
@-------------------------------------------------------------------------------
strlen:
    push {r1, r2}                              @ Save registers that will be modified
    mov r1, r0                                 @ Copy string address to r1
    mov r2, #0                                 @ Initialize counter to 0
    
    strlen_loop:
        ldrb r0, [r1, r2]                      @ Load byte at position r2
        cmp r0, #0                             @ Check if byte is null terminator
        beq strlen_done                        @ If null found, exit loop
        add r2, r2, #1                         @ Increment counter
        b strlen_loop                          @ Continue loop
    
    strlen_done:
        mov r0, r2                             @ Move final count to return register
        pop {r1, r2}                           @ Restore saved registers
        bx lr                                  @ Return to caller

@-------------------------------------------------------------------------------
@ Function: remove_newline
@ Purpose:  Remove newline and carriage return characters from end of string
@ Input:    r0 = pointer to null-terminated string  
@ Output:   String is modified in place
@ Note:     This function handles both Unix (\n) and Windows (\r\n) line endings
@-------------------------------------------------------------------------------
remove_newline:
    push {r1, r2, lr}                          @ Save registers that will be modified
    mov r1, r0                                 @ Copy string address to r1
    mov r2, #0                                 @ Initialize index to 0
    
    remove_loop:
        ldrb r0, [r1, r2]                      @ Load byte at current position
        cmp r0, #0                             @ Check for null terminator
        beq remove_done                        @ If end of string, exit
        cmp r0, #10                            @ Check for newline character (ASCII 10)
        beq remove_newline_char                @ If newline found, remove it
        cmp r0, #13                            @ Check for carriage return (ASCII 13)
        beq remove_newline_char                @ If carriage return found, remove it
        add r2, r2, #1                         @ Move to next character
        b remove_loop                          @ Continue searching
    
    remove_newline_char:
        mov r0, #0                             @ Replace with null terminator
        strb r0, [r1, r2]                      @ Store null terminator at current position
    
    remove_done:
        pop {r1, r2, lr}                       @ Restore saved registers
        bx lr                                  @ Return to caller

@-------------------------------------------------------------------------------
@ Function: strcmp
@ Purpose:  Compare two null-terminated strings for equality
@ Input:    r0 = pointer to first string, r1 = pointer to second string
@ Output:   r0 = 0 if strings are equal, 1 if different
@ Algorithm: Compare strings byte by byte until difference found or both end
@-------------------------------------------------------------------------------
strcmp:
    push {r2, r3}                              @ Save registers that will be modified
    
    strcmp_loop:
        ldrb r2, [r0], #1                      @ Load byte from first string and increment pointer
        ldrb r3, [r1], #1                      @ Load byte from second string and increment pointer
        cmp r2, r3                             @ Compare the two bytes
        bne strcmp_not_equal                   @ If different, strings are not equal
        cmp r2, #0                             @ Check if we've reached end of strings
        bne strcmp_loop                        @ If not at end, continue comparing
        
        @ Strings are equal (reached end of both strings)
        mov r0, #0                             @ Return 0 to indicate equality
        b strcmp_done
    
    strcmp_not_equal:
        mov r0, #1                             @ Return 1 to indicate difference
    
    strcmp_done:
        pop {r2, r3}                           @ Restore saved registers
        bx lr                                  @ Return to caller

@===============================================================================
@ COMMAND PARSING AND DISPATCH SYSTEM
@ These functions handle parsing user input and routing to appropriate commands
@===============================================================================

@-------------------------------------------------------------------------------
@ Function: parse_command
@ Purpose:  Parse user input and dispatch to appropriate command handler
@ Input:    r0 = pointer to input string
@ Output:   Command is executed, r0 = 0 (continue shell) or program exits
@ Algorithm: 1. Check for empty input
@           2. Extract first token (command name)  
@           3. Compare with known commands
@           4. Dispatch to appropriate handler
@-------------------------------------------------------------------------------
parse_command:
    push {r4, r5, lr}                          @ Save registers and return address
    mov r4, r0                                 @ Save input pointer in r4
    
    @ Check for empty command (user just pressed Enter)
    ldrb r5, [r4]                              @ Load first character
    cmp r5, #0                                 @ Check if string is empty
    beq parse_done_normal                      @ If empty, return to shell loop
    
    @ Extract first token (command name) from input
    mov r0, r4                                 @ Load input pointer
    ldr r1, =token_buffer                      @ Load address of token buffer
    bl extract_token                           @ Extract first word into token buffer
    
    @---------------------------------------------------------------------------
    @ Command matching section - compare extracted token with known commands
    @ Each command comparison follows the same pattern:
    @ 1. Load token and command string addresses
    @ 2. Call strcmp to compare
    @ 3. Branch to handler if match found (strcmp returns 0 for equality)
    @---------------------------------------------------------------------------
    
    @ Check for "hello" command
    ldr r0, =token_buffer                      @ Load token buffer address
    ldr r1, =cmd_hello                         @ Load "hello" string address
    bl strcmp                                  @ Compare strings
    cmp r0, #0                                 @ Check if strings are equal
    beq cmd_hello_found                        @ If equal, execute hello command
    
    @ Check for "help" command
    ldr r0, =token_buffer
    ldr r1, =cmd_help
    bl strcmp
    cmp r0, #0
    beq cmd_help_found
    
    @ Check for "exit" command
    ldr r0, =token_buffer
    ldr r1, =cmd_exit
    bl strcmp
    cmp r0, #0
    beq cmd_exit_found
    
    @ Check for "clear" command
    ldr r0, =token_buffer
    ldr r1, =cmd_clear
    bl strcmp
    cmp r0, #0
    beq cmd_clear_found
    
    @ Check for "cipher" command (Caesar cipher encryption)
    ldr r0, =token_buffer
    ldr r1, =cmd_cipher
    bl strcmp
    cmp r0, #0
    beq cmd_cipher_found
    
    @ Check for "freq" command (character frequency analysis)
    ldr r0, =token_buffer
    ldr r1, =cmd_freq
    bl strcmp
    cmp r0, #0
    beq cmd_freq_found
    
    @ No matching command found - display error message
    ldr r0, =unknown_cmd                       @ Load unknown command message
    bl print_string                           @ Display error message
    b parse_done_normal                        @ Return to shell loop
    
    @---------------------------------------------------------------------------
    @ Command dispatch section - branch to appropriate command handlers
    @ Each handler is called and execution returns to shell loop afterward
    @---------------------------------------------------------------------------
    
    cmd_hello_found:
        bl cmd_hello_handler                   @ Execute hello command
        b parse_done_normal                    @ Return to shell loop
    
    cmd_help_found:
        bl cmd_help_handler                    @ Execute help command
        b parse_done_normal                    @ Return to shell loop
    
    cmd_exit_found:
        bl cmd_exit_handler                    @ Execute exit command (terminates program)
        b parse_done_normal                    @ This line never reached
    
    cmd_clear_found:
        bl cmd_clear_handler                   @ Execute clear command
        b parse_done_normal                    @ Return to shell loop
    
    cmd_cipher_found:
        bl cmd_cipher_handler                  @ Execute cipher command
        b parse_done_normal                    @ Return to shell loop
    
    cmd_freq_found:
        bl cmd_freq_handler                    @ Execute frequency analysis command
        b parse_done_normal                    @ Return to shell loop
    
    parse_done_normal:
        mov r0, #0                             @ Set return value (continue shell loop)
        pop {r4, r5, lr}                       @ Restore saved registers
        bx lr                                  @ Return to caller

@-------------------------------------------------------------------------------
@ Function: extract_token
@ Purpose:  Extract the first whitespace-delimited token from a string
@ Input:    r0 = pointer to source string, r1 = pointer to destination buffer
@ Output:   First token is copied to destination buffer, null-terminated
@ Algorithm: 1. Skip leading whitespace
@           2. Copy characters until whitespace or end of string
@           3. Null-terminate the extracted token
@ Safety:   Includes bounds checking to prevent buffer overflow
@-------------------------------------------------------------------------------
extract_token:
    push {r2, r3, r4}                          @ Save registers that will be modified
    mov r2, #0                                 @ Initialize source index
    mov r3, #0                                 @ Initialize destination index
    
    @ Skip any leading whitespace characters
    skip_spaces:
        cmp r2, #250                           @ Check bounds to prevent reading past buffer
        bge token_done                         @ If near end of buffer, stop
        ldrb r4, [r0, r2]                      @ Load character at current position
        cmp r4, #0                             @ Check for end of string
        beq token_done                         @ If end reached, finish extraction
        cmp r4, #32                            @ Check if character is space (ASCII 32)
        bne copy_token                         @ If not space, start copying token
        add r2, r2, #1                         @ Move to next character
        b skip_spaces                          @ Continue skipping spaces
    
    @ Copy characters from source to destination until delimiter found
    copy_token:
        cmp r2, #250                           @ Check source bounds
        bge token_done                         @ If near end, stop copying
        cmp r3, #63                            @ Check destination bounds (leave room for null)
        bge token_done                         @ If destination nearly full, stop
        ldrb r4, [r0, r2]                      @ Load character from source
        cmp r4, #0                             @ Check for end of string
        beq token_done                         @ If end reached, finish token
        cmp r4, #32                            @ Check for space character
        beq token_done                         @ If space found, finish token
        strb r4, [r1, r3]                      @ Store character in destination
        add r2, r2, #1                         @ Move to next source character
        add r3, r3, #1                         @ Move to next destination position
        b copy_token                           @ Continue copying
    
    @ Finish token extraction by adding null terminator
    token_done:
        cmp r3, #63                            @ Check if destination buffer is full
        bge token_done_safe                    @ If full, use safer termination
        mov r4, #0                             @ Load null terminator
        strb r4, [r1, r3]                      @ Store null terminator at current position
        b token_done_exit
        
    token_done_safe:
        mov r4, #0                             @ Load null terminator
        strb r4, [r1, #63]                     @ Force null terminator at end of buffer
    
    token_done_exit:
        pop {r2, r3, r4}                       @ Restore saved registers
        bx lr                                  @ Return to caller

@===============================================================================
@ BASIC COMMAND HANDLERS
@ These functions implement the basic shell commands
@===============================================================================

@-------------------------------------------------------------------------------
@ Function: cmd_hello_handler
@ Purpose:  Handle the "hello" command by printing "Hello World!"
@ Input:    None
@ Output:   Prints "Hello World!" message to stdout
@-------------------------------------------------------------------------------
cmd_hello_handler:
    push {lr}                                  @ Save return address
    ldr r0, =hello_msg                         @ Load address of hello message
    bl print_string                           @ Print the message
    pop {lr}                                   @ Restore return address
    bx lr                                      @ Return to caller

@-------------------------------------------------------------------------------
@ Function: cmd_help_handler  
@ Purpose:  Handle the "help" command by displaying available commands
@ Input:    None
@ Output:   Prints list of all available commands with descriptions
@-------------------------------------------------------------------------------
cmd_help_handler:
    push {lr}                                  @ Save return address
    ldr r0, =help_msg                          @ Load address of help message
    bl print_string                           @ Print the help text
    pop {lr}                                   @ Restore return address
    bx lr                                      @ Return to caller

@-------------------------------------------------------------------------------
@ Function: cmd_exit_handler
@ Purpose:  Handle the "exit" command by terminating the shell
@ Input:    None  
@ Output:   Prints goodbye message and terminates program
@ Note:     This function does not return - it exits the program directly
@-------------------------------------------------------------------------------
cmd_exit_handler:
    push {lr}                                  @ Save return address (for consistency)
    ldr r0, =exit_msg                          @ Load address of goodbye message
    bl print_string                           @ Print the goodbye message
    pop {lr}                                   @ Restore return address
    
    @ Terminate the program using Linux exit system call
    mov r0, #0                                 @ Set exit status to 0 (success)
    mov r7, #1                                 @ System call number for sys_exit
    svc #0                                     @ Invoke system call (program terminates here)

@-------------------------------------------------------------------------------
@ Function: cmd_clear_handler
@ Purpose:  Handle the "clear" command by clearing the terminal screen
@ Input:    None
@ Output:   Sends ANSI escape sequence to clear screen and reset cursor
@ Note:     Uses ANSI escape sequence "\033[2J\033[H" for screen clearing
@-------------------------------------------------------------------------------
cmd_clear_handler:
    push {lr}                                  @ Save return address
    ldr r0, =clear_seq                         @ Load address of ANSI clear sequence
    bl print_string                           @ Send escape sequence to terminal
    pop {lr}                                   @ Restore return address
    bx lr                                      @ Return to caller

@===============================================================================
@ ADVANCED CUSTOM COMMANDS
@ These functions implement sophisticated algorithms demonstrating complex
@ programming concepts beyond basic shell operations
@===============================================================================

@-------------------------------------------------------------------------------
@ Function: cmd_freq_handler
@ Purpose:  Analyze character frequency in user-provided text
@ Input:    Text to analyze follows "freq " in the input buffer
@ Output:   Displays frequency count for each character in format 'char':count
@ Algorithm: 1. Parse input to extract text after "freq "
@           2. Initialize frequency counter array  
@           3. Count occurrences of each printable character
@           4. Display results in formatted output
@ Demonstrates: Array operations, data analysis, formatted output
@-------------------------------------------------------------------------------
cmd_freq_handler:
    push {r4, r5, r6, r7, lr}                 @ Save registers and return address
    
    @---------------------------------------------------------------------------
    @ Input parsing phase - extract text to analyze from command line
    @---------------------------------------------------------------------------
    ldr r4, =input_buffer                     @ Load input buffer address
    add r4, r4, #4                            @ Skip past "freq" command (4 characters)
    
    @ Skip whitespace between command and text
    freq_skip_spaces:
        ldrb r0, [r4]                         @ Load character at current position
        cmp r0, #0                            @ Check if end of input reached
        beq freq_show_help                    @ If no text provided, show usage help
        cmp r0, #32                           @ Check if character is space
        bne freq_start_analysis               @ If non-space found, start analysis
        add r4, r4, #1                        @ Move to next character
        b freq_skip_spaces                    @ Continue skipping spaces
    
    freq_start_analysis:
        @-----------------------------------------------------------------------
        @ Initialization phase - prepare frequency counting array
        @ We use only 95 bytes for printable ASCII characters (32-126)
        @ This is safer than using full 256-byte array
        @-----------------------------------------------------------------------
        ldr r5, =freq_counts                  @ Load address of frequency counter array
        mov r6, #0                            @ Initialize array index to 0
        
        @ Clear frequency counter array (set all counts to zero)
        clear_freq_loop:
            cmp r6, #95                       @ Check if processed all printable chars (126-32+1=95)
            bge freq_count_chars              @ If array cleared, proceed to counting
            mov r0, #0                        @ Load zero value
            strb r0, [r5, r6]                 @ Store zero at current array position
            add r6, r6, #1                    @ Move to next array position
            b clear_freq_loop                 @ Continue clearing array
        
        @-----------------------------------------------------------------------
        @ Counting phase - iterate through text and count character frequencies
        @-----------------------------------------------------------------------
        freq_count_chars:
            mov r6, r4                        @ Set r6 to current position in input text
            
            count_loop:
                ldrb r0, [r6]                 @ Load character from input text
                cmp r0, #0                    @ Check if end of string reached
                beq freq_display_results      @ If end reached, proceed to display results
                
                @ Validate character is in printable ASCII range
                cmp r0, #32                   @ Check if below space character
                blt freq_next_char_count      @ If below range, skip this character
                cmp r0, #126                  @ Check if above tilde character  
                bgt freq_next_char_count      @ If above range, skip this character
                
                @ Calculate array index and increment counter
                sub r7, r0, #32               @ Convert ASCII to array index (char - 32)
                ldrb r1, [r5, r7]             @ Load current count for this character
                add r1, r1, #1                @ Increment count
                cmp r1, #9                    @ Limit count to single digit for display
                bgt freq_next_char_count      @ If count too high, skip increment
                strb r1, [r5, r7]             @ Store updated count back to array
                
                freq_next_char_count:
                    add r6, r6, #1            @ Move to next character in input
                    b count_loop              @ Continue counting
        
        @-----------------------------------------------------------------------
        @ Display phase - output frequency analysis results in formatted form
        @-----------------------------------------------------------------------
        freq_display_results:
            @ Print header for frequency analysis results
            ldr r0, =freq_msg                 @ Load "Frequency: " message
            bl print_string                   @ Display the header
            
            @ Iterate through frequency array to display non-zero counts
            mov r6, #0                        @ Initialize array index
            
            display_loop:
                cmp r6, #95                   @ Check if processed all printable characters
                bge freq_done_display         @ If done with all characters, finish display
                
                ldrb r0, [r5, r6]             @ Load frequency count for current character
                cmp r0, #0                    @ Check if count is zero
                beq freq_next_display         @ If zero, skip this character
                
                @ Calculate actual ASCII character value
                add r7, r6, #32               @ Convert array index back to ASCII (index + 32)
                
                @---------------------------------------------------------------
                @ Format and display: 'char':count 
                @ Creates output like 'h':1 'e':2 etc.
                @---------------------------------------------------------------
                ldr r4, =freq_buffer          @ Load address of formatting buffer
                mov r0, #39                   @ Load single quote character (')
                strb r0, [r4]                 @ Store opening quote
                strb r7, [r4, #1]             @ Store the actual character
                mov r0, #39                   @ Load single quote character (')
                strb r0, [r4, #2]             @ Store closing quote
                mov r0, #58                   @ Load colon character (:)
                strb r0, [r4, #3]             @ Store colon separator
                ldrb r0, [r5, r6]             @ Load frequency count
                add r0, r0, #48               @ Convert count to ASCII digit (0-9)
                strb r0, [r4, #4]             @ Store count digit
                mov r0, #32                   @ Load space character
                strb r0, [r4, #5]             @ Store space separator
                mov r0, #0                    @ Load null terminator
                strb r0, [r4, #6]             @ Null-terminate the formatted string
                
                @ Display the formatted character frequency
                ldr r0, =freq_buffer          @ Load formatted string address
                bl print_string               @ Print the formatted output
                
                freq_next_display:
                    add r6, r6, #1            @ Move to next character in frequency array
                    b display_loop            @ Continue display loop
            
            freq_done_display:
                ldr r0, =newline              @ Load newline character
                bl print_string               @ Print newline to finish output
                b freq_exit                   @ Jump to function cleanup
    
    @---------------------------------------------------------------------------
    @ Error handling - display usage help if invalid input provided
    @---------------------------------------------------------------------------
    freq_show_help:
        ldr r0, =freq_help                    @ Load usage help message
        bl print_string                       @ Display help text
    
    freq_exit:
        pop {r4, r5, r6, r7, lr}              @ Restore all saved registers
        bx lr                                 @ Return to caller

@-------------------------------------------------------------------------------
@ Function: cmd_cipher_handler
@ Purpose:  Implement Caesar cipher encryption on user-provided text
@ Input:    Text and shift value follow "cipher " in input buffer
@ Format:   cipher <text> <shift_number>
@ Output:   Displays encrypted text using Caesar cipher algorithm
@ Algorithm: 1. Parse input to extract text and shift value
@           2. Apply Caesar cipher transformation to each alphabetic character
@           3. Preserve case and leave non-alphabetic characters unchanged
@           4. Display encrypted result
@ Demonstrates: String parsing, mathematical operations, character manipulation
@-------------------------------------------------------------------------------
cmd_cipher_handler:
    push {r4, r5, r6, r7, r8, lr}             @ Save registers and return address
    
    @---------------------------------------------------------------------------
    @ Input parsing phase - extract text and shift value from command line
    @---------------------------------------------------------------------------
    ldr r4, =input_buffer                     @ Load input buffer address
    add r4, r4, #6                            @ Skip past "cipher" command (6 characters)
    
    @ Skip whitespace after command name
    cipher_skip_initial_spaces:
        ldrb r0, [r4]                         @ Load character at current position
        cmp r0, #0                            @ Check if end of input reached
        beq cipher_show_help                  @ If no arguments provided, show help
        cmp r0, #32                           @ Check if character is space
        bne cipher_find_text_start            @ If non-space found, start parsing
        add r4, r4, #1                        @ Move to next character
        b cipher_skip_initial_spaces          @ Continue skipping spaces
    
    cipher_find_text_start:
        @-----------------------------------------------------------------------
        @ Parse command arguments - separate text from shift number
        @ Expected format: cipher <text> <shift>
        @ Strategy: Find last space which separates text from shift number
        @-----------------------------------------------------------------------
        mov r5, r4                            @ Set r5 to start of arguments
        mov r6, r4                            @ Set r6 to current scan position
        mov r7, r4                            @ Set r7 to last space position (initially start)
        
        @ Scan through arguments to find the last space
        cipher_find_last_space:
            ldrb r0, [r6]                     @ Load character at current position
            cmp r0, #0                        @ Check if end of string reached
            beq cipher_parse_shift            @ If end reached, parse shift value
            cmp r0, #32                       @ Check if current character is space
            bne cipher_continue_search        @ If not space, continue searching
            mov r7, r6                        @ Remember position of this space
            
        cipher_continue_search:
            add r6, r6, #1                    @ Move to next character
            b cipher_find_last_space          @ Continue searching for spaces
        
        cipher_parse_shift:
            @ Validate that we found a space (meaning we have both text and shift)
            cmp r7, r5                        @ Compare last space position with start
            beq cipher_show_help              @ If no space found, show usage help
            
            @-------------------------------------------------------------------
            @ Extract and parse the shift number from after the last space
            @-------------------------------------------------------------------
            add r8, r7, #1                    @ Set r8 to position after last space
            bl simple_parse_shift_number      @ Parse shift number from position r8
            cmp r0, #-1                       @ Check if parsing failed
            beq cipher_show_help              @ If parsing failed, show usage help
            mov r8, r0                        @ Store parsed shift value in r8
            
            @-------------------------------------------------------------------
            @ Apply Caesar cipher encryption to the text portion
            @ Text spans from r5 (start) to r7 (last space, exclusive)
            @-------------------------------------------------------------------
            bl apply_caesar_cipher            @ Apply cipher transformation to text
            
            @ Display the encryption results
            ldr r0, =cipher_msg               @ Load "Encrypted: " message
            bl print_string                   @ Display result header
            ldr r0, =cipher_buffer            @ Load address of encrypted text buffer
            bl print_string                   @ Display the encrypted text
            ldr r0, =newline                  @ Load newline character
            bl print_string                   @ Print newline to finish output
            
            b cipher_done                     @ Jump to function cleanup
    
    @---------------------------------------------------------------------------
    @ Error handling - display usage help for invalid input
    @---------------------------------------------------------------------------
    cipher_show_help:
        ldr r0, =cipher_help                  @ Load usage help message
        bl print_string                       @ Display help text
    
    cipher_done:
        pop {r4, r5, r6, r7, r8, lr}          @ Restore all saved registers
        bx lr                                 @ Return to caller

@===============================================================================
@ CAESAR CIPHER SUPPORT FUNCTIONS
@ These functions implement the mathematical and string processing logic
@ required for Caesar cipher encryption
@===============================================================================

@-------------------------------------------------------------------------------
@ Function: simple_parse_shift_number
@ Purpose:  Parse decimal shift number from string at position r8
@ Input:    r8 = pointer to string containing decimal number
@ Output:   r0 = parsed number (0-25), or -1 if parsing failed
@ Algorithm: 1. Skip leading whitespace
@           2. Convert ASCII digits to decimal number
@           3. Validate number is in acceptable range (0-25)
@ Safety:   Includes bounds checking and input validation
@-------------------------------------------------------------------------------
simple_parse_shift_number:
    push {r1, r2, r3, r9}                     @ Save registers (using r9 to avoid conflicts)
    mov r0, #0                                @ Initialize result accumulator
    mov r9, #0                                @ Initialize digit counter
    
    @ Skip any leading whitespace before the number
    shift_skip_spaces:
        ldrb r2, [r8]                         @ Load character at current position
        cmp r2, #32                           @ Check if character is space
        bne shift_parse_digits                @ If not space, start parsing digits
        cmp r2, #0                            @ Check if end of string reached
        beq shift_parse_error                 @ If end reached without digits, error
        add r8, r8, #1                        @ Move to next character
        b shift_skip_spaces                   @ Continue skipping spaces
    
    @ Parse decimal digits and accumulate result
    shift_parse_digits:
        ldrb r2, [r8]                         @ Load character at current position
        cmp r2, #48                           @ Check if below '0' (ASCII 48)
        blt shift_parse_done                  @ If below '0', stop parsing
        cmp r2, #57                           @ Check if above '9' (ASCII 57)
        bgt shift_parse_done                  @ If above '9', stop parsing
        
        @ Convert ASCII digit to number and add to result
        sub r2, r2, #48                       @ Convert ASCII digit to numeric value
        mov r3, #10                           @ Load decimal base multiplier
        mul r1, r0, r3                        @ Multiply current result by 10
        mov r0, r1                            @ Store multiplied result
        add r0, r0, r2                        @ Add new digit to result
        add r8, r8, #1                        @ Move to next character
        add r9, r9, #1                        @ Increment digit counter
        b shift_parse_digits                  @ Continue parsing digits
    
    shift_parse_done:
        cmp r9, #0                            @ Check if any digits were parsed
        beq shift_parse_error                 @ If no digits found, return error
        cmp r0, #25                           @ Check if number exceeds maximum shift
        bgt shift_parse_error                 @ If too large, return error
        b shift_parse_exit                    @ Success - exit with parsed number
        
    shift_parse_error:
        mov r0, #-1                           @ Set return value to indicate error
    
    shift_parse_exit:
        pop {r1, r2, r3, r9}                  @ Restore saved registers
        bx lr                                 @ Return to caller

@-------------------------------------------------------------------------------
@ Function: apply_caesar_cipher
@ Purpose:  Apply Caesar cipher transformation to text segment
@ Input:    r5 = start of text, r7 = end of text, r8 = shift value
@ Output:   Encrypted text stored in cipher_buffer
@ Algorithm: 1. Initialize output buffer
@           2. Process each character in input range
@           3. Apply shift to alphabetic characters (preserve case)
@           4. Leave non-alphabetic characters unchanged
@           5. Handle alphabet wraparound (z+1 becomes a)
@ Demonstrates: Character classification, modular arithmetic, case preservation
@-------------------------------------------------------------------------------
apply_caesar_cipher:
    push {r1, r2, r3, r4}                     @ Save registers that will be modified
    ldr r1, =cipher_buffer                    @ Load address of output buffer
    mov r2, #0                                @ Initialize output buffer index
    mov r3, r5                                @ Initialize input position to text start
    
    @---------------------------------------------------------------------------
    @ Main encryption loop - process each character in the input text
    @---------------------------------------------------------------------------
    cipher_loop:
        cmp r3, r7                            @ Check if reached end of text
        bge cipher_apply_done                 @ If at end, finish encryption
        cmp r2, #250                          @ Check output buffer bounds
        bge cipher_apply_done                 @ If buffer nearly full, stop
        
        ldrb r4, [r3]                         @ Load current character from input
        
        @-----------------------------------------------------------------------
        @ Process lowercase letters (a-z) with Caesar cipher
        @-----------------------------------------------------------------------
        cmp r4, #97                           @ Check if below 'a' (ASCII 97)
        blt cipher_check_upper                @ If below 'a', check if uppercase
        cmp r4, #122                          @ Check if above 'z' (ASCII 122)
        bgt cipher_check_upper                @ If above 'z', check if uppercase
        
        @ Apply Caesar cipher to lowercase letter
        sub r4, r4, #97                       @ Convert to range 0-25 (a=0, b=1, etc.)
        add r4, r4, r8                        @ Add shift value
        cmp r4, #25                           @ Check if result exceeds 'z'
        ble cipher_lower_ok                   @ If within range, proceed
        sub r4, r4, #26                       @ Wrap around alphabet (subtract 26)
        
        cipher_lower_ok:
        add r4, r4, #97                       @ Convert back to ASCII lowercase
        b cipher_store_char                   @ Store the encrypted character
        
        @-----------------------------------------------------------------------
        @ Process uppercase letters (A-Z) with Caesar cipher  
        @-----------------------------------------------------------------------
        cipher_check_upper:
        cmp r4, #65                           @ Check if below 'A' (ASCII 65)
        blt cipher_no_change                  @ If below 'A', leave unchanged
        cmp r4, #90                           @ Check if above 'Z' (ASCII 90)
        bgt cipher_no_change                  @ If above 'Z', leave unchanged
        
        @ Apply Caesar cipher to uppercase letter
        sub r4, r4, #65                       @ Convert to range 0-25 (A=0, B=1, etc.)
        add r4, r4, r8                        @ Add shift value
        cmp r4, #25                           @ Check if result exceeds 'Z'
        ble cipher_upper_ok                   @ If within range, proceed
        sub r4, r4, #26                       @ Wrap around alphabet (subtract 26)
        
        cipher_upper_ok:
        add r4, r4, #65                       @ Convert back to ASCII uppercase
        b cipher_store_char                   @ Store the encrypted character
        
        @-----------------------------------------------------------------------
        @ Non-alphabetic characters are left unchanged (spaces, punctuation, etc.)
        @-----------------------------------------------------------------------
        cipher_no_change:
        @ Character is not alphabetic - store without modification
        
        cipher_store_char:
        strb r4, [r1, r2]                     @ Store processed character in output buffer
        add r2, r2, #1                        @ Move to next output position
        add r3, r3, #1                        @ Move to next input character
        b cipher_loop                         @ Continue processing characters
    
    @---------------------------------------------------------------------------
    @ Finalize encrypted text by adding null terminator
    @---------------------------------------------------------------------------
    cipher_apply_done:
        mov r4, #0                            @ Load null terminator
        strb r4, [r1, r2]                     @ Add null terminator to output string
        pop {r1, r2, r3, r4}                  @ Restore saved registers
        bx lr                                 @ Return to caller

@===============================================================================
@ GNU STACK NOTE
@ This section informs the linker about executable stack requirements
@ Required for modern Linux systems for security purposes
@===============================================================================
.section .note.GNU-stack,"",%progbits         @ Mark stack as non-executable for security