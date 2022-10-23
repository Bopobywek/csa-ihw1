	.intel_syntax noprefix
	.text
	.local	A
	.comm	A,40000000,32
	.local	B
	.comm	B,40000000,32
	.globl	MAX_N
	.section	.rodata
	.type	MAX_N, @object
	.size	MAX_N, 4
MAX_N:
	.long	10000000
	.globl	SAMPLE_SIZE
	.type	SAMPLE_SIZE, @object
	.size	SAMPLE_SIZE, 4
SAMPLE_SIZE:
	.long	10
	.text
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
	sub	rsp, 8                     # |

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
# Использование стека удалось сократить, однако перед вызывом функции из libc, пришлось сохранить значение регистра на стек
#

    .globl	readArraySizeFromFile
	.type	readArraySizeFromFile, @function
readArraySizeFromFile:
	push	rbp                     # |
	mov	rbp, rsp                    # | Пролог
	push r12
	push r13
	sub	rsp, 16                     # |
	
	mov	r12, rdi      				# | r12 := rdi <=> r12 := fin -- сохраняем в регистр указатель на файл (первый аргумент).
	mov	r13, rsi     				# | r13 := rsi <=> r13 := size -- сохраняем в регистр указатель на число (второй аргумент).
	cmp	r12, 0						# | Сравниваем fin (r12) и NULL (0)
	jne	.L17						# | Если не равны, прыгаем на метку .L17
	mov	eax, 1						# | Иначе возвращаем через eax 1, которая сообщает о невозможности чтения файла
	jmp	.L18						# | И переходим к эпилогу на метку .L18
.L17:
	mov	rdx, r13     				# | rdx := r13 <=> rdx := size (третий аргумент для вызова fscanf)
	mov	rax, r12      				# | rax := r12 <=> rax := fin
	lea	rsi, .LC0[rip]              # | rsi := &rip[.LC0] -- адрес начала форматной строки (второй аргумент для вызова fscanf)
	mov	rdi, rax                    # | rdi := rax -- указатель на файл (первый аргумент для вызова fscanf) 
	mov	eax, 0                      # | Обнуляем eax
	call	__isoc99_fscanf@PLT     # | Вызываем fscanf
	
	mov	rax, r13     				# | rax := r13 <=> rax := size
	
	mov	eax, DWORD PTR [rax]		# | eax := [eax] <=> eax := *(eax) // size -- указатель, поэтому нужно разыменовать его.
	mov	edx, 10000000				# | edx := 10000000 -- const int MAX_N
	cmp	eax, edx					# | Сравниваем *size (eax) и MAX_N (edx)
	jg	.L19						# | Если *size > MAX_N, переходим к метке .L19	
	mov	rax, r13					# | rax := size
	mov	eax, DWORD PTR [rax]		# | eax := [rax] -- снова разыменовываем указатель
	test	eax, eax				# | test выполняет логическое И между всеми битами двух операндов, но в отличие от AND изменяет только флаговый регистр.
	jg	.L20						# |
.L19:
	mov	eax, 1						# | Иначе возвращаем 1 через eax
	jmp	.L18						# | И переходим на метку с эпилогом
.L20:
	mov	eax, 0                      # | Возвращаем 0 через eax 
.L18:
	add rsp, 16                     # | Эпилог функции
	pop r13
	pop r12
	pop rbp
	ret                             # \ 

# ^
# Удалось сократить использование стека, теперь fin хранится в r12, size в r13
	
    .globl	readArrayFromConsole
	.type	readArrayFromConsole, @function
readArrayFromConsole:
	push	rbp                     # |
	mov	rbp, rsp                    # | Пролог функции
	push r12
	push r13
	push r14
	push r15
	sub	rsp, 32                     # |
	
	mov	r14, rdi     				# | r14 := rdi <=> r14 = array -- загружаем в регистр первый аргумент (указатель на начало массива)
	mov	r13d, esi     				# | r13d := esi <=> r13d = size -- загружаем на стек второй переданный аргумент (размер массива)
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


	.globl	readArrayFromFile
	.type	readArrayFromFile, @function
readArrayFromFile:
	                                # /
	push	rbp                     # |
	mov	rbp, rsp                    # | Пролог
	sub	rsp, 48                     # |
	
	mov	r12, rdi     # | rbp[-24] := rdi <=> rbp[-24] := fin -- загружаем на стек первый аргумент (указатель на FILE)
	mov	r13, rsi     # | rbp[-32] := rsi <=> rbp[-32] := array -- загружаем на стек второй аргумент (указатель на начало массива)
	mov	r14d, edx     # | rbp[-36] := edx <=> rbp[-36] := size -- загружаем на стек третий аргумент (размер массива)
	cmp	r12, 0       # | Сравниваем fin (rbp[-24]) и NULL (0)
	jne	.L26						# | Если fin не NULL, идем дальше -- на метку .L26
	mov	eax, 1						# | Иначе кладем в eax 1 для возврата.
	jmp	.L27						# | И прыгаем на метку .L27 -- эпилог функции
.L26:
	mov	DWORD PTR -4[rbp], 0        # | rbp[-4] := 0 -- заводим счётчик i
	jmp	.L28						# | Переходим к метке, в которой проверяется условие цикла
.L29:
	mov	eax, DWORD PTR -4[rbp]      # | eax := i // rbp[-4] = i
	cdqe                            # | rax := sign-extend of eax. Копирует знак (31 бит) в старшие 32 бита регистра rax
	lea	rdx, 0[0+rax*4]             # | rdx := rax * 4 // Подобным трюком вычисляется адрес (rax*4)[0], который равен rax * 4
	mov	rax, r13     # | rax := array 
	add	rdx, rax                    # | rdx := rax + rdx // rdx = &array[i]
	mov	rax, r12     # | rax := fin
	lea	rsi, .LC0[rip]              # | rsi := &rip[.LC0] -- второй аргумент для вызова fscanf (адрес начала форматной строки)
	mov	rdi, rax                    # | rdi := rax <=> rdi := fin -- первым аргументом передаем указатель на FILE
	mov	eax, 0                      # | eax := 0
	call	__isoc99_fscanf@PLT     # | Вызываем fscanf
	add	DWORD PTR -4[rbp], 1		# | ++i
