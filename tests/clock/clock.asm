section .data
    hour_format     db "Hour: %02d", 10, 0
    minute_format   db "Minute: %02d", 10, 0
    second_format   db "Second: %02d", 10, 0
    time_format     db "Time: %02d:%02d:%02d", 10, 0

section .text
    global _start

_start:
    ; Get the current time
    mov rax, 0x0          ; syscall number for gettimeofday
    mov rdi, rsp          ; pointer to struct timeval
    mov rsi, 0            ; timezone (NULL)
    syscall

    ; Extract hours, minutes, and seconds
    mov rsi, [rsp + 8]    ; move the seconds part to RSI
    mov rcx, 3600         ; number of seconds in an hour
    div rcx               ; divide seconds by 3600, quotient in RAX, remainder in RDX
    mov r8b, dl           ; store hours
    mov rsi, rdx          ; move remaining seconds to RSI
    mov rcx, 60           ; number of seconds in a minute
    div rcx               ; divide remaining seconds by 60, quotient in RAX, remainder in RDX
    mov r9b, dl           ; store minutes
    mov rsi, rax          ; move remaining seconds to RSI
    mov rax, rsi          ; move remaining seconds to RAX (seconds)
    
    ; Print hour
    mov rax, 1            ; syscall number for write
    mov rdi, 1            ; file descriptor 1 (stdout)
    lea rsi, [hour_format]   ; pointer to the hour format string
    mov rdx, 10           ; length of the hour format string
    syscall

    ; Print minute
    mov rax, 1            ; syscall number for write
    mov rdi, 1            ; file descriptor 1 (stdout)
    lea rsi, [minute_format] ; pointer to the minute format string
    mov rdx, 12           ; length of the minute format string
    syscall

    ; Print second
    mov rax, 1            ; syscall number for write
    mov rdi, 1            ; file descriptor 1 (stdout)
    lea rsi, [second_format] ; pointer to the second format string
    mov rdx, 12           ; length of the second format string
    syscall

    ; Print time
    mov rax, 1            ; syscall number for write
    mov rdi, 1            ; file descriptor 1 (stdout)
    lea rsi, [time_format]   ; pointer to the time format string
    mov rdx, 18           ; length of the time format string
    syscall

    ; Exit program
    mov rax, 60           ; syscall number for exit
    xor rdi, rdi          ; exit code 0
    syscall
