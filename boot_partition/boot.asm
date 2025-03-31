[bits 16]
[org 0x7c00]

jmp 0x1000

times 510 - ($ - $$) db 0
dw 0xAA55