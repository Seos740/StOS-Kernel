[bits 32]

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

    ; Add pointer to proccess name here
    mov eax, proc_id_start

add_data_two:
    mov edx, [eax]
    mov [ecx], edx
    cmp eax, 0
    je add_data_three_pre
    inc eax
    jmp add_data_two

add_data_three_pre:

    ; Add pointer to proccess id here
    mov eax, proc_ring

add_data_three:
    mov edx, [eax]
    mov [ecx], edx
    cmp eax, 0
    je add_data_three_pre
    inc eax
    jmp add_data_two

    ; Add pointer to proccess's ring over here

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
