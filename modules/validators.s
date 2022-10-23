.intel_syntax noprefix

.section	.rodata
.LC4:
	.string	"Incorrect size of array"
.LC5:
	.string	"Incorrect element in array"
	.text
	.globl	validateInput
	.type	validateInput, @function
validateInput:
	                                # /
	push	rbp                     # |
	mov	rbp, rsp                    # | Пролог
	sub	rsp, 16						# | 
	
	mov	r12d, edi					# | r12d := edi = int code1 -- первый входной параметр загружаем в регистр
	mov	r13d, esi					# | r13d := esi = int code2 -- второй входной параметр загружаем в регистр
	cmp	r12d, 1						# | Сравниваем code1 (r12d) и 1
	jne	.L51						# | Если не равны, переходим к следующему if
	lea	rdi, .LC4[rip]				# | Иначе загружаем в rdi адрес на начало строки для печати -- первый аргумент для вызова printf: rdi = &rip[.LC4]
	mov	eax, 0						# | eax := 0
	call	printf@PLT				# | Вызываем printf(rdi=&rip[.LC4])
	mov	eax, 1						# | Возвращаем 1 через eax // return 1;
	jmp	.L52						# | Переходим к эпилогу
.L51:
	cmp	r13d, 1						# | Сравниваем code2 (r13d) и 1
	jne	.L53						# | Если не равны, переходим к возврату 0 
	lea	rdi, .LC5[rip]				# | Иначе загружаем в rdi адрес на начало строки для печати -- первый аргумент для вызова printf: rdi = &rip[.LC5]
	mov	eax, 0						# | eax := 0
	call	printf@PLT				# | Вызываем printf(rdi=&rip[.LC4])
	mov	eax, 1						# | Возвращаем 1 через eax // return 1;
	jmp	.L52						# | Переходим к эпилогу
.L53:
	mov	eax, 0						# | Возвращаем 0 через eax // return 0;
.L52:
	leave                           # | Эпилог
	ret                             # \
# ^
# Вместо стека теперь используем регистры r12, r13
