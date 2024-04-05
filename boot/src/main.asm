bits 16
org 0x7c00

jmp loop

loop:
    int 0x10

times 510 - ($-$$) db 0
dw 0xAA55