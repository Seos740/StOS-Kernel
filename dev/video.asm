[bits 32]

mov edi, vid_mem_start
mov eax, 50
mov ebx, 50

square_loop:
    mov ecx, eax
    mov edx, ebx
    imul edx, 320
    add ecx, edx
    mov edi, vid_mem_start
    add edi, ecx
    mov byte [edi], 0x0F

    inc eax
    cmp eax, 100
    jl square_loop

    mov eax, 50
    inc ebx
    cmp ebx, 100
    jl square_loop

end:
    ret

vid_mem_start equ 0xA0000
