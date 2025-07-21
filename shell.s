.data
    prompt:         .asciz "shell> "           @ Command prompt
    hello_msg:      .asciz "Hello World!\n"    @ Hello command output
    help_msg:       .asciz "Available commands:\n  hello - Prints Hello World!\n  help - Lists all commands\n  exit - Terminates the shell\n  clear - Clears the screen\n  reverse - Reverses your text\n  cipher - Caesar cipher encryption\n\n"
    exit_msg:       .asciz "Goodbye!\n"        @ Exit message
    clear_seq:      .asciz "\033[2J\033[H"     @ ANSI clear screen sequence
    unknown_cmd:    .asciz "Unknown command. Type 'help' for available commands.\n"
    reverse_msg:    .asciz "Reversed: "
    cipher_msg:     .asciz "Encrypted: "
    cipher_help:    .asciz "Usage: cipher <text> <shift>\nExample: cipher hello 3\n"
    newline:        .asciz "\n"
    
    @ Command strings for comparison
    cmd_hello:      .asciz "hello"
    cmd_help:       .asciz "help"
    cmd_exit:       .asciz "exit"
    cmd_clear:      .asciz "clear"
    cmd_reverse:    .asciz "reverse"
    cmd_cipher:     .asciz "cipher"

.bss
    input_buffer:   .space 256                 @ Buffer for user input
    token_buffer:   .space 64                  @ Buffer for tokenizing
    reverse_buffer: .space 256                 @ Buffer for reverse command
    cipher_buffer:  .space 256                 @ Buffer for cipher command

.text
.global main

main:
    @ Main shell loop
    shell_loop:
        @ Print prompt
        ldr r0, =prompt
        bl print_string
        
        @ Read user input
        ldr r0, =input_buffer
        mov r1, #255
        bl read_input
        
        @ Check if read was successful
        cmp r0, #0
        ble shell_loop
        
        @ Remove newline from input
        ldr r0, =input_buffer
        bl remove_newline
        
        @ Parse and execute command
        ldr r0, =input_buffer
        bl parse_command
        
        @ Continue loop (exit command will terminate directly)
        b shell_loop

@ Function to print string
print_string:
    push {r1, r2, r7, lr}                      @ Save registers
    mov r1, r0                                 @ String to print
    bl strlen                                  @ Get string length
    mov r2, r0                                 @ Length in r2
    mov r0, #1                                 @ stdout
    mov r7, #4                                 @ sys_write
    svc #0                                     @ System call
    pop {r1, r2, r7, lr}                       @ Restore registers
    bx lr

@ Function to read input
read_input:
    push {r2, r7, lr}                          @ Save registers
    mov r2, r1                                 @ Buffer size
    mov r1, r0                                 @ Buffer
    mov r0, #0                                 @ stdin
    mov r7, #3                                 @ sys_read
    svc #0                                     @ System call
    pop {r2, r7, lr}                           @ Restore registers
    bx lr

@ Function to calculate string length
strlen:
    push {r1, r2}                              @ Save registers
    mov r1, r0                                 @ Copy string address
    mov r2, #0                                 @ Counter
    strlen_loop:
        ldrb r0, [r1, r2]                      @ Load byte
        cmp r0, #0                             @ Check for null terminator
        beq strlen_done
        add r2, r2, #1                         @ Increment counter
        b strlen_loop
    strlen_done:
        mov r0, r2                             @ Return length
        pop {r1, r2}                           @ Restore registers
        bx lr

@ Function to remove newline character
remove_newline:
    push {r1, r2, lr}                          @ Save registers
    mov r1, r0                                 @ Copy string address
    mov r2, #0                                 @ Index
    remove_loop:
        ldrb r0, [r1, r2]                      @ Load byte
        cmp r0, #0                             @ Check for null terminator
        beq remove_done
        cmp r0, #10                            @ Check for newline (ASCII 10)
        beq remove_newline_char
        cmp r0, #13                            @ Check for carriage return (ASCII 13)
        beq remove_newline_char
        add r2, r2, #1                         @ Increment index
        b remove_loop
    remove_newline_char:
        mov r0, #0                             @ Null terminator
        strb r0, [r1, r2]                      @ Replace newline with null
    remove_done:
        pop {r1, r2, lr}                       @ Restore registers
        bx lr

