[bits 32]
[org 0x200000]
[extern fat32_init, FindFileOrDirectory, DisplayFileName, DisplayDirectoryName]

call fat32_init 

jmp $