.L28:
	mov	eax, DWORD PTR -4[rbp]      # | eax := i // rbp[-4] = i
	cmp	eax, r14d     # | Сравниваем i (eax) и size (rbp[-36])
	jl	.L29						# | Если i < size, прыгаем на метку .L29 -- тело цикла
	mov	eax, 0						# | Иначе возвращаем 0 -- знак, что всё прошло без ошибок
.L27:
	leave                           # | Эпилог функции
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
	
	mov	r12, rdi     # | rbp[-24] := rdi // Загружаем на стек первый аргумент -- указатель на начало массива int *array
	mov	r13d, esi     # | rbp[-28] := esi // Загружаем на стек второй аргумент -- размер массива int size
	mov	r14d, 0        # | rbp[-4] := 0 <=> int i = 0 // Запомним, что rbp[-4] = i
	jmp	.L31						# | Переходим на метку .L31, в которой проверится условие выхода из цикла
.L32:
	mov	eax, r14d      # | eax := i
	cdqe                            # | rax := sign-extend of eax. Копирует знак (31 бит) в старшие 32 бита регистра rax
	lea	rdx, 0[0+rax*4]             # | rdx := rax * 4 // Подобным трюком вычисляется адрес (rax*4)[0], который равен rax * 4
	mov	rax, r12     # | rax := array -- указатель на начало массива
	add	rax, rdx                    # | rax := rax + rdx -- вычисляем адрес i-ого элемента массива
	mov	eax, DWORD PTR [rax]        # | eax := *(rax) <=> eax := array[i]
	mov	esi, eax                    # | esi := eax -- второй аргумент (array[i]) для вызова printf   
	lea	rdi, .LC1[rip]              # | rdi := &rip[.LC1] -- первый аргумент (адрес начала форматной строки) для вызова printf
	mov	eax, 0                      # | eax := 0
	call	printf@PLT              # | Вызываем printf(rdi=&rip[.LC1], rsi=array[i])
	add	r14d, 1        # | ++i
.L31:
	mov	eax, r14d      # | eax := i
	cmp	eax, r13d     # | Сравниваем i (eax) и size (rbp[-28])
	jl	.L32						# | Если i < size, переходим к следующей итерации цикла
	mov	edi, 10                     # | Иначе edi := 10 -- первый аргумент для вызова putchar (записывает единственный char в поток вывода)
	call	putchar@PLT             # | Вызываем putchar(edi=10) // 10 = '\n'
	mov	eax, 0                      # | eax := 0
	
    leave                           # | Эпилог
	ret                             # \


	.globl	writeArrayToFile
	.type	writeArrayToFile, @function
writeArrayToFile:
	                                # /
	push	rbp                     # |
	mov	rbp, rsp                    # | Пролог
	sub	rsp, 48                     # |
	
	mov	r12, rdi     # | rbp[-24] := rdi -- первый переданный аргумент (FILE *fout) загружаем на стек 
	mov	r13, rsi     # | rbp[-32] := rsi -- загружаем на стек второй переданный аргумент (int *array -- указатель на начало массива)
	mov	r15d, edx     # | rbp[-36] := edx -- загружаем на стек третий переданный аргумент (int size -- размер массива)
	cmp	r12, 0       # | Сравниваем fout (rbp[-24]) и NULL (0)
	jne	.L35						# | Если fout не NULL, переходим к метке .L35
	mov	eax, 1                      # | Иначе возвращаем 1 через eax
	jmp	.L36						# | И прыгаем на эпилог
.L35:
	mov	r14d, 0        # | rbp[-4] = 0 <=> int i = 0		
	jmp	.L37						# | Переходим на метку .L37
.L38:
	mov	eax, r14d      # | eax := i
	cdqe                            # | rax := sign-extend of eax. Копирует знак (31 бит) в старшие 32 бита регистра rax
	lea	rdx, 0[0+rax*4]             # | rdx := rax * 4 // Подобным трюком вычисляется адрес (rax*4)[0], который равен rax * 4
	mov	rax, r13     # | rax := array
	add	rax, rdx                    # | rax := rax + rdx // rax := &array[i]
	mov	edx, DWORD PTR [rax]        # | edx := [rax] <=> edx := *(rax + rdx) = array[i] -- третий аргумент для вызова fprintf
	mov	rax, r12     # | rax := fout
	lea	rsi, .LC1[rip]              # | rsi := &rip[.LC1] -- второй аргумент для вызова fprintf (форматная строка)
	mov	rdi, rax                    # | rdi := rax = fout -- первый аргумент для вызова fprintf 
	mov	eax, 0                      # | eax := 0
	call	fprintf@PLT             # | Вызываем fprintf(rdi=fout, rsi=&rip[.LC1], rdx=array[i])
	add	r14d, 1        # | ++i
.L37:
	mov	eax, r14d      # | eax := i
	cmp	eax, r15d     # | Сравниваем eax (i) и size (rbp[-36])
	jl	.L38						# | Если i < size, переходим к следующей итерации цикла
	mov	rax, r12     # | Иначе rax := fout
	mov	rsi, rax                    # | rsi := rax -- второй аргумент (fout) для вызова fputc
	mov	edi, 10                     # | edi := 10 -- первый аргумент (10 = '\n') для вызова fputc
	call	fputc@PLT               # | Вызываем fputc(rdi='\n', rsi=fout)
	mov	eax, 0                      # | Возвращаем 0 через eax