@ Function to compare strings
strcmp:
    push {r2, r3}                              @ Save registers
    strcmp_loop:
        ldrb r2, [r0], #1                      @ Load byte from first string
        ldrb r3, [r1], #1                      @ Load byte from second string
        cmp r2, r3                             @ Compare bytes
        bne strcmp_not_equal
        cmp r2, #0                             @ Check for end of string
        bne strcmp_loop
        mov r0, #0                             @ Strings are equal
        b strcmp_done
    strcmp_not_equal:
        mov r0, #1                             @ Strings are not equal
    strcmp_done:
        pop {r2, r3}                           @ Restore registers
        bx lr

@ Function to parse and execute commands
parse_command:
    push {r4, r5, lr}                          @ Save registers
    mov r4, r0                                 @ Save input pointer
    
    @ Check for empty command
    ldrb r5, [r4]
    cmp r5, #0
    beq parse_done_normal
    
    @ Check for cipher command first (special handling)
    bl check_cipher_command
    cmp r0, #1
    beq handle_cipher_special
    
    @ Extract first token (command) for other commands
    mov r0, r4
    ldr r1, =token_buffer
    bl extract_token
    
    @ Compare with known commands (excluding reverse)
    ldr r0, =token_buffer
    ldr r1, =cmd_hello
    bl strcmp
    cmp r0, #0
    beq cmd_hello_found
    
    ldr r0, =token_buffer
    ldr r1, =cmd_help
    bl strcmp
    cmp r0, #0
    beq cmd_help_found
    
    ldr r0, =token_buffer
    ldr r1, =cmd_exit
    bl strcmp
    cmp r0, #0
    beq cmd_exit_found
    
    ldr r0, =token_buffer
    ldr r1, =cmd_clear
    bl strcmp
    cmp r0, #0
    beq cmd_clear_found
    
    ldr r0, =token_buffer
    ldr r1, =cmd_cipher
    bl strcmp
    cmp r0, #0
    beq cmd_cipher_found
    
    @ Unknown command
    ldr r0, =unknown_cmd
    bl print_string
    b parse_done_normal
    
    handle_cipher_special:
        bl cmd_cipher_handler
        b parse_done_normal
    
    handle_reverse_special:
        bl cmd_reverse_handler
        b parse_done_normal
    
    cmd_hello_found:
        bl cmd_hello_handler
        b parse_done_normal
    
    cmd_help_found:
        bl cmd_help_handler
        b parse_done_normal
    
    cmd_exit_found:
        bl cmd_exit_handler
        b parse_done_normal
    
    cmd_clear_found:
        bl cmd_clear_handler
        b parse_done_normal
    
    cmd_cipher_found:
        bl cmd_cipher_handler
        b parse_done_normal
    
    parse_done_normal:
        mov r0, #0                             @ Return 0 to continue
        pop {r4, r5, lr}                       @ Restore registers
        bx lr

