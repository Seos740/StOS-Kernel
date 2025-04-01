[bits 32]
[org 0x200000]
[extern fat32_init, FindFileOrDirectory, DisplayFileName, DisplayDirectoryName]

call fat32_init 

lea esi, [filename]         
lea edi, [directory_start]  
mov ecx, [max_entries]      
call FindFileOrDirectory

lea esi, [filename]         
mov edi, [load_address]     
call LoadFileIntoMemory

jmp dword [load_address]    


filename db "/bin/terminal.bin", 0  
directory_start dd 0x100000         
max_entries dd 128                  
load_address dd 0x200000             