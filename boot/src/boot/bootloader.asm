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
    mov ax, 0x0002              ; Set up disk read function (int 0x13 AH=0x02)
    mov bx, buffer              ; Destination buffer
    mov cx, 0x0002              ; Number of sectors to read
    mov dl, 0x00                ; Drive number (0=A:, 1=2nd floppy, 80h=1st hard disk)
    mov dh, 0x00                ; Head number
    mov dh, 0x00                ; Cylinder number
    int 0x13                    ; Call BIOS interrupt

    jc read_error               ; Jump to 'read_error' if the carry flag is set, indicating an error

    ; Check kernel signature
    mov si, buffer              ; Point SI to the beginning of the buffer
    add si, 510                 ; Adjust SI to point to the last 4 bytes of the loaded kernel
    cmp dword [si], 0xDEADBEEF ; Compare the last 4 bytes with the kernel signature
    je valid_kernel             ; Jump to 'valid_kernel' if the signature matches
    mov eax, dword [si]         ; Load the actual signature into EAX
    call print_hex              ; Print the wrong signature
    mov si, invalid_kernel
    call print_string
    jmp halt                    ; Jump to halt if signature doesn't match

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

print_hex:
    mov cx, 8                   ; Counter for 8 hex digits
next_digit:
    rol eax, 4                  ; Rotate the value in EAX right by 4 bits
    mov bl, al                  ; Move the lower 4 bits to BL
    and bl, 0x0F                ; Mask the higher 4 bits of BL
    cmp bl, 10                  ; Check if the value is greater than 9
    jl print_digit              ; If not, jump to print_digit
    add bl, 7                   ; If greater than 9, add 7 to get ASCII for A-F
print_digit:
    add bl, '0'                 ; Convert the value in BL to ASCII
    call print_char             ; Print the ASCII character in BL
    loop next_digit             ; Continue until all 8 digits are printed
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
invalid_kernel db 0x0D, "invalid kernel", 0x0D, 0x0A, 0

; Define the BIOS parameter block
times 510-($-$$) db 0
dw 0xAA55

buffer:
    ; Placeholder for the kernel loading