.L36:
	leave                           # | Эпилог
	ret                             # \

	.globl	getRandomArraySize
	.type	getRandomArraySize, @function
getRandomArraySize:
	                                # /
	push	rbp                     # |
	mov	rbp, rsp                    # | Пролог
	
	call	rand@PLT				# | Вызываем rand
	mov	ecx, eax					# | rand вернула число через eax, копируем его в ecx: ecx := eax
	movsx	rax, ecx				# | rax := ecx // Тот же mov, но уже со знаковым расширением (sign-extend).
	imul	rax, rax, 1717986919	# |=======================
	shr	rax, 32						# |	
	mov	edx, eax					# |
	sar	edx, 3						# |
	mov	eax, ecx					# |
	sar	eax, 31						# |  Тут очень сложно вычисляется
	sub	edx, eax					# |			(rax % 20) + 1
	mov	eax, edx					# |
	sal	eax, 2						# |
	add	eax, edx					# |
	sal	eax, 2						# |
	sub	ecx, eax					# |
	mov	edx, ecx					# |
	lea	eax, 1[rdx]					# |=======================
	
	pop	rbp							# | Эпилог
	ret								# \
	
	.globl	fillArrayWithRandom
	.type	fillArrayWithRandom, @function
fillArrayWithRandom:
	                                # /
	push	rbp                     # |
	mov	rbp, rsp                    # | Пролог
	push	r13
	push	rbx						# | Зачем-то на стек сохраняется rbx, который потом нигде всё равно не используются. Загадка...
	sub	rsp, 40						# |
	
	mov	r14, rdi		# | rbp[-40] := rdi = int *array
	mov	r12d, esi		# |	rbp[-44] := esi = int size
	mov	r13d, 0		# | rbp[-20] := 0 = i // Заводим счётчик цикла
	jmp	.L42						# | Переходим к проверке условия выхода из цикла
.L45:
	mov	eax, r13d		# | eax := rbp[-20] = i
	lea	ecx, 1[rax]					
	movsx	rax, ecx
	imul	rax, rax, 1431655766
	shr	rax, 32
	mov	rdx, rax
	mov	eax, ecx
	sar	eax, 31
	mov	esi, edx
	sub	esi, eax
	mov	eax, esi
	mov	edx, eax
	add	edx, edx
	add	edx, eax
	mov	eax, ecx
	sub	eax, edx
	test	eax, eax
	jne	.L43
	mov	eax, r13d		# |
	cdqe							# |
	lea	rdx, 0[0+rax*4]				# |
	mov	rax, r14		# |
	add	rax, rdx					# | 
	mov	DWORD PTR [rax], 0			# | <=> array [i] = 0
	jmp	.L44
.L43:
	call	rand@PLT				# | Вызываем rand без аргуметов
	movsx	rdx, eax				# | переносим возвращенное через eax значение в rdx sign-extend
	imul	rdx, rdx, 1374389535
	shr	rdx, 32
	mov	ecx, edx
	sar	ecx, 6
	cdq
	mov	ebx, ecx
	sub	ebx, edx
	imul	edx, ebx, 200
	sub	eax, edx
	mov	ebx, eax
	call	rand@PLT
	movsx	rdx, eax
	imul	rdx, rdx, 274877907
	shr	rdx, 32
	mov	ecx, edx
	sar	ecx, 4
	cdq
	sub	ecx, edx
	mov	edx, ecx
	imul	edx, edx, 250
	sub	eax, edx
	mov	edx, eax
	mov	eax, r13d					# |
	cdqe							# |
	lea	rcx, 0[0+rax*4]				# | Вычисляем адрес i элемента массива
	mov	rax, r14					# |
	add	rax, rcx					# |
	sub	ebx, edx
	mov	edx, ebx
	mov	DWORD PTR [rax], edx		# | <=> array[i] := edx = (rand() % 200) - (rand() % 250)
.L44:
	add	r13d, 1
.L42:
	mov	eax, r13d		# eax := rbp[-20] = i
	cmp	eax, r12d		# Сравниваем i (eax) и size (rbp[-44])
	jl	.L45						# Если i < size, переходим к следующей итерации цикла
	
	add	rsp, 40						# |
	pop	rbx							# |		Эпилог
	pop	r13
	pop	rbp							# |
	ret								# \ 
	
	.section	.rodata
.LC2:
	.string	"Incorrect input file"
.LC3:
	.string	"Incorrect output file"
	.text
	.globl	isFilesValid
	.type	isFilesValid, @function
isFilesValid:
	                                # /
	push	rbp                     # |
	mov	rbp, rsp                    # | Пролог
	sub	rsp, 32						# |
	
	mov	r12d, edi		# | Загружаем первый переданный аргумент int flag_in на стек. rbp[-4] := edi = flag_in
	mov	r13d, esi		# | Загружаем второй переданный аргумент int flag_in на стек. rbp[-8] := esi = flag_out
	mov	r14, rdx		# | rbp[-16] := rdx = input -- аналогично загружаем на стек третий переданный агрумент (указатель на FILE)
	mov	r15, rcx		# | Загружаем на стек 4 переданный аргумент FILE *output. rbp[-24] := rcx = output
	cmp	r12d, 1		# | Сравниваем flag_in (rbp[-4]) и 1
	jne	.L47						# | Если не равны, && не является истинной, поэтому прыгаем на метку .L47 -- следующий if
	cmp	r14, 0		# | Иначе сравниваем input (rbp[-16]) и NULL (0)
	jne	.L47						# | Если не равны, && не является истинной, поэтому прыгаем на метку .L47 -- следующий if
	lea	rdi, .LC2[rip]				# | Иначе, загружаем в rdi первый аргумент для вызова printf -- адрес на начало строки для печати: rdi := &rip[.LC2]
	mov	eax, 0						# | eax := 0
	call	printf@PLT				# | Вызываем printf(rdi=&rip[.LC2])
	mov	eax, 1						# | Возвращаем через eax 1 -- знак того, что файл не является валидным
	jmp	.L48						# | Переходим на метку с эпилогом
