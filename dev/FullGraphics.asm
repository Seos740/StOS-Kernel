[bits 32]

; Squaer Stack order (top to bottom): shape type, color, corner 1 X(or center), corner 1 Y, width, ... corn 2 Y, height ...

mov al, 0x13           ; set video mode
out 0x13C8, al          ; send mode to the video port
mov edi, 0xA0000

pop eax

cmp eax, 0x01 ; 0x01 = Square/Rectangle
jmp Rectangle
cmp eax, 0x02 ; 0x02 = Circle
jmp Circle
cmp eax, 0x03 ; 0x03 = Triangle
jmp Triangle


Rectangle:
pop ebx ; color to ebx
mov esi, ebx ; add color to esi
pop eax ; put first corner X pos in eax
pop ecx ; put first corner Y pos in ecx
pop edx ; put width into edx
mov ebx, ecx
imul ecx, 320 ; multiply Y pos by 320


Circle:
pop ebx


Triangle:
pop ebx