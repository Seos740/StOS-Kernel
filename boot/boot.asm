[bits 64]
[org 0x100000]

UefiMain:
    mov r8, [rsi]
    mov r9, [r8 + 0x18]
    call LoadKernelFromESP
    jmp KernelEntryPoint

LoadKernelFromESP:
    ret

KernelEntryPoint:
    ret