@ Function to extract first token from string
extract_token:
    push {r2, r3, r4}                          @ Save registers
    mov r2, #0                                 @ Index for source
    mov r3, #0                                 @ Index for destination
    
    @ Skip leading spaces
    skip_spaces:
        cmp r2, #250                           @ Prevent reading past buffer
        bge token_done
        ldrb r4, [r0, r2]
        cmp r4, #0                             @ Check for end first
        beq token_done
        cmp r4, #32                            @ Space character
        bne copy_token
        add r2, r2, #1
        b skip_spaces
    
    @ Copy token until space or null
    copy_token:
        cmp r2, #250                           @ Prevent reading past buffer
        bge token_done
        cmp r3, #63                            @ Prevent writing past token buffer
        bge token_done
        ldrb r4, [r0, r2]
        cmp r4, #0                             @ Null terminator
        beq token_done
        cmp r4, #32                            @ Space character
        beq token_done
        strb r4, [r1, r3]                      @ Store character
        add r2, r2, #1
        add r3, r3, #1
        b copy_token
    
    token_done:
        cmp r3, #63                            @ Check bounds
        bge token_done_safe
        mov r4, #0                             @ Null terminator
        strb r4, [r1, r3]                      @ Terminate string
        b token_done_exit
    token_done_safe:
        mov r4, #0
        strb r4, [r1, #63]                     @ Force terminate at end
    token_done_exit:
        pop {r2, r3, r4}                       @ Restore registers
        bx lr

@ Check if command starts with "cipher"
check_cipher_command:
    push {r1, r2, r3}
    mov r1, r0                                @ Input pointer
    
    @ Check first 6 characters for "cipher"
    ldrb r2, [r1]
    cmp r2, #99                               @ 'c'
    bne not_cipher
    ldrb r2, [r1, #1]
    cmp r2, #105                              @ 'i'
    bne not_cipher
    ldrb r2, [r1, #2]
    cmp r2, #112                              @ 'p'
    bne not_cipher
    ldrb r2, [r1, #3]
    cmp r2, #104                              @ 'h'
    bne not_cipher
    ldrb r2, [r1, #4]
    cmp r2, #101                              @ 'e'
    bne not_cipher
    ldrb r2, [r1, #5]
    cmp r2, #114                              @ 'r'
    bne not_cipher
    
    @ Check if next character is space or null (complete word)
    ldrb r2, [r1, #6]
    cmp r2, #32                               @ Space
    beq is_cipher
    cmp r2, #0                                @ Null
    beq is_cipher
    b not_cipher
    
    is_cipher:
        mov r0, #1
        b check_cipher_exit
    not_cipher:
        mov r0, #0
    check_cipher_exit:
        pop {r1, r2, r3}
        bx lr

@ Command handlers
cmd_hello_handler:
    push {lr}
    ldr r0, =hello_msg
    bl print_string
    pop {lr}
    bx lr

cmd_help_handler:
    push {lr}
    ldr r0, =help_msg
    bl print_string
    pop {lr}
    bx lr

cmd_exit_handler:
    push {lr}
    ldr r0, =exit_msg
    bl print_string
    pop {lr}
    @ Exit directly using system call
    mov r0, #0                                 @ Exit status
    mov r7, #1                                 @ sys_exit
    svc #0                                     @ System call - this will terminate immediately

cmd_clear_handler:
    push {lr}
    ldr r0, =clear_seq
    bl print_string
    pop {lr}
    bx lr

cmd_reverse_handler:
    push {r4, r5, r6, lr}                     @ Save registers
    
    @ Print "Reversed: "
    ldr r0, =reverse_msg
    bl print_string
    
    @ Find start of text after "reverse "
    ldr r4, =input_buffer
    add r4, r4, #7                            @ Skip "reverse"
    
    @ Skip any spaces
    reverse_skip_spaces:
        ldrb r0, [r4]
        cmp r0, #0                            @ Check for end
        beq reverse_empty
        cmp r0, #32                           @ Space
        bne reverse_process
        add r4, r4, #1
        b reverse_skip_spaces
    
    reverse_process:
        @ Find the end of the string to reverse
        mov r5, r4                            @ Start of text
        mov r6, r4                            @ Find end
        
        find_end:
            ldrb r0, [r6]
            cmp r0, #0
            beq found_end
            add r6, r6, #1
            b find_end
        
        found_end:
            sub r6, r6, #1                    @ Point to last character
            
        @ Copy characters in reverse order to reverse_buffer
        ldr r1, =reverse_buffer
        mov r2, #0                            @ Index in reverse_buffer
        
        reverse_copy:
            cmp r6, r5                        @ Check if we've processed all
            blt reverse_done
            ldrb r0, [r6]                     @ Get character from end
            strb r0, [r1, r2]                 @ Store in buffer
            sub r6, r6, #1                    @ Move backwards
            add r2, r2, #1                    @ Move forward in buffer
            cmp r2, #250                      @ Prevent overflow
            bge reverse_done
            b reverse_copy
        
        reverse_done:
            mov r0, #0
            strb r0, [r1, r2]                 @ Null terminate
            
            @ Print the reversed string
            ldr r0, =reverse_buffer
            bl print_string
            ldr r0, =newline
            bl print_string
            b reverse_exit
    
    reverse_empty:
        ldr r0, =newline
        bl print_string
    
    reverse_exit:
        pop {r4, r5, r6, lr}                  @ Restore registers
        bx lr

@ Check if command starts with "reverse"
check_reverse_command:
    push {r1, r2, r3}
    mov r1, r0                                @ Input pointer
    
    @ Check first 7 characters for "reverse"
    ldrb r2, [r1]
    cmp r2, #114                              @ 'r'
    bne not_reverse
    ldrb r2, [r1, #1]
    cmp r2, #101                              @ 'e'
    bne not_reverse
    ldrb r2, [r1, #2]
    cmp r2, #118                              @ 'v'
    bne not_reverse
    ldrb r2, [r1, #3]
    cmp r2, #101                              @ 'e'
    bne not_reverse
    ldrb r2, [r1, #4]
    cmp r2, #114                              @ 'r'
    bne not_reverse
    ldrb r2, [r1, #5]
    cmp r2, #115                              @ 's'
    bne not_reverse
    ldrb r2, [r1, #6]
    cmp r2, #101                              @ 'e'
    bne not_reverse
    
    @ Check if next character is space or null (complete word)
    ldrb r2, [r1, #7]
    cmp r2, #32                               @ Space
    beq is_reverse
    cmp r2, #0                                @ Null
    beq is_reverse
    b not_reverse
    
    is_reverse:
        mov r0, #1
        b check_reverse_exit
    not_reverse:
        mov r0, #0
    check_reverse_exit:
        pop {r1, r2, r3}
        bx lr

cmd_cipher_handler:
    push {r4, r5, r6, r7, r8, lr}             @ Save registers
    
    @ Parse cipher command: cipher <text> <shift>
    ldr r4, =input_buffer
    add r4, r4, #6                            @ Skip "cipher"
    
    @ Skip spaces after cipher
    cipher_skip_initial_spaces:
        ldrb r0, [r4]
        cmp r0, #0
        beq cipher_show_help
        cmp r0, #32                           @ Space
        bne cipher_find_text_start
        add r4, r4, #1
        b cipher_skip_initial_spaces
    
    cipher_find_text_start:
        @ Find the text portion (everything before the last number)
        mov r5, r4                            @ Start of text
        mov r6, r4                            @ Current position
        mov r7, r4                            @ Last space position
        
        @ Find the last space (which should be before the shift number)
        cipher_find_last_space:
            ldrb r0, [r6]
            cmp r0, #0
            beq cipher_parse_shift
            cmp r0, #32                       @ Space
            bne cipher_continue_search
            mov r7, r6                        @ Remember this space position
        cipher_continue_search:
            add r6, r6, #1
            b cipher_find_last_space
        
        cipher_parse_shift:
            @ Check if we found a space (meaning we have text and shift)
            cmp r7, r5
            beq cipher_show_help              @ No space found, invalid format
            
            @ Parse the shift value from after the last space
            add r8, r7, #1                    @ Position after last space
            bl simple_parse_shift_number
            cmp r0, #-1
            beq cipher_show_help
            mov r8, r0                        @ Store shift value
            
            @ Apply cipher to text (from r5 to r7)
            bl apply_caesar_cipher
            
            @ Print result
            ldr r0, =cipher_msg
            bl print_string
            ldr r0, =cipher_buffer
            bl print_string
            ldr r0, =newline
            bl print_string
            
            b cipher_done
    
    cipher_show_help:
        ldr r0, =cipher_help
        bl print_string
    
    cipher_done:
        pop {r4, r5, r6, r7, r8, lr}          @ Restore registers
        bx lr

@ Simple function to parse shift number from current position in r8
simple_parse_shift_number:
    push {r1, r2, r3, r9}                     @ Save registers including r9
    mov r0, #0                                @ Result
    mov r9, #0                                @ Digit count (using r9 instead of r1)
    
    @ Skip spaces
    shift_skip_spaces:
        ldrb r2, [r8]
        cmp r2, #32                           @ Space
        bne shift_parse_digits
        cmp r2, #0                            @ End check
        beq shift_parse_error
        add r8, r8, #1
        b shift_skip_spaces
    
    shift_parse_digits:
        ldrb r2, [r8]
        cmp r2, #48                           @ '0'
        blt shift_parse_done
        cmp r2, #57                           @ '9'
        bgt shift_parse_done
        
        @ Add digit: result = result * 10 + digit
        sub r2, r2, #48                       @ Convert to number
        mov r3, #10
        mul r1, r0, r3                        @ temp = result * 10 (using r1 as temp)
        mov r0, r1                            @ result = temp
        add r0, r0, r2                        @ + digit
        add r8, r8, #1                        @ Next character
        add r9, r9, #1                        @ Count digits (using r9)
        b shift_parse_digits
    
    shift_parse_done:
        cmp r9, #0                            @ Check if we got any digits (using r9)
        beq shift_parse_error
        @ Limit shift to reasonable range (0-25)
        cmp r0, #25
        bgt shift_parse_error
        b shift_parse_exit
        
    shift_parse_error:
        mov r0, #-1
    
    shift_parse_exit:
        pop {r1, r2, r3, r9}                  @ Restore registers including r9
        bx lr

@ Apply Caesar cipher to text from r5 to r7, store result in cipher_buffer
apply_caesar_cipher:
    push {r1, r2, r3, r4}
    ldr r1, =cipher_buffer                    @ Destination buffer
    mov r2, #0                                @ Index in destination
    mov r3, r5                                @ Current source position
    
    cipher_loop:
        cmp r3, r7                            @ Check if we reached end of text
        bge cipher_apply_done
        cmp r2, #250                          @ Prevent buffer overflow
        bge cipher_apply_done
        
        ldrb r4, [r3]                         @ Get character
        
        @ Check if it's a lowercase letter (a-z)
        cmp r4, #97                           @ 'a'
        blt cipher_check_upper
        cmp r4, #122                          @ 'z'
        bgt cipher_check_upper
        
        @ Apply cipher to lowercase letter
        sub r4, r4, #97                       @ Convert to 0-25
        add r4, r4, r8                        @ Add shift
        and r4, r4, #31                       @ Modulo 26 (using AND with 31 for simplicity)
        cmp r4, #25                           @ Check if > 25
        ble cipher_lower_ok
        sub r4, r4, #26                       @ Wrap around
        cipher_lower_ok:
        add r4, r4, #97                       @ Convert back to ASCII
        b cipher_store_char
        
        cipher_check_upper:
        @ Check if it's an uppercase letter (A-Z)
        cmp r4, #65                           @ 'A'
        blt cipher_no_change
        cmp r4, #90                           @ 'Z'
        bgt cipher_no_change
        
        @ Apply cipher to uppercase letter
        sub r4, r4, #65                       @ Convert to 0-25
        add r4, r4, r8                        @ Add shift
        and r4, r4, #31                       @ Modulo 26 (using AND with 31 for simplicity)
        cmp r4, #25                           @ Check if > 25
        ble cipher_upper_ok
        sub r4, r4, #26                       @ Wrap around
        cipher_upper_ok:
        add r4, r4, #65                       @ Convert back to ASCII
        b cipher_store_char
        
        cipher_no_change:
        @ Keep non-alphabetic characters unchanged
        
        cipher_store_char:
        strb r4, [r1, r2]                     @ Store encrypted character
        add r2, r2, #1                        @ Move to next position in buffer
        add r3, r3, #1                        @ Move to next source character
        b cipher_loop
    
    cipher_apply_done:
        mov r4, #0
        strb r4, [r1, r2]                     @ Null terminate
        pop {r1, r2, r3, r4}
        bx lr

.section .note.GNU-stack,"",%progbits         @ Add GNU stack note