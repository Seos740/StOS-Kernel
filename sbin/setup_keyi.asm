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
    mov eax, eax      
    iret

jmp 0x200000