.L47:
	cmp	r13d, 1		# | Сравниваем flag_out (rbp[-8]) и 1
	jne	.L49						# | Если не равны, && не является истинной, переходим на метку с возвратом
	cmp	r15, 0		# | Иначе сравниваем output (rbp[-24]) и NULL (0)
	jne	.L49						# | Если не равны, && не является истинной, переходим на метку с возвратом
	lea	rdi, .LC3[rip]				# | Иначе загружаем в rdi первый аргумент для вызова printf -- адрес на начало строки для печати
	mov	eax, 0						# | eax := 0
	call	printf@PLT				# | Вызываем printf(rdi=&rip[.LC3])
	mov	eax, 1						# | Возвращаем через eax 1 -- знак того, что файл не является валидным
	jmp	.L48						# | Прыгаем на метку с эпилогом
.L49:
	mov	eax, 0						# | Возвращаем 0 через eax => файл можно читать
.L48:
	leave                           # | Эпилог
	ret                             # \
	
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
	
	mov	r12d, edi		# | rbp[-4] := edi = int code1 -- первый входной параметр загружаем на стек
	mov	r13d, esi		# |rbp[-4] := esi = int code2 -- второй входной параметр загружаем на стек
	cmp	r12d, 1		# | Сравниваем code1 (rbp[-4]) и 1
	jne	.L51						# | Если не равны, переходим к следующему if
	lea	rdi, .LC4[rip]				# | Иначе загружаем в rdi адрес на начало строки для печати -- первый аргумент для вызова printf: rdi = &rip[.LC4]
	mov	eax, 0						# | eax := 0
	call	printf@PLT				# | Вызываем printf(rdi=&rip[.LC4])
	mov	eax, 1						# | Возвращаем 1 через eax // return 1;
	jmp	.L52						# | Переходим к эпилогу
.L51:
	cmp	r13d, 1		# | Сравниваем code2 (rbp[-8]) и 1
	jne	.L53						# | Если не равны, переходим к возврату 0 
	lea	rdi, .LC5[rip]				# # | Иначе загружаем в rdi адрес на начало строки для печати -- первый аргумент для вызова printf: rdi = &rip[.LC5]
	mov	eax, 0						# | eax := 0
	call	printf@PLT				# | Вызываем printf(rdi=&rip[.LC4])
	mov	eax, 1						# | Возвращаем 1 через eax // return 1;
	jmp	.L52						# | Переходим к эпилогу
.L53:
	mov	eax, 0						# | Возвращаем 0 через eax // return 0;
.L52:
	leave                           # | Эпилог
	ret                             # \
	
	.globl	handleFileInput
	.type	handleFileInput, @function
handleFileInput:
	                                # /
	push	rbp                     # |
	mov	rbp, rsp                    # | Пролог
	sub	rsp, 32						# |
	
	mov	r15, rdi		# | rbp[-24] := rdi = FILE *input -- первый входной параметр загружаем на стек
	mov	r14, rsi		# | rbp[-32] := rsi = int *size -- второй входной параметр загружаем на стек
	mov	rdx, r14		# | rdx := rbp[-32] = size
	mov	rax, r15		# | rax := rbp[-24] = input
	mov	rsi, rdx					# |	rsi := rdx = size
	mov	rdi, rax					# |	rdi := rax = input
	call	readArraySizeFromFile   # | Вызываем readArraySizeFromFile(rdi=input, rsi=size)
	
	mov	ebx, eax		# | rbp[-4] := eax <=> int code1 = возвращенное значение от readArraySizeFromFile
	mov	rax, r14		# | rax := rbp[-32] = size
	mov	edx, DWORD PTR [rax]		# | edx := [rax] = *size
	mov	rax, r15		# |	rax := rbp[-24] = input
	lea	rsi, A[rip]					# |	rsi := &rip[A] -- адрес на начало массива A
	mov	rdi, rax					# | rdi := rax = input
	call	readArrayFromFile		# | Вызываем readArrayFromFile(rdi=input, rsi=&rip[A], edx=*size)
	
	mov	r12d, eax		# | rbp[-8] := eax <=> int code1 = возвращенное значение от readArraySizeFromFile
	mov	rax, r15		# | rax := rbp[-24] = input
	mov	rdi, rax					# |	rdi := rax = input
	call	fclose@PLT				# | Вызываем fclose(rdi=input)
	
	mov	edx, r12d		# | edx := rbp[-8] = code1
	mov	eax, ebx		# | eas := rbp[-4] = code2
	mov	esi, edx					# |	esi := edx = code2
	mov	edi, eax					# | edi := eax = code1
	call	validateInput			# | Вызываем validateInput(edi=code1, esi=code2)
									# | Значение возвращаем через eax так же, как и validateInput, поэтому ничего не делаем и переходим к эпилогу 
	leave							# | Эпилог
	ret								# \
	
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
	
	mov	r13, rdi		# | rbp[-24] := rdi = int *size -- первый входной параметр загружаем на стек
	lea	rdi, .LC6[rip]				# | rdi := &rip[.LC6] -- адрес начала строки для печати
	mov	eax, 0						# | eax := 0
	call	printf@PLT				# | Вызываем printf(rdi=&rip[.LC6])
	
	mov	rax, r13		# | rax := size
	mov	rdi, rax					# | rdi := rax = size
	call	readArraySizeFromConsole # \ Вызываем readArraySizeFromConsole(rdi=size)	
	
	mov	r15d, eax		#  / rbp[-4] := eax <=> int code1 = возвращенное значение от readArraySizeFromConsole(rdi=size)
	lea	rdi, .LC7[rip]				# | rdi := &rip[.LC7] -- адрес начала строки для печати
	call	puts@PLT				# | Вызываем puts(rdi=&rip[.LC7])
	
	mov	rax, r13		# | rax := rbp[-24] = size
	mov	eax, DWORD PTR [rax]		# | eax := [rax] = *size
	mov	esi, eax					# | esi := eax = *size
	lea	rdi, A[rip]					# | rdi := &rip[A] -- адре на начало массива A
	call	readArrayFromConsole	# | Вызываем readArrayFromConsole(rdi=&rip[A], esi=*size)
	
	mov	r14d, eax		# | rbp[-8] := eax <=> int code2 = возвращенное значение от readArrayFromConsole(rdi=&rip[A], esi=*size)
	mov	edx, r14d		# | edx := rbp[-8] = code2
	mov	eax, r15d		# | eax := rbp[-4] = code1
	mov	esi, edx					# | esi := edx = code2
	mov	edi, eax					# | edi := eax = code1
	call	validateInput			# | Вызываем validateInput(edi=code1, esi=code2)
									# | Значение возвращаем через eax так же, как и validateInput, поэтому ничего не делаем и переходим к эпилогу 
	leave							# | Эпилог
	ret								# \
	
	.section	.rodata
