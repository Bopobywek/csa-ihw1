.intel_syntax noprefix

.globl	getMin
	.type	getMin, @function
getMin:                             # Функция нахождения минимума в массиве
	push	rbp                     # |
	mov	rbp, rsp                    # | Пролог
	
    mov	r9, rdi     				# r9 := rdi // Оптимизиция, кладем int *array в регистр r9, а не на стек
	mov	r10d, esi     				# r10 := esi // Оптимизиция, кладем int array_size в регистр r10, а не на стек
	mov	r11d, DWORD PTR A[rip]      # Оптимизируем, кладем минимальный элемент в регистр, а не на стек. int min = A[i];
	mov	ecx, 1        				# Снова оптимизация, заводим счётчик в регистре ecx. Обходимся без стека
    
    jmp	.L2                         # Переходим на метку, в которой будет проверяться условие цикла

.L5:                                # В метке .L5 проверяется условию внутри оператора if
	cmp	r11d, 0        				# Сравниваем min (r11) и 0
	je	.L3                         # min == 0 => условие истинно, переходим в тело условного оператора
	mov	eax, ecx      				# eax := ecx // <=> eax := i
	cdqe                            # rax := sign-extend of eax. Копирует знак (31 бит) в старшие 32 бита регистра rax
	lea	rdx, 0[0+rax*4]             # rdx := rax * 4 // Подобным трюком вычисляется адрес (rax*4)[0], который равен rax * 4             
	lea	rax, A[rip]                 # rax := &rip[A] -- адрес начала массива
	mov	eax, DWORD PTR [rdx+rax]    # eax := [rdx + rax] // <=> eax := A[i]
	cmp	r11d, eax      				# Сравниваем min (r11) и A[i] (eax)
	jle	.L4                         # Если min <= A[i], условие не выполняется и мы переходим на следуюзую итерацию
	                                # Иначе проверяем, второй операнд &&
    mov	eax, ecx      				# eax := ecx // <=> eax := i
	cdqe                            # rax := sign-extend of eax. Копирует знак (31 бит) в старшие 32 бита регистра rax 
	lea	rdx, 0[0+rax*4]             # rdx := rax * 4 // Подобным трюком вычисляется адрес (rax*4)[0], который равен rax * 4
	lea	rax, A[rip]                 #
	mov	eax, DWORD PTR [rdx+rax]    # eax := [rdx + rax] // <=> eax := A[i]
	test	eax, eax                # 
	je	.L4                         #

.L3:                                # Тело условного оператора
	mov	eax, ecx      				# eax := ecx // <=> eax := i
	cdqe                            # rax := sign-extend of eax. Копирует знак (31 бит) в старшие 32 бита регистра rax
	lea	rdx, 0[0+rax*4]             # rdx := rax * 4 // Подобным трюком вычисляется адрес (rax*4)[0], который равен rax * 4 
	lea	rax, A[rip]                 # rax := &rip[A] -- адрес на начало массива
	mov	eax, DWORD PTR [rdx+rax]    # eax := [rdx + rax] // <=> eax := A[i]
	mov	r11d, eax      				# r11d := eax // <=> min := A[i] 

.L4:
	add	ecx, 1        				# ecx += 1 // <=> ++i

.L2:
	# mov	eax, ecx    <= нет необходимости, в следующей строке меняем `cmp eax, r10d` на `cmp ecx, r10d`   				
	cmp	ecx, r10d     				# Сравниваем значение счётчика (eax) и array_size (rbp[-28])
	
    jl	.L5                         # Если i < array_size, переходим в тело цикла.
                                    # Иначе возвращаем значение через eax и выходим из функции
                                                                    
	mov	eax, r11d      				# eax := r11d // <=> eax := min
    
	leave                        # | Эпилог функции           
	ret                             # \

#
#	
# Перенесли хранение локальных переменных со стека в регистры.
# Получилось заменить способ хранения для всех локальных переменных.
#
