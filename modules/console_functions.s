.intel_syntax noprefix
  .section	.rodata
.LC0:
	.string	"%d"
	.text
	.globl	readArraySizeFromConsole
	.type	readArraySizeFromConsole, @function
readArraySizeFromConsole:
	push	rbp                     # |
	mov	rbp, rsp                    # | Пролог
	push r12
	sub	rsp, 8                      # |

	mov	r12, rdi      				# | r12 := rdi <=> r12 := size -- кладём в регистр первый аргумент (указатель на число)
	mov	rax, r12      				# | rax := r12 <=> rax := size -- теперь в rax лежит int *size
	mov	rsi, rax                    # | rsi := rax <=> rax := size // rsi -- второй аргумент для вызова scanf 
	lea	rdi, .LC0[rip]              # | rdi := &rip[.LC0] -- адрес на начало форматной строки // rdi -- первый аргумент
	mov	eax, 0                      # | Обнуляем eax
	call	__isoc99_scanf@PLT      # | Вызываем scanf
	
	mov	rax, r12						# | rax := r12 <=> rax := size
	mov	eax, DWORD PTR [rax]		# | eax := [eax] <=> eax := *(eax) // size -- указатель, поэтому нужно разыменовать его.
	mov	edx, 10000000				# | edx := 10000000 -- const int MAX_N
	cmp	eax, edx					# | Сравниваем *size (eax) и MAX_N (edx)
	jg	.L13						# | Если *size > MAX_N, переходим к метке .L13 
	mov	rax, r12						# | rax := size
	mov	eax, DWORD PTR [rax]		# | eax := [rax] -- снова разыменовываем указатель
	test	eax, eax				# | test выполняет логическое И между всеми битами двух операндов, но в отличие от AND изменяет только флаговый регистр. 
	jg	.L14						# | 
.L13:
	mov	eax, 1						# | Ввод некорректный => возвращаем 1 через eax
	jmp	.L15						# | Переходим к эпилогу
.L14:
	mov	eax, 0						# | Ввод корректный, возвращаем 0 через eax
.L15:
	add rsp, 8
	pop r12						    # | Эпилог
	pop rbp
	ret								# \


# ^
# Использование стека удалось сократить, используем регистр r12
#

   .globl	readArrayFromConsole
	.type	readArrayFromConsole, @function
readArrayFromConsole:
	push	rbp                     # |
	mov	rbp, rsp                    # | Пролог функции
	push r12
	push r13						# | <= не портим callee-saved регистры
	push r14
	push r15
	sub	rsp, 32                     # |
	
	mov	r14, rdi     				# | r14 := rdi <=> r14 = array -- загружаем в регистр первый аргумент (указатель на начало массива)
	mov	r13d, esi     				# | r13d := esi <=> r13d = size -- загружаем в регистр второй переданный аргумент (размер массива)
	mov	r12d, 0        				# | r12d := 0 <=> int i = 0 // Заводим счётчик
	jmp	.L22						# | Переходим на метку, в которой проверяется условие цикла
.L23:
	mov	eax, r12d      				# | eax := i // r12d = i
	cdqe                            # | rax := sign-extend of eax. Копирует знак (31 бит) в старшие 32 бита регистра rax
	lea	rdx, 0[0+rax*4]             # | rdx := rax * 4 // Подобным трюком вычисляется адрес (rax*4)[0], который равен rax * 4 
	mov	rax, r14     				# | rax := array
	add	rax, rdx                    # | rax += rdx // теперь в rax адрес i-ой ячейки массива
	mov	rsi, rax                    # | rsi := rax
	lea	rdi, .LC0[rip]              # | rdi := &rip[.LC0]
	mov	eax, 0                      # | eax := 0
	call	__isoc99_scanf@PLT      # | Вызываем scanf(rdi=&rip[.LC0], rsi=&array[i])
	add	r12d, 1        				# | ++i // r12d = i
.L22:
	mov	eax, r12d      				# | eax := r12d <=> eax := i
	cmp	eax, r13d     				# | Сравниваем i (eax) и size (r13d)
	jl	.L23						# | Если i < size, переходим к следующей итерации цикла
	mov	eax, 0                      # | Возвращаем 0 через eax <=> return 0
	
	add rsp, 32                     # | Эпилог функции
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret                             # \



	.section	.rodata
.LC1:
	.string	"%d "
	.text
	.globl	writeArrayToConsole
	.type	writeArrayToConsole, @function
