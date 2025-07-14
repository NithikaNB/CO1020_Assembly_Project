.data
    prompt:         .asciz "shell> "           @ Command prompt
    hello_msg:      .asciz "Hello World!\n"    @ Hello command output
    help_msg:       .asciz "Available commands:\n  hello - Prints Hello World!\n  help - Lists all commands\n  exit - Terminates the shell\n  clear - Clears the screen\n  reverse - Reverses your text\n  echo - Echo back your message\n\n"
    exit_msg:       .asciz "Goodbye!\n"        @ Exit message
    clear_seq:      .asciz "\033[2J\033[H"     @ ANSI clear screen sequence
    unknown_cmd:    .asciz "Unknown command. Type 'help' for available commands.\n"
    reverse_msg:    .asciz "Reversed: "
    echo_msg:       .asciz "Echo: "
    newline:        .asciz "\n"
    
    @ Command strings for comparison
    cmd_hello:      .asciz "hello"
    cmd_help:       .asciz "help"
    cmd_exit:       .asciz "exit"
    cmd_clear:      .asciz "clear"
    cmd_reverse:    .asciz "reverse"
    cmd_echo:       .asciz "echo"

.bss
    input_buffer:   .space 256                 @ Buffer for user input
    token_buffer:   .space 64                  @ Buffer for tokenizing
    reverse_buffer: .space 256                 @ Buffer for reverse command

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
    
    @ Check for reverse command first (special handling)
    bl check_reverse_command
    cmp r0, #1
    beq handle_reverse_special
    
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
    ldr r1, =cmd_echo
    bl strcmp
    cmp r0, #0
    beq cmd_echo_found
    
    @ Unknown command
    ldr r0, =unknown_cmd
    bl print_string
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
    
    cmd_echo_found:
        bl cmd_echo_handler
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

cmd_echo_handler:
    push {r4, lr}                              @ Save registers
    
    @ Print "Echo: "
    ldr r0, =echo_msg
    bl print_string
    
    @ Find start of message after "echo "
    ldr r4, =input_buffer
    add r4, r4, #4                             @ Skip "echo"
    
    @ Skip any spaces
    echo_skip_spaces:
        ldrb r0, [r4]
        cmp r0, #0                             @ Check for end
        beq echo_done
        cmp r0, #32                            @ Space
        bne echo_print
        add r4, r4, #1
        b echo_skip_spaces
    
    echo_print:
        mov r0, r4
        bl print_string
        ldr r0, =newline
        bl print_string
        b echo_end
    
    echo_done:
        ldr r0, =newline
        bl print_string
    
    echo_end:
        pop {r4, lr}                           @ Restore registers
        bx lr

.section .note.GNU-stack,"",%progbits         @ Add GNU stack note