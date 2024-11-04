global _start

; С клавиатуры вводится целое число любой разрядности.
; Определить количество цифр в нем и их сумму. 
; Вывести на экран число, количество цифр и сумму
section .data
  length: dq 0
  sum: dq 0
  rcx_sum: dq 0

  sum_message db    "sum:             ", 0
  length_message db "count of digits: ", 0
  msg_len: equ $-length_message

  digit db " ", 0
  void_row db " ", 0xA
  len: equ $-void_row

section .bss
  buffer resb 1      ; Резервируем 1 байт для строки

section .text
_start:
  mov rax, 0        ; sys_read
  mov rdi, 0        ; файл stdin
  mov rsi, buffer ; указатель на буфер, где сохраняем символ
  mov rdx, 4096        ; считываем 4096 байт - максимальное кол-во символов
  syscall

  mov rsi, buffer     ; указываем на начало буфера
  xor rdi, rdi        ; обнуляем счетчик длины
  xor rax, rax
  
  .count_length:
    xor rdx, rdx
    mov rdx, [rsi + rdi]
    cmp rdx, 0xA ; проверяем, не конец ли строки (символ 'n')
    je .done_counting         ; если да, выходим из цикла
    
    sub dl, '0'
    movsx rcx, byte dl
    add rax, rcx

    inc rdi                   ; увеличиваем счетчик
    jmp .count_length          ; продолжаем считать

.done_counting:
  mov [length], rdi
  mov [sum], rax

  ; Print sum
  mov rdx, msg_len
  mov rsi, sum_message
  call print_rsi

  mov rax, [sum]
  call print

  mov rdx, len
  mov rsi, void_row
  call print_rsi

  ; Print length
  mov rdx, msg_len
  mov rsi, length_message
  call print_rsi

  mov rax, [length]
  call print

  mov rdx, len
  mov rsi, void_row
  call print_rsi

  mov rax, 60 ; sys_exit
  mov rdi, 0  ; код завершения 0
  syscall

print:
      mov r9, 0
      mov rbx, 10
      
      .next_digit:
        xor rdx, rdx       ; clear rdx prior to dividing edx:eax by ebx
        div rbx            ; rax /= 10
        add dl, 48        ; convert the remainder to ASCII 

        xor r8, r8
        movsx r8, byte dl
        push r8

        add r9, 1
        cmp rax, 0
      jne .next_digit    ; repeat until    

      mov rsi, digit
      .write:
        xor rdx, rdx
        pop rdx

        mov [rsi], dl
        mov rdx, 1      ; length of the string
        call print_rsi

        dec r9
        test r9, r9
      jnz .write
  ret

print_rsi:
  mov rdi, 1           ; file descriptor, in this case stdout
  mov rax, 1           ; syscall number for write
  syscall
  ret