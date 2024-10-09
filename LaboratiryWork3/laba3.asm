global _start ; _start

section .data
a: dq 29
b: dq 18
c: dq 31
d: dq -14

; (!b + c * a) + d

result_sign: db 0
message db "result =          ", 0xA
message_legth: equ $-message      ; length of msg

section .text           ; code section
_start:                 ; enter point
    ; c * a start
    mov rax, [c]
    mov rdi, [a]
    and rax, rdi
    ; c * a end

    ; (!b + c * a) start
    mov rdi, [b]
    not rdi
    or rax, rdi
    ; (!b + c * a) end

    ; (!b + c * a) + d start
    mov rdi, [d]
    and rax, rdi
    ; (!b + c * a) + d end
    
    ; start print
    test rax, rax
    jns .output

    mov dl, 1
    mov [result_sign], dl
    neg rax
        ;Поготовка к выводу
    .output:
        mov rsi, message
        add rsi, message_legth-1
        mov rbx, 2;10
        .next_digit:
            xor rdx, rdx       ; clear rdx prior to dividing rdx:rax by rbx
            div rbx            ; rax /= 10
            add dl, '0'        ; convert the remainder to ASCII 
            dec rsi            ; store characters in reverse order
            mov [rsi], dl      ;
            test rax, rax
            jnz .next_digit    ; repeat until
    
        mov dl, 1
        cmp [result_sign], dl
        jnz .print

        dec rsi
        mov dl, 45 ; 45 is minus
        mov [rsi], dl
    
        .print:
        mov rdx, message_legth      ; length of the string
        mov rsi, message         ; address of the string
        mov rdi, 1           ; file descriptor, in this case stdout
        mov rax, 1           ; syscall number for write
        syscall
        ; end print

    .exit:
        ; Завершение программы
        mov rax, 60 ; sys_exit
        mov rdi, 0 ; код завершения 0
        syscall