.LC8:
	.string	"Random array with size %d:\n"
	.text
	.globl	handleRandomInput
	.type	handleRandomInput, @function
handleRandomInput:
	                                # /
	push	rbp                     # |
	mov	rbp, rsp                    # | Пролог
	sub	rsp, 32						# |
	
	mov	rbx, rdi		# | rbp[-8] := rdi = int *size -- первый входной параметр загружаем на стек
	mov	r15, rsi		# | rbp[-16] := rsi = FILE *output -- второй входной параметр загружаем на стек
	mov	r13d, edx		# |	rbp[-20] := edx = int flag_file_out -- третий входной параметр загружаем на стек
	mov	eax, 0						# | eax := 0
	call	getRandomArraySize		# | Вызываем getRandomArraySize()
	
	mov	rdx, rbx		# | rdx := rbp[-8] = size
	mov	DWORD PTR [rdx], eax		# |	[rdx] := eax <=> *size = getRandomArraySize()
	mov	rax, rbx		# | rax := rbp[-8] = size
	mov	eax, DWORD PTR [rax]		# | eax := [rax] = *size
	mov	esi, eax					# |	esi := eax = *size
	lea	rdi, A[rip]					# | rdi := &rip[A] -- адрес на начало массива A
	call	fillArrayWithRandom		# | fillArrayWithRandom(rdi=&rip[A], esi=*size)
	
	cmp	r13d, 0		# | Сравниваем flag_file_out(rbp[-20) и 0
	jne	.L59						# |	Если не равны, переходим к else на метку .L59
	
	mov	rax, rbx		# | rax := rbp[-8] = size
	mov	eax, DWORD PTR [rax]		# | eax := [rax] = *size
	mov	esi, eax					# | esi := eax
	lea	rdi, .LC8[rip]				# | rdi := &rip[.LC8] -- адрес начала строки для печати
	mov	eax, 0						# | eax := 0
	call	printf@PLT				# | printf(rdi=&rip[.LC8], esi=*size)
	
	mov	rax, rbx		# | rax := rbp[-8] = size
	mov	eax, DWORD PTR [rax]		# | eax := [rax] = *size
	mov	esi, eax					# | esi := eax
	lea	rdi, A[rip]					# | rdi = &rip[A] -- адрес начала массива A
	call	writeArrayToConsole		# | writeArrayToConsole(rdi=&rip[A], esi=*size)
	
	jmp	.L60						# | Переходим на метку с эпилогом

.L59:								# | else				
	mov	rax, rbx		# | rax := rbp[-8] = size
	mov	edx, DWORD PTR [rax]		# | edx := [rax] = *size
	mov	rax, r15		# | rax := rbp[-16] = output
	lea	rsi, A[rip]					# | rsi := &rip[A] -- адрес начала массива
	mov	rdi, rax					# | rdi := rax
	call	writeArrayToFile		# | writeArrayToFile(rdi=output, rsi=&rip[A], edx=*size)
.L60:
	mov	eax, 0						# | Возвращаем 0 // return 0
	
	leave							# | Эпилог
	ret								# \
	
	.globl	getTimeDiff
	.type	getTimeDiff, @function
getTimeDiff:
	                                # /
	push	rbp                     # |
	mov	rbp, rsp                    # | Пролог
	
									# | Блок со странными обменами
	mov	rax, rsi					# | rax := rsi = ts1.tv_nsec
	mov	r8, rdi						# | r8 := rdi = ts1.tv_sec
	mov	rsi, r8						# | rsi := r8 = ts1.tv_sec
	mov	rdi, r9						# | rdi := r9 // ?????
	mov	rdi, rax					# | rdi := rax = ts1.tv_nsec 
	# Вообще странная штука, поменяли местами rdi и rsi, с лишним действием...
	# При сокращении кода можно попробовать удалить
	
	mov	r12, rsi		# | rbp[-32] := rsi = ts1.tv_sec
	mov	r13, rdi		# | rbp[-24] := rsi = ts1.tv_nsec
	mov	r14, rdx		# | rbp[-48] := rdx = ts2.tv_sec
	mov	r15, rcx		# | rbp[-40] := rdx = ts2.tv_nsec
	
	
	mov	rax, r12		# | rax := rbp[-32] = ts1.tv_sec
	imul	rsi, rax, 1000			# | rsi := rax * 1000 = ts1.tv_sec * 1000
	mov	rcx, r13		# | rcx := rbp[-24] = ts1.tv_nsec
	movabs	rdx, 4835703278458516699 # \ Второй операнд очень похож на константу 1000000.
	mov	rax, rcx					#  / rax := rcx = ts1.tv_nsec
	imul	rdx						# | rdx:rax := rax * rdx
	sar	rdx, 18						# | 
	mov	rax, rcx					# | 
	sar	rax, 63						# | sar -- побитовый сдвиг вправо
	sub	rdx, rax					# |	происходит какая-то арифметика... 
	mov	rax, rdx					# |
	add	rax, rsi					# | rax := rax + rsi
	mov	QWORD PTR -8[rbp], rax		# | rbp[-8] := rax = ts1_ms
	mov	rax, r14     # | rax := rbp[-48] = ts2.tv_sec
	imul	rsi, rax, 1000			# |	rsi := rax * 1000
	mov	rcx, r15		# \ rcx := rbp[-40] = ts2.tv_nsec
	movabs	rdx, 4835703278458516699 # | Снова арифметика
	mov	rax, rcx					# /	
	imul	rdx						# |	
	sar	rdx, 18						# |
	mov	rax, rcx					# |
	sar	rax, 63						# |
	sub	rdx, rax					# |
	mov	rax, rdx					# |
	add	rax, rsi					# | rax := rax + rsi
	mov	QWORD PTR -16[rbp], rax		# | rbp[-16] := rax = ts2_ms
	mov	rax, QWORD PTR -8[rbp]		# | rax := rbp[-8] = ts1_ms
	sub	rax, QWORD PTR -16[rbp]		# | rax := rax - rbp[-16] = ts1_ms - ts2_ms
									# | Возвращаем результат через rax
									
	pop	rbp							# | Эпилог			
	ret								# \
	
	.globl	measureTime
	.type	measureTime, @function
