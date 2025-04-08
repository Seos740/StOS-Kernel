[bits 32]
[extern fat32_init]
[extern FindFileOrDirectory]
[extern DisplayFileName]
[extern DisplayDirectoryName]

lea esi, [filename]
lea edi, [directory_start]
mov ecx, [max_entries]
call FindFileOrDirectory

call DisplayFileName

call DisplayDirectoryName

ret

filename db "MyFile.txt", 0
directory_start dd 0x100000
max_entries dd 128