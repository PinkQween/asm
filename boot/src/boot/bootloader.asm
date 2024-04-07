[org 0x7c00]

jmp short start
nop

; Define Disk Parameters
OEMLabel        db "MYOS"     ; OEM Label
BytesPerSector  dw 512         ; Bytes per Sector
SectorsPerCluster db 1         ; Sectors per Cluster
ReservedSectors dw 1           ; Reserved Sectors
NumberOfFATs    db 2           ; Number of FATs
RootDirEntries  dw 224         ; Number of Root Directory Entries
LogicalSectors  dw 2880        ; Logical Sectors
MediumByte      db 0xf0        ; Medium Byte
SectorsPerFAT   dw 9           ; Sectors per FAT
SectorsPerTrack dw 18          ; Sectors per Track
Heads           dw 2           ; Number of Heads
HiddenSectors   dd 0           ; Hidden Sectors
LargeSectors    dd 0           ; Large Sectors

; Define Stack Segment
stack_bottom    equ 0x7c00
stack_size      equ 0x0200
stack_top       equ stack_bottom - stack_size

start:
    xor ax, ax                  ; Set up segments
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    ; Clear AX register, set SS to 0, and set SP to the top of the stack
    xor ax, ax
    mov ss, ax
    mov sp, stack_top

    mov ebp, stack_top          ; Set up stack

    mov ah, 0x00                ; BIOS Video Services - Set Video Mode
    mov al, 0x03                ; Video mode 0x03: text mode 80x25 16 colors
    int 0x10                    ; Call BIOS interrupt

    ; Print a message
    mov si, msg                 ; Load message address into SI
    call print_string           ; Call print_string function

    ; Load kernel
    mov ax, 0x0201         ; Set up disk read function (int 0x13 AH=0x02)
    mov bx, buffer         ; Destination buffer
    mov cx, 0x0002         ; Number of sectors to read
    mov dl, 0x00           ; Drive number (0=A:, 1=2nd floppy, 80h=1st hard disk)
    mov dh, 0x00           ; Head number
    mov ch, 0x00           ; Cylinder number
    int 0x13               ; Call BIOS interrupt

    jc read_error          ; Jump to 'read_error' if the carry flag is set, indicating an error

    ; Print out the loaded signature
    mov si, buffer         ; Point SI to the beginning of the buffer
    add si, 510            ; Address of kernel signature in the buffer
    mov di, si             ; Copy SI to DI for printing
    call print_hex         ; Print the loaded signature in hexadecimal

    ; Print out the expected signature
    mov eax, 0xDEADBEEF    ; Expected kernel signature
    movzx edi, ax          ; Copy expected signature to DI for printing (Zero extend EAX into EDI)
    mov si, ax              ; Move lower 16 bits to DI
    call print_hex         ; Print the expected signature in hexadecimal

    ; Compare signatures
    mov eax, dword [si]    ; Load the actual signature into EAX
    cmp eax, 0xDEADBEEF    ; Compare the kernel signature
    je valid_kernel        ; Jump to 'valid_kernel' if the signature matches

    ; jmp valid_kernel

    call print_newline

    ; Print error message if signatures don't match
    mov si, invalid_kernel
    call print_string

    ; Halt the system
    jmp halt

print_hex:
    mov ecx, 8             ; Print 8 hex digits for a 32-bit value
print_hex_loop:
    ; Extract the most significant nibble
    mov ebx, eax
    shr ebx, 28            ; Shift 28 bits to get the most significant nibble
    and ebx, 0xF           ; Mask to get only the nibble
    movzx ebx, byte [hex_table + ebx]  ; Get ASCII character for the nibble
    mov [si], bl           ; Store the ASCII character in SI
    inc si                 ; Move to the next position in the buffer
    ; Move to the next nibble
    shl eax, 4             ; Shift left by 4 bits to move to the next nibble
    loop print_hex_loop
    ret

hex_table db '0123456789ABCDEF'  ; Lookup table for converting nibbles to ASCII


signature_msg db "Expected Signature: ", 0
invalid_kernel db 0x0D, "Invalid Kernel Signature", 0x0D, 0x0A, 0

print_newline:
    mov ah, 0x0E        ; Function code for BIOS teletype output
    mov al, 0x0D        ; ASCII code for carriage return
    int 0x10            ; Call BIOS interrupt to print carriage return
    mov al, 0x0A        ; ASCII code for line feed
    int 0x10            ; Call BIOS interrupt to print line feed
    ret

valid_kernel:
    mov si, noErrorMsg
    call print_string           ; Call print_string function
    jmp 0x1000:0000             ; Jump to kernel

print_char:
    mov ah, 0x0E                ; BIOS Video Services - Teletype
    mov bh, 0x00                ; Display page number
    mov bl, 0x07                ; Text attribute: white on black
    int 0x10                    ; Call BIOS interrupt
    ret

print_string:
    next_char:
        lodsb                   ; Load byte at SI into AL, and increment SI
        or al, al               ; Check if AL is zero (end of string)
        jz done                 ; If zero, end of string
        call print_char         ; Print character in AL
        jmp next_char           ; Continue to next character
    done:
        ret

read_error:
    mov si, errorMsg            ; Load address of error message into SI
    call print_string           ; Display the error message
    jmp halt                    ; Jump to halt

halt:
    mov si, halting
    call print_string

    hlt                         ; Halt the system

msg db 0x0D, "Booting...", 0x0D, 0x0A, 0
errorMsg db 0x0D, "Disk read error!", 0x0D, 0x0A, 0
noErrorMsg db 0x0D, "no read error", 0x0D, 0x0A, 0
halting db 0x0D, "halting system", 0x0D, 0x0A, 0
is_hex_called db 0x0D, "is_hex_called", 0x0D, 0x0A, 0

; Define the BIOS parameter block
times 510-($-$$) db 0
dw 0xAA55

buffer:
    ; Placeholder for the kernel loading
