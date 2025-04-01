[bits 32]

mov al, 0x03
out 0x03C8, al

mov edi, 0xB8000
mov esi, msg

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
    cmp eax, 0x1c
    je print_new_command
    mov ah, 0x0F      
    mov word [edi], ax
    add edi, 2        
    iret

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