measureTime:
	                                # /
	push	rbp                     # |
	mov	rbp, rsp                    # | Пролог
	sub	rsp, 48						# |
	
	mov	QWORD PTR -8[rbp], 0		# | rbp[-8] := 0 = elapsed 		
	mov	DWORD PTR -12[rbp], 0		# | rbp[-12] := 0 = i // Заводим счётчик цикла i
	jmp	.L65						# | Переходим к метке, которая проверяет условие выхода из цикла
.L66:
	mov	eax, 10000000				# | eax := 10000000 = MAX_N
	mov	esi, eax					# | esi := eax = MAX_N
	lea	rdi, A[rip]					# | rdi := &rip[A] -- адрес начала массива
	call	fillArrayWithRandom		# | fillArrayWithRandom(rdi=&rip[A], esi=10000000)
	
	lea	rax, -32[rbp]				# | rax := rbp[-32] = &start
	mov	rsi, rax					# | rsi := rax
	mov	edi, 1						# | edi := 1 -- CLOCK_MONOTONIC
	call	clock_gettime@PLT		# | clock_gettime(edi=1, rsi=&start)
	
	mov	eax, 10000000				# | eax := 10000000 = MAX_N
	mov	edi, eax					# | edi := eax = 10000000
	call	makeB					# | makeB(edi=10000000) <=> makeB(MAX_N)
	
	lea	rax, -48[rbp]				# | rax := rbp[-48] = &end
	mov	rsi, rax					# | rsi := rax = &end
	mov	edi, 1						# | edi := 1 -- CLOCK_MONOTONIC
	call	clock_gettime@PLT		# | clock_gettime(edi=1, rsi=&end)
	
	mov	rax, QWORD PTR -32[rbp]		# | rax := rbp[-32] = start.tv_sec
	mov	rdx, QWORD PTR -24[rbp]		# | rdx := rbp[-24] = start.tv_nsec
	mov	rdi, QWORD PTR -48[rbp]		# | rdi := rbp[-48] = end.tv_sec
	mov	rsi, QWORD PTR -40[rbp]		# | rsi := rbp[-40] = end.tv_nsec
	mov	rcx, rdx					# | rcx := rdx = start.tv_nsec
	mov	rdx, rax					# | rdx := rax = start.tv_sec
	call	getTimeDiff				# | getTimeDiff(rdi=end.tv_sec, rsi=end.tv_nsec, rdx=start.tv_sec, rcx=start.tv_nsec)
	
	add	QWORD PTR -8[rbp], rax		# | rbp[-8] := rbp[-8] + rax //elapsed += getTimeDiff(end, start);
	add	DWORD PTR -12[rbp], 1		# | ++i
.L65:
	mov	eax, 10						# | eax := 10 = SAMPLE_SIZE
	cmp	DWORD PTR -12[rbp], eax     # | Сравниваем i (rbp[-12]) и SAMPLE_SIZE (eax)
	
	jl	.L66						# | Если i < SAMPLE_SIZE, переходим к следующей итерации цикла
	
	mov	rax, QWORD PTR -8[rbp]		# | rax := rbp[-8] = elapsed -- возвращаемое значение
	
	leave							# | Эпилог
	ret								# \
	
	.section	.rodata
.LC9:
	.string	"r"
.LC10:
	.string	"w"
.LC11:
	.string	"rts:i:o:"
.LC12:
	.string	"Elapsed time: %ld ms\n"
	.align 8
.LC13:
	.string	"Cannot write a result to output stream"
	.text
	.globl	main
	.type	main, @function
main:
	                                # /
	push	rbp                     # |
	mov	rbp, rsp                    # | Пролог
	sub	rsp, 80						# |
	
	mov	DWORD PTR -68[rbp], edi 	# | rbp[-68] := edi = argc
	mov	QWORD PTR -80[rbp], rsi		# | rbp[-80] := rsi = argv
	mov	QWORD PTR -8[rbp], 0		# | rbp[-8] := 0 = input <=> FILE *input = NULL
	mov	QWORD PTR -16[rbp], 0		# | rbp[-16] := 0 = output <=> FILE *output = NULL
	mov	DWORD PTR -20[rbp], 0		# | rbp[-20] := 0 = file_in_flag <=> int file_in_flag = 0
	mov	DWORD PTR -24[rbp], 0		# | rbp[-24] := 0 = file_out_flag <=> int file_out_flag = 0
	mov	DWORD PTR -28[rbp], 0		# | rbp[-28] := 0 = random_flag <=> int random_flag = 0
	mov	DWORD PTR -32[rbp], 0		# | rbp[-32] := 0 = test_flag <=> int test_flag = 0
	mov	DWORD PTR -36[rbp], 42		# | rbp[-36] := 42 = seed <=> int seed = 42
	
	jmp	.L69						# | Прыгаем на метку .L69				
