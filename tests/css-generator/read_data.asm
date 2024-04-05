section .data
    buffer db 100         ; Buffer to store the input data
    newline db 10         ; ASCII code for newline character

section .bss
    fd resb 4             ; File descriptor
    bytes_read resb 4     ; Bytes read counter

section .text
    global _start

_start:
    ; Open the file
    mov eax, 5            ; sys_open syscall number
    mov ebx, data_file    ; Address of filename string
    mov ecx, 0            ; O_RDONLY mode
    int 0x80              ; Call the kernel
    mov dword [fd], eax   ; Store file descriptor

read_loop:
    ; Read data from the file
    mov eax, 3            ; sys_read syscall number
    mov ebx, dword [fd]   ; File descriptor
    mov ecx, buffer       ; Buffer to store the input data
    mov edx, 100          ; Maximum number of bytes to read
    int 0x80              ; Call the kernel
    mov dword [bytes_read], eax  ; Store number of bytes read

    ; Check if end of file is reached
    cmp eax, 0
    je end_program

    ; Write the read data to stdout
    mov eax, 4            ; sys_write syscall number
    mov ebx, 1            ; File descriptor 1 (stdout)
    mov ecx, buffer       ; Buffer containing the data
    mov edx, eax          ; Number of bytes to write (bytes read)
    int 0x80              ; Call the kernel

    ; Loop back to read more data
    jmp read_loop

end_program:
    ; Close the file
    mov eax, 6            ; sys_close syscall number
    mov ebx, dword [fd]   ; File descriptor
    int 0x80              ; Call the kernel

    ; Exit the program
    mov eax, 1            ; sys_exit syscall number
    xor ebx, ebx          ; Exit code 0
    int 0x80              ; Call the kernel

section .data
    data_file db "data.data",0   ; Filename of the data file
