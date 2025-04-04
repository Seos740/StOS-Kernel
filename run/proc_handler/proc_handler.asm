[bits 32]

[extern fat32_init]
[extern FindFileOrDirectory]
[extern DisplayFileName]
[extern DisplayDirectoryName]

global Proc_Create

Proc_Create:
    lea esi, [proc_dir_start]
    call FindFileOrDirectory
    cmp eax, 0                   
    je FileNotFound

    loopie: 
    mov ecx, [eax]
    cmp ecx, 0x00
    je add_data
    inc eax
    jmp loopie

    mov eax, proc_nametable_start
add_data_one:

    mov edx, [eax]
    mov [ebx], edx
    cmp eax, 0
    je add_data_two_pre
    inc eax
    jmp add_data_one

add_data_two_pre:    

    proc_name_loop:

    mov edx, [eax]
    mov [ebx], edx
    mov [edx], edi
    cmp edi, 0
    je cont_one
    inc eax
    jmp proc_name_loop

    cont_one:
    mov eax, proc_id_start

add_data_two:
    mov edx, [eax]
    mov [ecx], edx
    cmp eax, 0
    je add_data_three_pre
    inc eax
    jmp add_data_two

add_data_three_pre:

    proc_id_loop:
    
    mov edx, [eax]
    mov [ebx], edx
    mov [edx], ebp
    cmp ebp, 0
    je cont_two
    inc eax
    jmp proc_id_loop

    cont_two:

    mov eax, proc_ring

add_data_three:
    mov edx, [eax]
    mov [ecx], edx
    cmp eax, 0
    je add_data_three_pre
    inc eax
    jmp add_data_two

    proc_ring_loop:
    
    mov edx, [eax]
    mov [ebx], edx
    mov [edx], esp
    cmp esp, 0
    je cont_three
    inc eax
    jmp proc_ring_loop

    cont_three:
    ret

add_data:
    ; my implementation will be here
    ret

FileNotFound:
    mov ebx, 1
    ret

proc_dir_start:
    db '/proc/proc_table.txt', 0

proc_nametable_start:
    dd 'procname=', 0

proc_id_start:
    dd 'procid=', 0

proc_ring:
    dd 'procring=', 0
