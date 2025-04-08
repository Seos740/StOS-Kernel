[bits 32]

global UserObtainMemory:

    mov eax, UserSpace_Start ; Start of UserSpace (0x26000001)

scan_memory:
    cmp eax, User_Space_End ; Checks if we have reached the end of UserSpace
    jge end_scan ; If we have, return an error

    mov ecx, [eax] ; Move the data at the current location in MemAllocTable
    test ecx, ecx ; Check to see if it's empty
    jz found_empty ; If it is, then we write new data there

    inc eax ; Move to the next spot to check
    jmp scan_memory ; Loop

found_empty:
    mov ecx, eax          ; Load the start address of the memory block (ecx = start)
    mov edx, eax          ; Load the start address to edx temporarily
    add edx, 16000000           ; Allocate 16 MB 
    
    ; Now, we will update the MemAllocTable with the new allocation details.
    ; The table tracks start and end addresses of the allocated memory.

    jmp toMem

toMem:
    sub eax, 16           ; Go back to the start of the memory entry in MemAllocTable
    mov [eax], ecx        ; Store the start address of the allocated memory in MemAllocTable
    inc eax               ; Increment to the next 4-byte location
    mov [eax], edx        ; Store the end address of the allocated memory in MemAllocTable

    mov ebx, 0            ; Error code register (0 for success)
    ret                   ; Return to caller

end_scan:
    mov ebx, 1            ; Error code register (1 for failure)
    ret                   ; Return to caller

; Memory regions
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
    dd 0x26000001       ; Start of UserSpace
User_Space_End:
    dd 0xF4000000       ; End of UserSpace
FreeStart:
    dd 0xF4000001
Free_End:
    dd 0xFFFFFFFF
