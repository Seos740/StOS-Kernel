[bits 32]
[org 0x300000]

cli


mov al, 0x11
out 0x20, al
out 0xA0, al
mov al, 0x20
out 0x21, al
mov al, 0x28
out 0xA1, al
mov al, 0xFD
out 0x21, al
sti


keyboard_handler:
    in al, 0x60
    cmp al, 0xE0
    je extended_key
    cmp al, 0x1C
    je handle_enter
    cmp al, 0x0E
    je handle_backspace
    cmp al, 0x02
    je print_char_1
    cmp al, 0x03
    je print_char_2
    jmp skip_key

print_char_1:
    mov byte [free_pos], '1'
    jmp move_cursor

print_char_2:
    mov byte [free_pos], '2'
    jmp move_cursor

skip_key:
    iret

extended_key:
    iret

handle_enter:
    mov byte [free_pos], 0x0A
    jmp move_cursor

handle_backspace:
    sub free_pos, 2
    mov byte [free_pos], ' '
    jmp move_cursor

move_cursor:
    add free_pos, 2
    cmp free_pos, 0xB8FA0
    jl continue
    mov free_pos, 0xB8000

    
    mov ax, free_pos
    shr ax, 1
    mov dx, 0x3D4
    mov al, 0x0F
    out dx, al
    mov al, ah
    out dx, al
    mov al, 0x0E
    out dx, al
    mov al, al
    out dx, al

continue:
    iret

free_pos:
    dd 0xB8000


jmp 0x200000