writeArrayToConsole:
	                                # /
	push	rbp                     # |
	mov	rbp, rsp                    # | Пролог
	sub	rsp, 32                     # |
	
	mov	r12, rdi     				# | r12 := rdi // Загружаем в регистр первый аргумент -- указатель на начало массива int *array
	mov	r13d, esi     				# | r13d := esi // Загружаем в регистр второй аргумент -- размер массива int size
	mov	r14d, 0        				# | r14d := 0 <=> int i = 0 // Запомним, что r14d = i
	jmp	.L31						# | Переходим на метку .L31, в которой проверится условие выхода из цикла
.L32:
	mov	eax, r14d      				# | eax := i
	cdqe                            # | rax := sign-extend of eax. Копирует знак (31 бит) в старшие 32 бита регистра rax
	lea	rdx, 0[0+rax*4]             # | rdx := rax * 4 // Подобным трюком вычисляется адрес (rax*4)[0], который равен rax * 4
	mov	rax, r12     				# | rax := array -- указатель на начало массива
	add	rax, rdx                    # | rax := rax + rdx -- вычисляем адрес i-ого элемента массива
	mov	eax, DWORD PTR [rax]        # | eax := *(rax) <=> eax := array[i]
	mov	esi, eax                    # | esi := eax -- второй аргумент (array[i]) для вызова printf   
	lea	rdi, .LC1[rip]              # | rdi := &rip[.LC1] -- первый аргумент (адрес начала форматной строки) для вызова printf
	mov	eax, 0                      # | eax := 0
	call	printf@PLT              # | Вызываем printf(rdi=&rip[.LC1], rsi=array[i])
	add	r14d, 1        				# | ++i
.L31:
	# mov	eax, r14d     <===    теперь не нужно 	
	cmp	r14d, r13d     				# | Сравниваем i (r14d) и size (r13d)
	jl	.L32						# | Если i < size, переходим к следующей итерации цикла
	mov	edi, 10                     # | Иначе edi := 10 -- первый аргумент для вызова putchar (записывает единственный char в поток вывода)
	call	putchar@PLT             # | Вызываем putchar(edi=10) // 10 = '\n'
	mov	eax, 0                      # | eax := 0
	
    leave                           # | Эпилог
	ret                             # \

# ^
# Вместо стека теперь используем регистры r12, r13, r14

.section	.rodata
	.align 8
.LC6:
	.string	"Input array size 0 < size < 1'000'000: "
	.align 8
.LC7:
	.string	"Enter the array elements in a row separated by a space:"
	.text
	.globl	handleConsoleInput
	.type	handleConsoleInput, @function
handleConsoleInput:
	                                # /
	push	rbp                     # |
	mov	rbp, rsp                    # | Пролог
	sub	rsp, 32						# |
	
	mov	r13, rdi					# | r13 := rdi = int *size -- первый входной параметр загружаем в регистр
	lea	rdi, .LC6[rip]				# | rdi := &rip[.LC6] -- адрес начала строки для печати
	mov	eax, 0						# | eax := 0
	call	printf@PLT				# | Вызываем printf(rdi=&rip[.LC6])
	
	mov	rax, r13					# | rax := size
	mov	rdi, rax					# | rdi := rax = size
	call	readArraySizeFromConsole # \ Вызываем readArraySizeFromConsole(rdi=size)	
	
	mov	r15d, eax					#  / r15d := eax <=> int code1 = возвращенное значение от readArraySizeFromConsole(rdi=size)
	lea	rdi, .LC7[rip]				# | rdi := &rip[.LC7] -- адрес начала строки для печати
	call	puts@PLT				# | Вызываем puts(rdi=&rip[.LC7])
	
	mov	rax, r13					# | rax := r13 = size
	mov	eax, DWORD PTR [rax]		# | eax := [rax] = *size
	mov	esi, eax					# | esi := eax = *size
	lea	rdi, A[rip]					# | rdi := &rip[A] -- адре на начало массива A
	call	readArrayFromConsole	# | Вызываем readArrayFromConsole(rdi=&rip[A], esi=*size)
	
	mov	r14d, eax					# | r14d := eax <=> int code2 = возвращенное значение от readArrayFromConsole(rdi=&rip[A], esi=*size)
	mov	edx, r14d					# | edx := r14d = code2
	mov	eax, r15d					# | eax := r15d = code1
	mov	esi, edx					# | esi := edx = code2
	mov	edi, eax					# | edi := eax = code1
	call	validateInput@PLT			# | Вызываем validateInput(edi=code1, esi=code2)
									# | Значение возвращаем через eax так же, как и validateInput, поэтому ничего не делаем и переходим к эпилогу 
	leave							# | Эпилог
	ret								# \
# ^
# Вместо стека теперь используем регистры r13, r14, r15	