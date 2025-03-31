[BITS 16]
[ORG 0x1000]

mov ax, 0x13    
int 0x10               

mov ax, 0xA000  
mov es, ax            

mov dx, 0              

draw_loop:
    mov di, dx          
    mov bx, 320         
    mul bx               
    mov di, ax          

    mov cx, 0            

draw_row:
    mov al, cl           
    stosb                

    inc cx               
    cmp cx, 320          
    jl draw_row          

    inc dx               
    cmp dx, 200          
    jl draw_loop         

xor ah, ah
int 0x16               

mov ax, 0x03    
int 0x10               

hlt                    

             
