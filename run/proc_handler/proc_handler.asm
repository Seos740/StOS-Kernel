[bits 32]

[extern fat32_init]
[extern FindFileOrDirectory]
[extern DisplayFileName]
[extern DisplayDirectoryName]

global Proc_Create

Proc_Create:
    ; Initialize the directory search to look for /proc/proc_table.txt
    lea esi, [proc_dir_start]   ; Load the address of "/proc/proc_table.txt"
    call FindFileOrDirectory    ; Call FindFileOrDirectory to find the file

    ; Check if the file is not found (eax == 0)
    cmp eax, 0                   
    je FileNotFound              ; Jump to FileNotFound if file not found

    ; File found, continue processing
    lea ebx, [proc_nametable_start] ; Load address of proc_name table
    call add_data_one

    ; Process additional data for proc_id_start
    lea ebx, [proc_id_start]     ; Load address of proc_id_start
    call add_data_two

    ; Process additional data for proc_ring
    lea ebx, [proc_ring]         ; Load address of proc_ring
    call add_data_three

    ret

add_data_one:
    ; Process the proc_name (from proc_nametable_start)
    mov edx, [ebx]               ; Load the first part of the proc name
    mov [ecx], edx               ; Store it in the memory location pointed by ecx
    cmp edx, 0                   ; Check if it's the end of string (NULL terminator)
    je cont_one                  ; If NULL, jump to cont_one
    inc ebx                      ; Move to the next part of the name
    jmp add_data_one             ; Continue processing

cont_one:
    mov eax, proc_id_start       ; Load address of proc_id_start

add_data_two:
    mov edx, [eax]               ; Load the next part of the data
    mov [ecx], edx               ; Store it in the memory location pointed by ecx
    cmp edx, 0                   ; Check if it's the end of string (NULL terminator)
    je cont_two                  ; If NULL, jump to cont_two
    inc eax                      ; Move to the next part of the ID
    jmp add_data_two             ; Continue processing

cont_two:
    mov eax, proc_ring           ; Load address of proc_ring

add_data_three:
    mov edx, [eax]               ; Load the next part of the data
    mov [ecx], edx               ; Store it in the memory location pointed by ecx
    cmp edx, 0                   ; Check if it's the end of string (NULL terminator)
    je cont_three                ; If NULL, jump to cont_three
    inc eax                      ; Move to the next part of the ring
    jmp add_data_three           ; Continue processing

cont_three:
    ret

FileNotFound:
    mov ebx, 1                   ; Set error code (file not found)
    ret

; Data section with file paths, etc.
section .data
    proc_dir_start db '/proc/proc_table.txt', 0
    proc_nametable_start db 'procname=', 0
    proc_id_start db 'procid=', 0
    proc_ring db 'procring=', 0
