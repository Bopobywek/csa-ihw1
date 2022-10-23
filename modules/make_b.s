.intel_syntax noprefix

.globl	makeB
	.type	makeB, @function
makeB:
	push	rbp                     # | Пролог функции
	mov	rbp, rsp
	sub	rsp, 24                     # |

	mov	r12d, edi     				# | r12d := edi -- положили в r12d первый аргумент int array_size. Провели оптимизацию
	# mov	eax, r12d     <===== исключаем лишнее копирование
	mov	esi, r12d                    # | esi := eax -- в esi теперь array_size
	lea	rdi, A[rip]                 # | rdi := &rip[A] -- адрес на начало массива
	
    call	getMin                  # | Вызов функции getMin. Первый аргумент в rdi = &rip[A], второй в esi (rsi) = array_size
                                    # | Результат возвращается через eax
	
    mov	r14d, eax      				# | r14d := eax // <=> int min = getMin(A, array_size)
	mov	r13d, 0        				# | r13d := 0 // <=> int i = 0
	jmp	.L8         
.L11:                               #
	mov	eax, r13d      				# | eax := r13d // <=> eax := i
	cdqe                            # | rax := sign-extend of eax. Копирует знак (31 бит) в старшие 32 бита регистра rax
	lea	rdx, 0[0+rax*4]             # | rdx := rax * 4 // Подобным трюком вычисляется адрес (rax*4)[0], который равен rax * 4
	lea	rax, A[rip]                 # | rax := &rip[A] -- адрес начала массива
	mov	eax, DWORD PTR [rdx+rax]    # | eax := [rdx + rax] // <=> eax := A[i]
	test	eax, eax                #
	jne	.L9                         #
	mov	eax, r13d      				# | eax := r13d // <=> eax := i
	cdqe                            # | rax := sign-extend of eax. Копирует знак (31 бит) в старшие 32 бита регистра rax
	lea	rcx, 0[0+rax*4]             # | rcx := rax * 4 // Подобным трюком вычисляется адрес (rax*4)[0], который равен rax * 4 
	lea	rdx, B[rip]                 # | rdx := &rip[B] -- адрес начала массива B
	mov	eax, r14d      				# | eax := r14d // <=> eax := min
	mov	DWORD PTR [rcx+rdx], eax    # | [rcx + rdx] := eax // <=> B[i] = min
	jmp	.L10                        # | Переходим на метку увеличения счётчика

.L9:                                # | метка .L9 -- else
	mov	eax, r13d      				# | eax := r13d // eax := i
	cdqe                            # | rax := sign-extend of eax. Копирует знак (31 бит) в старшие 32 бита регистра rax
	lea	rdx, 0[0+rax*4]             # | rdx := rax * 4 // Подобным трюком вычисляется адрес (rax*4)[0], который равен rax * 4
	lea	rax, A[rip]                 # | rax := &rip[A] -- адрес начала массива A
	mov	eax, DWORD PTR [rdx+rax]    # | eax := [rdx + rax] <=> eax := A[i]
	mov	edx, r13d      				# | edx := r13d <=> edx := i
	movsx	rdx, edx                # | rdx := edx // Тот же mov, но уже со знаковым расширением (sign-extend).
                                    # | Предположительно используется потому, что cdqe нельзя использовать из-за того, что rax занят
	lea	rcx, 0[0+rdx*4]             # | rcx := rax * 4 // Подобным трюком вычисляется адрес (rax*4)[0], который равен rax * 4 
	lea	rdx, B[rip]                 # | rdx := &rip[B] -- адрес на начало массива B
	mov	DWORD PTR [rcx+rdx], eax    # | [rcx + rdx] := eax <=> B[i] := A[i]

.L10:                               # | метка увеличения счётчика
	add	r13d, 1        				# | ++r13d <=> ++i

.L8:                            
	# mov	eax, r13d      	<=== 	теперь у нас есть регистры, мы можем сразу сравнивать значения в них
	cmp	r13d, r12d     				# | Сравниваем i (eax) и array_size (rbp[-20])
	jl	.L11                        # | Если i < array_size, переходим к телу цикла
	
	leave						# | Эпилог функции
	ret                             # \

# ^
# Заменили использование стека на использование регистров r12, r13 и r14
#
#
