[bits 32]

mov al, 0x03
out 0x03C8, al

mov edi, 0xB8000 ;text memory
mov esi, msg ;string pointer

print_char:
    mov al, [esi]
    cmp al, 0
    je read_keyboard
    mov ah, 0x0F
    mov word [edi], ax
    add edi, 2
    inc esi
    jmp print_char

msg:
    db 'Welcome to StOS!', 0x0d, 0x0a, 'StOS $ ', 0

newcommand:
    db 0x0d, 0x0a, 'StOS $ ', 0

read_keyboard:
    cmp eax, 0x1c ;0x1c = enter key
    je print_new_command ;jump if enter key is pressed
    mov ah, 0x0F   ;white text thing    
    mov word [edi], ax ; ax = ah + al, moves the character into video memory
    add edi, 2   ;Prepare for next character      
    iret ;return to caller to recive next character

print_new_command:
    mov esi, newcommand
new_command_loop:
    mov al, [esi]
    cmp al, 0
    je read_keyboard
    mov ah, 0x0F
    mov word [edi], ax
    add edi, 2
    inc esi
    jmp new_command_loop