.L77:								
	# Это switch
	# Сравнивается opt (rbp[-48]) и коды символов-опций
	cmp	DWORD PTR -48[rbp], 116
	je	.L70
	cmp	DWORD PTR -48[rbp], 116
	jg	.L69
	cmp	DWORD PTR -48[rbp], 115
	je	.L71
	cmp	DWORD PTR -48[rbp], 115
	jg	.L69
	cmp	DWORD PTR -48[rbp], 114
	je	.L72
	cmp	DWORD PTR -48[rbp], 114
	jg	.L69
	cmp	DWORD PTR -48[rbp], 111
	je	.L73
	cmp	DWORD PTR -48[rbp], 111
	jg	.L69
	cmp	DWORD PTR -48[rbp], 63
	je	.L74
	cmp	DWORD PTR -48[rbp], 105
	je	.L75
	jmp	.L69
.L72: # case 'r'
	mov	DWORD PTR -28[rbp], 1	 	# | random_flag = rpb[-28] := 1
	jmp	.L69
.L75: # case 'i'
	mov	DWORD PTR -20[rbp], 1		# | file_in_flag = rbp[-20] := 1
	mov	rax, QWORD PTR optarg[rip]	# | rax := rip[optarg] -- аргумент опции (optarg -- адрес на начало строки с аргументом опции)
	lea	rsi, .LC9[rip]				# | rsi := &rip[.LC9] -- адрес на строку с mode открытия файла
	mov	rdi, rax					# | rdi := rax = rip[optarg]
	call	fopen@PLT				# | fopen(rdi=rip[optarg], rsi=&rip[.LC9])
	mov	QWORD PTR -8[rbp], rax		# | input = rbp[-8] := rax // через rax fopen вернула указатель на FILE 
	jmp	.L69
.L73: # case 'o'
	mov	DWORD PTR -24[rbp], 1		# | file_out_flag = rbp[-24] := 1
	mov	rax, QWORD PTR optarg[rip]	# | rax := rip[optarg] -- аргумент опции (optarg -- адрес на начало строки с аргументом опции)
	lea	rsi, .LC10[rip]				# | rsi := &rip[.LC10] -- адрес на строку с mode открытия файла				
	mov	rdi, rax					# | rdi := rax = rip[optarg]
	call	fopen@PLT				# | fopen(rdi=rip[optarg], rsi=&rip[.LC10])
	mov	QWORD PTR -16[rbp], rax		# | output = rbp[-16] := rax // через rax fopen вернула указатель на FILE 
	jmp	.L69
.L71: # case 's'
	mov	rax, QWORD PTR optarg[rip] 	# | rax := rip[optarg] -- аргумент опции (optarg -- адрес на начало строки с аргументом опции) 
	mov	rdi, rax					# | rdi := rax = rip[optarg]
	call	atoi@PLT				# | atoi(rdi=rip[optarg])
	mov	DWORD PTR -36[rbp], eax		# | seed = rbp[-36] := eax -- atoi вернула результат (int) через eax
	jmp	.L69
.L70: # case 't'
	mov	DWORD PTR -32[rbp], 1 		# | test_flag = rbp[-32] := 1 
	jmp	.L69	
.L74:
	mov	eax, 0						# | Возвращаем 0 через eax
	jmp	.L87
.L69:
	mov	rcx, QWORD PTR -80[rbp]		# | rcx := rbp[-80] = argv
	mov	eax, DWORD PTR -68[rbp]		# | eax := rbp[-68] = argc
	lea	rdx, .LC11[rip]				# | rdx := &rip[.LC11] -- адрес начала строки с опциями
	mov	rsi, rcx					# | rsi := rcx = argv
	mov	edi, eax					# | edi := eax = argc
	call	getopt@PLT				# | getopt(edi=argc, rsi=argv, rdx=&rip[.LC11])
	
	mov	DWORD PTR -48[rbp], eax		# | rbp[-48] := eax <=> opt = getopt(edi=argc, rsi=argv, rdx=&rip[.LC11]) -- getopt вернула значение через eax	
	
	cmp	DWORD PTR -48[rbp], -1		# | Если opt != -1
	jne	.L77						# | Переходим к switch
	mov	eax, DWORD PTR -36[rbp]		# | Иначе eax := rbp[-36] = seed
	mov	edi, eax					# | edi := eax = seed
	call	srand@PLT				# | srand(edi=seed)
	
	cmp	DWORD PTR -32[rbp], 0		# | test_flag == 0 ?
	je	.L78						# | Переходи на метку .L78
	mov	eax, 0						# | eax := 0, так как measureTime будет возвращать через eax значение
	call	measureTime				# | measureTime()
	mov	QWORD PTR -56[rbp], rax		# | rbp[-56] := rax <=> int64_t elapsed = measureTime() значение вернулось через rax
	
	mov	rax, QWORD PTR -56[rbp] 	# | rax := rbp[-56] = elapsed 
	mov	rsi, rax					# |	rsi := rax = elapsed
	lea	rdi, .LC12[rip]				# | rdi := &rip[.LC12] -- адрес на начало форматной строки
	mov	eax, 0						# | eax := 0
	call	printf@PLT				# | printf(rdi=&rip[.LC12], rsi=elapsed)
	mov	eax, 0						# | Возвращаем 0 через eax // return 0;
	jmp	.L87						# | Переходим к эпилогу
