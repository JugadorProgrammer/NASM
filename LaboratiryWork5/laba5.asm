global _start

; С клавиатуры вводится целое число любой разрядности.
; Определить количество цифр в нем и их сумму. 
; Вывести на экран число, количество цифр и сумму
section .data
  sum dq 0

  digit db " ", 0

  void_row db " ", 0xA
  len: equ $-void_row

section .bss
  buffer resb 256      ; Резервируем 256 байт для строки

section .text
_start:
  mov rax, 0        ; sys_read
  mov rdi, 0        ; файл stdin
  mov rsi, buffer ; указатель на буфер, где сохраняем символ
  mov rdx, 256        ; считываем 256 байт
  syscall

  mov rcx, buffer     ; указываем на начало буфера
  xor rdi, rdi        ; обнуляем счетчик длины
  mov rax, 0
  
  .count_length:
    cmp byte [rcx + rdi], 10 ; проверяем, не конец ли строки (символ 'n')
    je .done_counting         ; если да, выходим из цикла
    mov rdx, [rcx + rdi]
    sub rdx, '0'
    add rax, rdx

    inc rdi                   ; увеличиваем счетчик
    jmp .count_length          ; продолжаем считать

.done_counting:
  mov [sum], rax
  mov rax, rdi
  call print

  mov rdx, len
  mov rsi, void_row
  mov rdi, 1           ; file descriptor, in this case stdout
  mov rax, 1           ; syscall number for write
  syscall

  mov rax, [sum]
  call print

  mov rdx, len
  mov rsi, void_row
  mov rdi, 1           ; file descriptor, in this case stdout
  mov rax, 1           ; syscall number for write
  syscall

  mov rax, 60 ; sys_exit
  mov rdi, 0  ; код завершения 0
  syscall

print:
      mov rcx, 0
      mov rbx, 10
      .next_digit:
        xor rdx, rdx       ; clear rdx prior to dividing edx:eax by ebx
        div rbx            ; rax /= 10
        add dl, 48        ; convert the remainder to ASCII 

        xor r8, r8
        movsx r8, byte dl
        push r8

        add rcx, 1
        cmp rax, 0
      jne .next_digit    ; repeat until        

      .write:
        xor rdx, rdx
        pop rdx
        mov [rsi], dl
        mov r8, rcx; save

        mov rdx, 1      ; length of the string
        mov rdi, 1           ; file descriptor, in this case stdout
        mov rax, 1           ; syscall number for write
        syscall

        mov rcx, r8 ;restore
        dec rcx
        test rcx, rcx
      jnz .write
  ret
