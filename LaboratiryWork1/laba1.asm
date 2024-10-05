global _start

section .data
a: dq 19
b: dq 15
c: dq 26
d: dq 14
cd: dq 0
ab: dq 0
result_sign: db 0
message db "result =        ", 0xA
message_length: equ $-message      ; length of message

section .text           ; code section
_start:                 ; enter point

    ;c * d start
    mov rax, [c]
    mov rdi, [d]
    mul rdi
    mov [cd], rax
    ;c * d end

    ;a mod b start
    mov rax, [a]
    mov rdi, [b]
    div rdi
    mov [ab], rdx
    ;a mod b end

    ;a ^ 2 -7 start
    mov rax, [a]
    mul rax
    mov rdi, 7
    sub rax, rdi
    ; a ^ 2 -7 end

    add rax, [ab]
    sub rax, [cd]

    test rax, rax
    jns .output

    mov dl, 1
    mov [result_sign], dl
    neg rax

    ;prepare output
    .output:
    mov rsi, message
    add rsi, message_length-1
    mov rbx, 10
    .next_digit:
        xor rdx, rdx       ; clear rdx prior to dividing rdx:rax by rbx
        div rbx            ; rax /= 10
        add dl, '0'        ; convert the remainder to ASCII 
        dec rsi            ; store characters in reverse order
        mov [rsi], dl
        test rax, rax
        jnz .next_digit    ; repeat until
    
    mov dl, 1
    cmp [result_sign], dl
    jnz .print

    dec rsi
    mov dl, '-' ; 45 is minus
    mov [rsi], dl
    
    .print:
    mov rdx, message_length      ; length of the string
    mov rsi, message         ; address of the string
    mov rdi, 1           ; file descriptor, in this case stdout
    mov rax, 1           ; syscall number for write
    syscall
    
    ; exit
    mov rax, 60 ; sys_exit
    mov rdi, 0 ; code 0
    syscall
