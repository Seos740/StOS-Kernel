[bits 32]

;used: edi, eax, ebx, esi, ecx
; Stack order (top to bottom): X pos, Y pos, Color

mov al, 0x13           ; set video mode
out 0x13C8, al          ; send mode to the video port

mov edi, 0xA0000        ; set pointer to the start of video memory
pop eax            ; X position (starting)
pop ebx            ; Y position (starting)

; Square loop (draws a 50x50 square for now)
square_loop_y:
    mov ecx, 50         ; Width of the square (X direction loop)
    mov edx, ebx        ; Y position

    ; Calculate offset (EDX * 320 + ECX)
    imul edx, edx, 320  ; Multiply Y pos by 320 (screen width)
    
    square_loop_x:
        ; Add X offset (ECX)
        add edx, eax      ; Add X position to the offset

        ; Move pointer to the specific memory address
        mov esi, 0xA0000  ; Reset to start of video memory
        add esi, edx      ; Add calculated offset to video memory base

        pop [esi] ; Set pixel to white (0x0F)

        inc eax           ; Increment X position
        dec ecx           ; Decrement loop counter
        jnz square_loop_x ; Continue X loop if not done

    inc ebx               ; Increment Y position
    cmp ebx, 100          ; Check if we've finished drawing all Y rows
    jl square_loop_y      ; If not, continue the Y loop

end:
    ret                   ; Return from function


vid_mem_start equ 0xA0000 ; Define memory start