.L78:
	mov	rcx, QWORD PTR -16[rbp]		# | rcx := rbp[-16] = output
	mov	rdx, QWORD PTR -8[rbp]		# | rdx := rbp[-8] = input
	mov	esi, DWORD PTR -24[rbp]		# | esi := rbp[-24] = file_out_flag
	mov	eax, DWORD PTR -20[rbp]		# | eax := rbp[-20] = file_in_flag
	mov	edi, eax					# | edi := eax = file_in_flag
	call	isFilesValid			# | isFilesValid(rdi=file_in_flag, esi=file_out_flag, rdx=input, rcx=output)
	test	eax, eax				# |	Проверяем, что код, который функция вернула
	je	.L79						# | через eax != 0. Если равен, возвращаем через
	mov	eax, 0						# |	eax 0 (return 0) и переходим к эпилогу .L87
	jmp	.L87						# | Иначе прыгаем на .L79
.L79:
	mov	DWORD PTR -40[rbp], 0		# | status_code = rbp[-40] := 0
	cmp	DWORD PTR -20[rbp], 0		# | Сравниваем file_in_flag (rbp[-20]) и 0
	je	.L80						# | Если равны, переходим к проверке другого условия, && не является истинной
	cmp	DWORD PTR -28[rbp], 1		# | Проверяем второе выражение random_flag (rbp[-28]) и 1
	je	.L80						# | Если равны, переходим к проверке другого условия, && не является истинной
	
	lea	rdx, -60[rbp]				# | rdx := &rbp[-60] = &n -- адрес переменной n
	mov	rax, QWORD PTR -8[rbp]		# | rax := rbp[-8] = input
	mov	rsi, rdx					# | rsi := rdx = &n
	mov	rdi, rax					# | rdi := rax = input
	call	handleFileInput			# | handleFileInput(rdi=input, rsi=&n)
	
	mov	DWORD PTR -40[rbp], eax		# | status_code = rbp[-40] := eax -- handleFileInput вернула значение через eax
	jmp	.L81
.L80:
	cmp	DWORD PTR -28[rbp], 1		# | Сравниваем random_flag (rbp[-28]) и 1
	je	.L82						# | Если равны, переходим к else (.L82)
	lea	rax, -60[rbp]				# | rax := &rbp[-60] = &n
	mov	rdi, rax					# | rdi := rax = &n
	call	handleConsoleInput		# | handleConsoleInput(rdi=&n)
	
	mov	DWORD PTR -40[rbp], eax 	# | status_code = rbp[-40] := eax -- handleFileInput вернула значение через eax    
	jmp	.L81
.L82: # else
	mov	edx, DWORD PTR -24[rbp] 	# | edx := rbp[-24] = file_out_flag
	mov	rcx, QWORD PTR -16[rbp]		# | rcx := rbp[-16] = output
	lea	rax, -60[rbp]				# | rax := &rbp[-60] = &n
	mov	rsi, rcx					# | rsi := rcx = output
	mov	rdi, rax					# | rdi := rax = &n
	call	handleRandomInput		# | handleRandomInput(rdi=&n, rsi=output, rdx=file_out_flag)
.L81:
	cmp	DWORD PTR -40[rbp], 0		# | Сравниваем status_code (rbp[-40]) и 0
	je	.L83						# | Если status_code == 0, переходим на метку .L83
	mov	eax, 0						# | Иначе возвращаем 0 через eax и переходим к эпилогу .L87
	jmp	.L87
.L83:
	mov	eax, DWORD PTR -60[rbp]		# | eax := rbp[-60] = n
	mov	edi, eax					# | edi := eax = n
	call	makeB					# | makeB(edi=n)
	
	mov	DWORD PTR -44[rbp], 0		# | out_state = rbp[-44] := 0
	cmp	DWORD PTR -24[rbp], 0		# | Сравниваем file_out_flag (rbp[-24]) и 0
	jne	.L84						# | Если не равны, переходим к else
	mov	eax, DWORD PTR -60[rbp]		# | eax := rbp[-60] = n
	mov	esi, eax					# | esi := eax = n
	lea	rdi, B[rip]					# | rdi := &rip[B] -- адрес на начало массива B
	call	writeArrayToConsole		# | writeArrayToConsole(rdi=&rip[B], rsi=n)
	
	mov	DWORD PTR -44[rbp], eax		# | out_state = rbp[-44] := eax -- функция вернула значение через eax 
	jmp	.L85
.L84:
	mov	edx, DWORD PTR -60[rbp] 	# | edx := rbp[-60] = n
	mov	rax, QWORD PTR -16[rbp]		# | rax := rbp[-16] =  output
	lea	rsi, B[rip]					# | rsi := &rip[B] -- адрес начала массива B
	mov	rdi, rax					# | rdi := rax = output
	call	writeArrayToFile		# | writeArrayToFile(rdi=output, rsi=&rip[B], edx=n)
	
	mov	DWORD PTR -44[rbp], eax 	# | out_state = rbp[-44] := eax -- функция вернула значение через eax 
	
	mov	rax, QWORD PTR -16[rbp]		# | rax := rbp[-16] = output
	mov	rdi, rax					# | rdi := rax = output
	call	fclose@PLT				# | fclose(rdi=output)
.L85:
	cmp	DWORD PTR -44[rbp], 0		# | Сравниваем out_state (rbp[-44]) и 0
	je	.L86						# | Если равны, значит всё прошло без ошибок, переходим на .L86
	lea	rdi, .LC13[rip]				# | rdi := &rip[.LC13] -- адрес начала строки для печати
	mov	eax, 0						# | eax := 0
	call	printf@PLT				# | printf(rdi=&rip[.LC13]) // Печатаем сообщение об ошибке
.L86:
	mov	eax, 0						# | Возвращаем 0 через eax
.L87:
	leave							# | Эпилог
	ret								# \
