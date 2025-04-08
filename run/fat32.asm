global fat32_init, CompareFilenames, FindFileOrDirectory

[bits 32]

FAT32_BootSector: 
    db 0xEB, 0x58, 0x90
    db "MSWIN4.1"
    dw 0x0200
    db 0x08
    dw 0x0001
    db 0x02
    dw 0x003F
    dw 0x003F
    db 0xF8
    dw 0x0000
    dw 0x0000
    dw 0x0000
    dd 0x00000000
    dd 0x00000000

ReadSector:
    mov ah, 0x02
    int 0x13
    jc ReadError
    ret

ReadError:
    jmp $

fat32_init:
    mov dl, 0x80
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov al, 1
    call ReadSector
    ret

FAT32_DirectoryEntry:
    db "MYFILE  TXT"

FindFileOrDirectory:
    mov ecx, 0                ; Directory entry counter

SearchLoop:
    movzx eax, byte [esi]     ; Load byte from current directory entry (pointed by esi)
    cmp eax, 0x00             ; Check if it's the end of directory (empty entry)
    je NoFileFound
    cmp byte [esi], 0xE5      ; Check if it's a deleted entry
    je SkipEntry

    lea edi, [FAT32_DirectoryEntry] ; Load address of the filename to compare
    call CompareFilenames            ; Compare filenames
    je FileFound

    add esi, 32               ; Move to the next directory entry (32 bytes per entry)
    inc ecx                   ; Increment entry count
    cmp ecx, max_entries      ; Check if we've exceeded max entries
    jl SearchLoop
    jmp NoFileFound

SkipEntry:
    add esi, 32               ; Skip to the next entry
    jmp SearchLoop

NoFileFound:
    ret

FileFound:
    ; Extract the starting cluster from the directory entry (offset 0x1A and 0x1C)
    movzx eax, word [esi + 0x1A]   ; Load the low 16 bits of the starting cluster
    movzx ebx, word [esi + 0x1C]   ; Load the high 16 bits of the starting cluster
    shl ebx, 16                    ; Shift the high 16 bits to the left
    or eax, ebx                    ; Combine the low and high parts of the cluster number

    ; Now eax contains the starting cluster of the found file
    ; You can now use eax to access the file's starting cluster

    ret

DisplayFileName:
    ret

DisplayDirectoryName:
    ret

CompareFilenames:
    mov al, [edi]               ; Load byte from directory entry filename
    mov bl, [esi]               ; Load byte from directory entry pointed by esi
    cmp al, bl                  ; Compare the characters
    jne FilenamesDoNotMatch     ; If they don't match, return
    inc edi                     ; Move to the next character in filename
    inc esi                     ; Move to the next character in directory entry
    cmp byte [edi], 0           ; Check if end of string (NULL terminator)
    je FilenamesMatch           ; If it matches, return
    jmp CompareFilenames        ; Otherwise, continue comparing

FilenamesDoNotMatch:
    ret

FilenamesMatch:
    ret

max_entries:
    dd 128                     ; Set this value to the number of directory entries to search
