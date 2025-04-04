; Declare global functions before their definitions
global fat32_init, CompareFilenames, FindFileOrDirectory

[bits 32]

; FAT32 boot sector definition
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

; Read sector function
ReadSector:
    mov ah, 0x02
    int 0x13
    jc ReadError
    ret

ReadError:
    jmp $

; FAT32 Initialization function
fat32_init:
    mov dl, 0x80
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov al, 1
    call ReadSector
    ret

; Directory entry (for use later)
FAT32_DirectoryEntry:
    db "MYFILE  TXT"

; File search function
FindFileOrDirectory:
    mov esi, directory_start
    mov edi, file_name
    mov ecx, 0

SearchLoop:
    movzx eax, byte [esi]
    cmp eax, 0x00
    je NoFileFound
    cmp byte [esi], 0xE5
    je SkipEntry

    lea edi, [FAT32_DirectoryEntry]
    call CompareFilenames
    je FileFound

    add esi, 32
    inc ecx
    cmp ecx, max_entries
    jl SearchLoop
    jmp NoFileFound

SkipEntry:
    add esi, 32
    jmp SearchLoop

NoFileFound:
    ret

FileFound:
    cmp byte [esi + 11], 0x10
    je DirectoryFound
    call DisplayFileName
    ret

DirectoryFound:
    call DisplayDirectoryName
    ret

; Display functions (you can implement later)
DisplayFileName:
    ret

DisplayDirectoryName:
    ret

; Compare filenames function
CompareFilenames:
    mov al, [edi]
    mov bl, [esi]
    cmp al, bl
    jne FilenamesDoNotMatch
    inc edi
    inc esi
    cmp byte [edi], 0
    je FilenamesMatch
    jmp CompareFilenames

FilenamesDoNotMatch:
    ret

FilenamesMatch:
    ret

; Maximum number of entries for directory search
max_entries:
    dd 10  ; You can set this to the number of directory entries to search

; Starting directory
directory_start:
    db "/proc", 0

; File to search for
file_name:
    db "proc_table.txt", 0
