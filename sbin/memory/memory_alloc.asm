[bits 32]

global UserObtainMemory:

    mov eax, 0x19A00000

scan_memory:
    cmp eax, kernel_end
    jge end_scan

    mov ebx, [eax]
    test ebx, ebx
    jz found_empty

    inc eax
    jmp scan_memory

found_empty:
    mov ebx, [eax]
    mov edx, [eax]
    inc ebx
    add edx, 17

    jmp toMem

toMem:
    mov [eax], ebx
    inc eax
    mov [eax], edx

    mov ebx, 0

    ret

end_scan:
    mov ebx, 1
    ret

kernel_start:
    dd 0x00000000
kernel_end: 
    dd 0x20000000
kernel_driver_start:
    dd 0x20000001
kernel_driver_end:
    dd 0x22000000
Ring1Driver_start:
    dd 0x22000001
Ring1Driver_end:
    dd 0x24000000
Ring2Driver_start:
    dd 0x24000001
Ring2Driver_end:
    dd 0x26000000
UserSpace_Start:
    dd 0x26000001
User_Space_End:
    dd 0xF4000000
FreeStart:
    dd 0xF4000001
Free_End:
    dd 0xFFFFFFFF
