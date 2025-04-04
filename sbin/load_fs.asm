[bits 32]

; org 0x200000   . Set the origin address of the program (you may adjust this)

; Declare external functions
extern fat32_init
extern FindFileOrDirectory
extern DisplayFileName
extern DisplayDirectoryName
extern LoadFileIntoMemory

; Start of the program
_start:
    ; Call fat32_init to initialize the FAT32 file system
    call fat32_init 

    ; Set up for FindFileOrDirectory
    lea esi, [filename]      ; Load the address of the filename into ESI
    lea edi, [directory_start] ; Load the address of the directory start into EDI
    mov ecx, [max_entries]   ; Load max_entries value into ECX
    call FindFileOrDirectory  ; Call the external function

    ; Set up for LoadFileIntoMemory
    lea esi, [filename]      ; Load the address of the filename into ESI
    mov edi, [load_address]  ; Load the load address into EDI
    call LoadFileIntoMemory  ; Call the external function

    ; Jump to the loaded address to execute the file
    jmp dword [load_address]    

; Data section
filename db "/bin/terminal.bin", 0  ; Null-terminated filename
directory_start dd 0x100000         ; Directory start address
max_entries dd 128                  ; Max number of directory entries to search
load_address dd 0x200000            ; Memory address to load the file into
