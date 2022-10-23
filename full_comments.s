	.file	"program.c"
	.intel_syntax noprefix
	.text
	.local	A
	.comm	A,40000000,32
	.local	B
	.comm	B,40000000,32
	.globl	MAX_N
	.section	.rodata
	.align 4
	.type	MAX_N, @object
	.size	MAX_N, 4
MAX_N:
	.long	10000000
	.globl	SAMPLE_SIZE
	.align 4
	.type	SAMPLE_SIZE, @object
	.size	SAMPLE_SIZE, 4
SAMPLE_SIZE:
	.long	10
	.text
	.globl	getMin
	.type	getMin, @function
getMin:                             # Функция нахождения минимума в массиве
	endbr64                         # / 
	push	rbp                     # |
	mov	rbp, rsp                    # | Пролог
	
    mov	QWORD PTR -24[rbp], rdi     # rbp[-24] := rdi // Положили на стек первый аргумент -- int *array
	mov	DWORD PTR -28[rbp], esi     # rbp[-28] := esi // Положили на стек второй агрумент -- int array_size
	mov	eax, DWORD PTR A[rip]       # eax := rip[A] // <=> int min = A[0]
	mov	DWORD PTR -4[rbp], eax      # rbp[-4] := eax // Кладем на стек min
	mov	DWORD PTR -8[rbp], 1        # rbp[-8] := 1 // Положили на стек значение счётчика i
	
    # На текущий момент состояние следующее
    # rbp[-24] -- int *array, rbp[-28] -- int array_size
    # rbp[-4] -- min, rbp[-8] -- i
    # eax пока тоже хранит значение минимума, но скоро будет использоваться для других целей.
    
    jmp	.L2                         # Переходим на метку, в которой будет проверяться условие цикла

.L5:                                # В метке .L5 проверяется условию внутри оператора if
	cmp	DWORD PTR -4[rbp], 0        # Сравниваем min (rbp[-4]) и 0
	je	.L3                         # min == 0 => условие истинно, переходим в тело условного оператора
	mov	eax, DWORD PTR -8[rbp]      # eax := rbp[-8] // <=> eax := i
	cdqe                            # rax := sign-extend of eax. Копирует знак (31 бит) в старшие 32 бита регистра rax
	lea	rdx, 0[0+rax*4]             # rdx := rax * 4 // Подобным трюком вычисляется адрес (rax*4)[0], который равен rax * 4             
	lea	rax, A[rip]                 # rax := &rip[A] -- адрес начала массива
	mov	eax, DWORD PTR [rdx+rax]    # eax := [rdx + rax] // <=> eax := A[i]
	cmp	DWORD PTR -4[rbp], eax      # Сравниваем min (rbp[-4]) и A[i] (eax)
	jle	.L4                         # Если min <= A[i], условие не выполняется и мы переходим на следуюзую итерацию
	                                # Иначе проверяем, второй операнд &&
    mov	eax, DWORD PTR -8[rbp]      # eax := rbp[-8] // <=> eax := i
	cdqe                            # rax := sign-extend of eax. Копирует знак (31 бит) в старшие 32 бита регистра rax 
	lea	rdx, 0[0+rax*4]             # rdx := rax * 4 // Подобным трюком вычисляется адрес (rax*4)[0], который равен rax * 4
	lea	rax, A[rip]                 #
	mov	eax, DWORD PTR [rdx+rax]    # eax := [rdx + rax] // <=> eax := A[i]
	test	eax, eax                # 
	je	.L4                         #

.L3:                                # Тело условного оператора
	mov	eax, DWORD PTR -8[rbp]      # eax := rbp[-8] // <=> eax := i
	cdqe                            # rax := sign-extend of eax. Копирует знак (31 бит) в старшие 32 бита регистра rax
	lea	rdx, 0[0+rax*4]             # rdx := rax * 4 // Подобным трюком вычисляется адрес (rax*4)[0], который равен rax * 4 
	lea	rax, A[rip]                 # rax := &rip[A] -- адрес на начало массива
	mov	eax, DWORD PTR [rdx+rax]    # eax := [rdx + rax] // <=> eax := A[i]
	mov	DWORD PTR -4[rbp], eax      # rbp[-4] := eax // <=> min := A[i] 

.L4:
	add	DWORD PTR -8[rbp], 1        # rbp[-8] += 1 // <=> ++i

.L2:
	mov	eax, DWORD PTR -8[rbp]      # eax := rbp[-8] // <=> eax := i
	cmp	eax, DWORD PTR -28[rbp]     # Сравниваем значение счётчика (eax) и array_size (rbp[-28])
	
    jl	.L5                         # Если i < array_size, переходим в тело цикла.
                                    # Иначе возвращаем значение через eax и выходим из функции
                                                                    
	mov	eax, DWORD PTR -4[rbp]      # eax := rbp[-4] // <=> eax := min
    
    pop	rbp                         # | Эпилог функции           
	ret                             # \
	.size	getMin, .-getMin
	.globl	makeB
	.type	makeB, @function
makeB:
	endbr64                         # / 
	push	rbp                     # | Пролог функции
	mov	rbp, rsp                    # |
	sub	rsp, 24                     # |

	mov	DWORD PTR -20[rbp], edi     # | rbp[-20] := edi -- положили на стек первый аргумент int array_size
	mov	eax, DWORD PTR -20[rbp]     # | eax := rbp[-20] -- в регистр кладем только что полженный на стек array_size
	mov	esi, eax                    # | esi := eax -- в esi теперь array_size
	lea	rdi, A[rip]                 # | rdi := &rip[A] -- адрес на начало массива
	
    call	getMin                  # | Вызов функции getMin. Первый аргумент в rdi = &rip[A], второй в esi (rsi) = array_size
                                    # | Результат возвращается через eax
	
    mov	DWORD PTR -8[rbp], eax      # | rbp[-8] := eax // <=> int min = getMin(A, array_size)
	mov	DWORD PTR -4[rbp], 0        # | rbp[-4] := 0 // <=> int i = 0
	jmp	.L8         
.L11:                               #
	mov	eax, DWORD PTR -4[rbp]      # | eax := rbp[-4] // <=> eax := i
	cdqe                            # | rax := sign-extend of eax. Копирует знак (31 бит) в старшие 32 бита регистра rax
	lea	rdx, 0[0+rax*4]             # | rdx := rax * 4 // Подобным трюком вычисляется адрес (rax*4)[0], который равен rax * 4
	lea	rax, A[rip]                 # | rax := &rip[A] -- адрес начала массива
	mov	eax, DWORD PTR [rdx+rax]    # | eax := [rdx + rax] // <=> eax := A[i]
	test	eax, eax                #
	jne	.L9                         #
	mov	eax, DWORD PTR -4[rbp]      # | eax := rbp[-4] // <=> eax := i
	cdqe                            # | rax := sign-extend of eax. Копирует знак (31 бит) в старшие 32 бита регистра rax
	lea	rcx, 0[0+rax*4]             # | rcx := rax * 4 // Подобным трюком вычисляется адрес (rax*4)[0], который равен rax * 4 
	lea	rdx, B[rip]                 # | rdx := &rip[B] -- адрес начала массива B
	mov	eax, DWORD PTR -8[rbp]      # | eax := rbp[-8] // <=> eax := min
	mov	DWORD PTR [rcx+rdx], eax    # | [rcx + rdx] := eax // <=> B[i] = min
	jmp	.L10                        # | Переходим на метку увеличения счётчика

.L9:                                # | метка .L9 -- else
	mov	eax, DWORD PTR -4[rbp]      # | eax := rbp[-4] // eax := i
	cdqe                            # | rax := sign-extend of eax. Копирует знак (31 бит) в старшие 32 бита регистра rax
	lea	rdx, 0[0+rax*4]             # | rdx := rax * 4 // Подобным трюком вычисляется адрес (rax*4)[0], который равен rax * 4
	lea	rax, A[rip]                 # | rax := &rip[A] -- адрес начала массива A
	mov	eax, DWORD PTR [rdx+rax]    # | eax := [rdx + rax] <=> eax := A[i]
	mov	edx, DWORD PTR -4[rbp]      # | edx := rbp[-4] <=> edx := i
	movsx	rdx, edx                # | rdx := edx // Тот же mov, но уже со знаковым расширением (sign-extend).
                                    # | Предположительно используется потому, что cdqe нельзя использовать из-за того, что rax занят
	lea	rcx, 0[0+rdx*4]             # | rcx := rax * 4 // Подобным трюком вычисляется адрес (rax*4)[0], который равен rax * 4 
	lea	rdx, B[rip]                 # | rdx := &rip[B] -- адрес на начало массива B
	mov	DWORD PTR [rcx+rdx], eax    # | [rcx + rdx] := eax <=> B[i] := A[i]

.L10:                               # | метка увеличения счётчика
	add	DWORD PTR -4[rbp], 1        # | ++rbp[-4] <=> ++i

.L8:                            
	mov	eax, DWORD PTR -4[rbp]      # | eax := rbp[-4] // <=> eax := i
	cmp	eax, DWORD PTR -20[rbp]     # | Сравниваем i (eax) и array_size (rbp[-20])
	jl	.L11                        # | Если i < array_size, переходим к телу цикла
	nop                             # | Выравнивание для оптимизации
	nop                             # | Выравнивание для оптимизации

    leave                           # | Эпилог функции
	ret                             # \
	.size	makeB, .-makeB
	.section	.rodata
.LC0:
	.string	"%d"
	.text
	.globl	readArraySizeFromConsole
	.type	readArraySizeFromConsole, @function
readArraySizeFromConsole:
	endbr64                         # /
	push	rbp                     # |
	mov	rbp, rsp                    # | Пролог
	sub	rsp, 16                     # |

	mov	QWORD PTR -8[rbp], rdi      # | rbp[-8] := rdi <=> rbp[-8] := size -- кладём на стек первый аргумент (указатель на число)
	mov	rax, QWORD PTR -8[rbp]      # | rax := rbp[-8] <=> rax := size -- теперь в rax лежит int *size
	mov	rsi, rax                    # | rsi := rax <=> rax := size // rsi -- второй аргумент для вызова scanf 
	lea	rdi, .LC0[rip]              # | rdi := &rip[.LC0] -- адрес на начало форматной строки // rdi -- первый аргумент
	mov	eax, 0                      # | Обнуляем eax
	call	__isoc99_scanf@PLT      # | Вызываем scanf
	
	mov	rax, QWORD PTR -8[rbp]		# | rax := rbp[-8] <=> rax := size
	mov	eax, DWORD PTR [rax]		# | eax := [eax] <=> eax := *(eax) // size -- указатель, поэтому нужно разыменовать его.
	mov	edx, 10000000				# | edx := 10000000 -- const int MAX_N
	cmp	eax, edx					# | Сравниваем *size (eax) и MAX_N (edx)
	jg	.L13						# | Если *size > MAX_N, переходим к метке .L13 
	mov	rax, QWORD PTR -8[rbp]		# | rax := size
	mov	eax, DWORD PTR [rax]		# | eax := [rax] -- снова разыменовываем указатель
	test	eax, eax				# | test выполняет логическое И между всеми битами двух операндов, но в отличие от AND изменяет только флаговый регистр. 
	jg	.L14						# | 
.L13:
	mov	eax, 1						# | Ввод некорректный => возвращаем 1 через eax
	jmp	.L15						# | Переходим к эпилогу
.L14:
	mov	eax, 0						# | Ввод корректный, возвращаем 0 через eax
.L15:
	leave							# | Эпилог
	ret								# \
	.size	readArraySizeFromConsole, .-readArraySizeFromConsole
	.globl	readArraySizeFromFile
	.type	readArraySizeFromFile, @function
readArraySizeFromFile:
	endbr64                         # /
	push	rbp                     # |
	mov	rbp, rsp                    # | Пролог
	sub	rsp, 16                     # |
	
	mov	QWORD PTR -8[rbp], rdi      # | rbp[-8] := rdi <=> rbp[-8] := fin -- сохраняем на стек указатель на файл (первый аргумент).
	mov	QWORD PTR -16[rbp], rsi     # | rbp[-16] := rsi <=> rbp[-16] := size -- сохраняем на стек указатель на число (второй аргумент).
	cmp	QWORD PTR -8[rbp], 0		# | Сравниваем fin (rbp[-8]) и NULL (0)
	jne	.L17						# | Если не равны, прыгаем на метку .L17
	mov	eax, 1						# | Иначе возвращаем через eax 1, которая сообщает о невозможности чтения файла
	jmp	.L18						# | И переходим к эпилогу на метку .L18
.L17:
	mov	rdx, QWORD PTR -16[rbp]     # | rdx := rbp[-16] <=> rdx := size (третий аргумент для вызова fscanf)
	mov	rax, QWORD PTR -8[rbp]      # | rax := rbp[-8] <=> rax := fin
	lea	rsi, .LC0[rip]              # | rsi := &rip[.LC0] -- адрес начала форматной строки (второй аргумент для вызова fscanf)
	mov	rdi, rax                    # | rdi := rax -- указатель на файл (первый аргумент для вызова fscanf) 
	mov	eax, 0                      # | Обнуляем eax
	call	__isoc99_fscanf@PLT     # | Вызываем fscanf
	
	mov	rax, QWORD PTR -16[rbp]     # | rax := rbp[-16] <=> rax := size
	
	mov	eax, DWORD PTR [rax]		# | eax := [eax] <=> eax := *(eax) // size -- указатель, поэтому нужно разыменовать его.
	mov	edx, 10000000				# | edx := 10000000 -- const int MAX_N
	cmp	eax, edx					# | Сравниваем *size (eax) и MAX_N (edx)
	jg	.L19						# | Если *size > MAX_N, переходим к метке .L19	
	mov	rax, QWORD PTR -16[rbp]		# | rax := size
	mov	eax, DWORD PTR [rax]		# | eax := [rax] -- снова разыменовываем указатель
	test	eax, eax				# | test выполняет логическое И между всеми битами двух операндов, но в отличие от AND изменяет только флаговый регистр.
	jg	.L20						# |
.L19:
	mov	eax, 1						# | Иначе возвращаем 1 через eax
	jmp	.L18						# | И переходим на метку с эпилогом
.L20:
	mov	eax, 0                      # | Возвращаем 0 через eax 
.L18:
	leave                           # | Эпилог функции
	ret                             # \ 
	.size	readArraySizeFromFile, .-readArraySizeFromFile
	.globl	readArrayFromConsole
	.type	readArrayFromConsole, @function
readArrayFromConsole:
	endbr64                         # /
	push	rbp                     # |
	mov	rbp, rsp                    # | Пролог функции
	sub	rsp, 32                     # |
	
	mov	QWORD PTR -24[rbp], rdi     # | rbp[-24] := rdi <=> rbp[-24] = array -- загружаем на стек первый аргумент (указатель на начало массива)
	mov	DWORD PTR -28[rbp], esi     # | rbp[-28] := esi <=> rbp[-28] = size -- загружаем на стек второй переданный аргумент (размер масива)
	mov	DWORD PTR -4[rbp], 0        # | rbp[-4] := 0 <=> int i = 0 // Заводим счётчик
	jmp	.L22						# | Переходим на метку, в которой проверяется условие цикла
.L23:
	mov	eax, DWORD PTR -4[rbp]      # | eax := i // rbp[-4] = i
	cdqe                            # | rax := sign-extend of eax. Копирует знак (31 бит) в старшие 32 бита регистра rax
	lea	rdx, 0[0+rax*4]             # | rdx := rax * 4 // Подобным трюком вычисляется адрес (rax*4)[0], который равен rax * 4 
	mov	rax, QWORD PTR -24[rbp]     # | rax := array
	add	rax, rdx                    # | rax += rdx // теперь в rax адрес i-ой ячейки массива
	mov	rsi, rax                    # | rsi := rax
	lea	rdi, .LC0[rip]              # | rdi := &rip[.LC0]
	mov	eax, 0                      # | eax := 0
	call	__isoc99_scanf@PLT      # | Вызываем scanf(rdi=&rip[.LC0], rsi=&array[i])
	add	DWORD PTR -4[rbp], 1        # | ++i // rbp[-4] = i
.L22:
	mov	eax, DWORD PTR -4[rbp]      # | eax := rbp[-4] <=> eax := i
	cmp	eax, DWORD PTR -28[rbp]     # | Сравниваем i (eax) и size (rbp[-28])
	jl	.L23						# | Если i < size, переходим к следующей итерации цикла
	mov	eax, 0                      # | Возвращаем 0 через eax <=> return 0
	
	leave                           # | Эпилог функции
	ret                             # \
	.size	readArrayFromConsole, .-readArrayFromConsole
	.globl	readArrayFromFile
	.type	readArrayFromFile, @function
readArrayFromFile:
	endbr64                         # /
	push	rbp                     # |
	mov	rbp, rsp                    # | Пролог
	sub	rsp, 48                     # |
	
	mov	QWORD PTR -24[rbp], rdi     # | rbp[-24] := rdi <=> rbp[-24] := fin -- загружаем на стек первый аргумент (указатель на FILE)
	mov	QWORD PTR -32[rbp], rsi     # | rbp[-32] := rsi <=> rbp[-32] := array -- загружаем на стек второй аргумент (указатель на начало массива)
	mov	DWORD PTR -36[rbp], edx     # | rbp[-36] := edx <=> rbp[-36] := size -- загружаем на стек третий аргумент (размер массива)
	cmp	QWORD PTR -24[rbp], 0       # | Сравниваем fin (rbp[-24]) и NULL (0)
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
	mov	rax, QWORD PTR -32[rbp]     # | rax := array 
	add	rdx, rax                    # | rdx := rax + rdx // rdx = &array[i]
	mov	rax, QWORD PTR -24[rbp]     # | rax := fin
	lea	rsi, .LC0[rip]              # | rsi := &rip[.LC0] -- второй аргумент для вызова fscanf (адрес начала форматной строки)
	mov	rdi, rax                    # | rdi := rax <=> rdi := fin -- первым аргументом передаем указатель на FILE
	mov	eax, 0                      # | eax := 0
	call	__isoc99_fscanf@PLT     # | Вызываем fscanf
	add	DWORD PTR -4[rbp], 1		# | ++i
.L28:
	mov	eax, DWORD PTR -4[rbp]      # | eax := i // rbp[-4] = i
	cmp	eax, DWORD PTR -36[rbp]     # | Сравниваем i (eax) и size (rbp[-36])
	jl	.L29						# | Если i < size, прыгаем на метку .L29 -- тело цикла
	mov	eax, 0						# | Иначе возвращаем 0 -- знак, что всё прошло без ошибок
.L27:
	leave                           # | Эпилог функции
	ret                             # \
	.size	readArrayFromFile, .-readArrayFromFile
	.section	.rodata
.LC1:
	.string	"%d "
	.text
	.globl	writeArrayToConsole
	.type	writeArrayToConsole, @function
writeArrayToConsole:
	endbr64                         # /
	push	rbp                     # |
	mov	rbp, rsp                    # | Пролог
	sub	rsp, 32                     # |
	
	mov	QWORD PTR -24[rbp], rdi     # | rbp[-24] := rdi // Загружаем на стек первый аргумент -- указатель на начало массива int *array
	mov	DWORD PTR -28[rbp], esi     # | rbp[-28] := esi // Загружаем на стек второй аргумент -- размер массива int size
	mov	DWORD PTR -4[rbp], 0        # | rbp[-4] := 0 <=> int i = 0 // Запомним, что rbp[-4] = i
	jmp	.L31						# | Переходим на метку .L31, в которой проверится условие выхода из цикла
.L32:
	mov	eax, DWORD PTR -4[rbp]      # | eax := i
	cdqe                            # | rax := sign-extend of eax. Копирует знак (31 бит) в старшие 32 бита регистра rax
	lea	rdx, 0[0+rax*4]             # | rdx := rax * 4 // Подобным трюком вычисляется адрес (rax*4)[0], который равен rax * 4
	mov	rax, QWORD PTR -24[rbp]     # | rax := array -- указатель на начало массива
	add	rax, rdx                    # | rax := rax + rdx -- вычисляем адрес i-ого элемента массива
	mov	eax, DWORD PTR [rax]        # | eax := *(rax) <=> eax := array[i]
	mov	esi, eax                    # | esi := eax -- второй аргумент (array[i]) для вызова printf   
	lea	rdi, .LC1[rip]              # | rdi := &rip[.LC1] -- первый аргумент (адрес начала форматной строки) для вызова printf
	mov	eax, 0                      # | eax := 0
	call	printf@PLT              # | Вызываем printf(rdi=&rip[.LC1], rsi=array[i])
	add	DWORD PTR -4[rbp], 1        # | ++i
.L31:
	mov	eax, DWORD PTR -4[rbp]      # | eax := i
	cmp	eax, DWORD PTR -28[rbp]     # | Сравниваем i (eax) и size (rbp[-28])
	jl	.L32						# | Если i < size, переходим к следующей итерации цикла
	mov	edi, 10                     # | Иначе edi := 10 -- первый аргумент для вызова putchar (записывает единственный char в поток вывода)
	call	putchar@PLT             # | Вызываем putchar(edi=10) // 10 = '\n'
	mov	eax, 0                      # | eax := 0
	
    leave                           # | Эпилог
	ret                             # \
	.size	writeArrayToConsole, .-writeArrayToConsole
	.globl	writeArrayToFile
	.type	writeArrayToFile, @function
writeArrayToFile:
	endbr64                         # /
	push	rbp                     # |
	mov	rbp, rsp                    # | Пролог
	sub	rsp, 48                     # |
	
	mov	QWORD PTR -24[rbp], rdi     # | rbp[-24] := rdi -- первый переданный аргумент (FILE *fout) загружаем на стек 
	mov	QWORD PTR -32[rbp], rsi     # | rbp[-32] := rsi -- загружаем на стек второй переданный аргумент (int *array -- указатель на начало массива)
	mov	DWORD PTR -36[rbp], edx     # | rbp[-36] := edx -- загружаем на стек третий переданный аргумент (int size -- размер массива)
	cmp	QWORD PTR -24[rbp], 0       # | Сравниваем fout (rbp[-24]) и NULL (0)
	jne	.L35						# | Если fout не NULL, переходим к метке .L35
	mov	eax, 1                      # | Иначе возвращаем 1 через eax
	jmp	.L36						# | И прыгаем на эпилог
.L35:
	mov	DWORD PTR -4[rbp], 0        # | rbp[-4] = 0 <=> int i = 0		
	jmp	.L37						# | Переходим на метку .L37
.L38:
	mov	eax, DWORD PTR -4[rbp]      # | eax := i
	cdqe                            # | rax := sign-extend of eax. Копирует знак (31 бит) в старшие 32 бита регистра rax
	lea	rdx, 0[0+rax*4]             # | rdx := rax * 4 // Подобным трюком вычисляется адрес (rax*4)[0], который равен rax * 4
	mov	rax, QWORD PTR -32[rbp]     # | rax := array
	add	rax, rdx                    # | rax := rax + rdx // rax := &array[i]
	mov	edx, DWORD PTR [rax]        # | edx := [rax] <=> edx := *(rax + rdx) = array[i] -- третий аргумент для вызова fprintf
	mov	rax, QWORD PTR -24[rbp]     # | rax := fout
	lea	rsi, .LC1[rip]              # | rsi := &rip[.LC1] -- второй аргумент для вызова fprintf (форматная строка)
	mov	rdi, rax                    # | rdi := rax = fout -- первый аргумент для вызова fprintf 
	mov	eax, 0                      # | eax := 0
	call	fprintf@PLT             # | Вызываем fprintf(rdi=fout, rsi=&rip[.LC1], rdx=array[i])
	add	DWORD PTR -4[rbp], 1        # | ++i
.L37:
	mov	eax, DWORD PTR -4[rbp]      # | eax := i
	cmp	eax, DWORD PTR -36[rbp]     # | Сравниваем eax (i) и size (rbp[-36])
	jl	.L38						# | Если i < size, переходим к следующей итерации цикла
	mov	rax, QWORD PTR -24[rbp]     # | Иначе rax := fout
	mov	rsi, rax                    # | rsi := rax -- второй аргумент (fout) для вызова fputc
	mov	edi, 10                     # | edi := 10 -- первый аргумент (10 = '\n') для вызова fputc
	call	fputc@PLT               # | Вызываем fputc(rdi='\n', rsi=fout)
	mov	eax, 0                      # | Возвращаем 0 через eax
.L36:
	leave                           # | Эпилог
	ret                             # \
	.size	writeArrayToFile, .-writeArrayToFile
	.globl	getRandomArraySize
	.type	getRandomArraySize, @function
getRandomArraySize:
	endbr64                         # /
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
	.size	getRandomArraySize, .-getRandomArraySize
	.globl	fillArrayWithRandom
	.type	fillArrayWithRandom, @function
fillArrayWithRandom:
	endbr64                         # /
	push	rbp                     # |
	mov	rbp, rsp                    # | Пролог
	push	rbx						# | Зачем-то на стек сохраняется rbx, который потом нигде всё равно не используются. Загадка...
	sub	rsp, 40						# |
	
	mov	QWORD PTR -40[rbp], rdi		# |
	mov	DWORD PTR -44[rbp], esi		# |
	mov	DWORD PTR -20[rbp], 0		# |
	jmp	.L42
.L45:
	mov	eax, DWORD PTR -20[rbp]
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
	mov	eax, DWORD PTR -20[rbp]
	cdqe
	lea	rdx, 0[0+rax*4]
	mov	rax, QWORD PTR -40[rbp]
	add	rax, rdx
	mov	DWORD PTR [rax], 0
	jmp	.L44
.L43:
	call	rand@PLT
	movsx	rdx, eax
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
	mov	eax, DWORD PTR -20[rbp]
	cdqe
	lea	rcx, 0[0+rax*4]
	mov	rax, QWORD PTR -40[rbp]
	add	rax, rcx
	sub	ebx, edx
	mov	edx, ebx
	mov	DWORD PTR [rax], edx
.L44:
	add	DWORD PTR -20[rbp], 1
.L42:
	mov	eax, DWORD PTR -20[rbp]
	cmp	eax, DWORD PTR -44[rbp]
	jl	.L45
	nop
	nop
	add	rsp, 40
	pop	rbx
	pop	rbp
	ret
	.size	fillArrayWithRandom, .-fillArrayWithRandom
	.section	.rodata
.LC2:
	.string	"Incorrect input file"
.LC3:
	.string	"Incorrect output file"
	.text
	.globl	isFilesValid
	.type	isFilesValid, @function
isFilesValid:
	endbr64
	push	rbp
	mov	rbp, rsp
	sub	rsp, 32
	mov	DWORD PTR -4[rbp], edi
	mov	DWORD PTR -8[rbp], esi
	mov	QWORD PTR -16[rbp], rdx
	mov	QWORD PTR -24[rbp], rcx
	cmp	DWORD PTR -4[rbp], 1
	jne	.L47
	cmp	QWORD PTR -16[rbp], 0
	jne	.L47
	lea	rdi, .LC2[rip]
	mov	eax, 0
	call	printf@PLT
	mov	eax, 1
	jmp	.L48
.L47:
	cmp	DWORD PTR -8[rbp], 1
	jne	.L49
	cmp	QWORD PTR -24[rbp], 0
	jne	.L49
	lea	rdi, .LC3[rip]
	mov	eax, 0
	call	printf@PLT
	mov	eax, 1
	jmp	.L48
.L49:
	mov	eax, 0
.L48:
	leave
	ret
	.size	isFilesValid, .-isFilesValid
	.section	.rodata
.LC4:
	.string	"Incorrect size of array"
.LC5:
	.string	"Incorrect element in array"
	.text
	.globl	validateInput
	.type	validateInput, @function
validateInput:
	endbr64
	push	rbp
	mov	rbp, rsp
	sub	rsp, 16
	mov	DWORD PTR -4[rbp], edi
	mov	DWORD PTR -8[rbp], esi
	cmp	DWORD PTR -4[rbp], 1
	jne	.L51
	lea	rdi, .LC4[rip]
	mov	eax, 0
	call	printf@PLT
	mov	eax, 1
	jmp	.L52
.L51:
	cmp	DWORD PTR -8[rbp], 1
	jne	.L53
	lea	rdi, .LC5[rip]
	mov	eax, 0
	call	printf@PLT
	mov	eax, 1
	jmp	.L52
.L53:
	mov	eax, 0
.L52:
	leave
	ret
	.size	validateInput, .-validateInput
	.globl	handleFileInput
	.type	handleFileInput, @function
handleFileInput:
	endbr64
	push	rbp
	mov	rbp, rsp
	sub	rsp, 32
	mov	QWORD PTR -24[rbp], rdi
	mov	QWORD PTR -32[rbp], rsi
	mov	rdx, QWORD PTR -32[rbp]
	mov	rax, QWORD PTR -24[rbp]
	mov	rsi, rdx
	mov	rdi, rax
	call	readArraySizeFromFile
	mov	DWORD PTR -4[rbp], eax
	mov	rax, QWORD PTR -32[rbp]
	mov	edx, DWORD PTR [rax]
	mov	rax, QWORD PTR -24[rbp]
	lea	rsi, A[rip]
	mov	rdi, rax
	call	readArrayFromFile
	mov	DWORD PTR -8[rbp], eax
	mov	rax, QWORD PTR -24[rbp]
	mov	rdi, rax
	call	fclose@PLT
	mov	edx, DWORD PTR -8[rbp]
	mov	eax, DWORD PTR -4[rbp]
	mov	esi, edx
	mov	edi, eax
	call	validateInput
	leave
	ret
	.size	handleFileInput, .-handleFileInput
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
	endbr64
	push	rbp
	mov	rbp, rsp
	sub	rsp, 32
	mov	QWORD PTR -24[rbp], rdi
	lea	rdi, .LC6[rip]
	mov	eax, 0
	call	printf@PLT
	mov	rax, QWORD PTR -24[rbp]
	mov	rdi, rax
	call	readArraySizeFromConsole
	mov	DWORD PTR -4[rbp], eax
	lea	rdi, .LC7[rip]
	call	puts@PLT
	mov	rax, QWORD PTR -24[rbp]
	mov	eax, DWORD PTR [rax]
	mov	esi, eax
	lea	rdi, A[rip]
	call	readArrayFromConsole
	mov	DWORD PTR -8[rbp], eax
	mov	edx, DWORD PTR -8[rbp]
	mov	eax, DWORD PTR -4[rbp]
	mov	esi, edx
	mov	edi, eax
	call	validateInput
	leave
	ret
	.size	handleConsoleInput, .-handleConsoleInput
	.section	.rodata
.LC8:
	.string	"Random array with size %d:\n"
	.text
	.globl	handleRandomInput
	.type	handleRandomInput, @function
handleRandomInput:
	endbr64
	push	rbp
	mov	rbp, rsp
	sub	rsp, 32
	mov	QWORD PTR -8[rbp], rdi
	mov	QWORD PTR -16[rbp], rsi
	mov	DWORD PTR -20[rbp], edx
	mov	eax, 0
	call	getRandomArraySize
	mov	rdx, QWORD PTR -8[rbp]
	mov	DWORD PTR [rdx], eax
	mov	rax, QWORD PTR -8[rbp]
	mov	eax, DWORD PTR [rax]
	mov	esi, eax
	lea	rdi, A[rip]
	call	fillArrayWithRandom
	cmp	DWORD PTR -20[rbp], 0
	jne	.L59
	mov	rax, QWORD PTR -8[rbp]
	mov	eax, DWORD PTR [rax]
	mov	esi, eax
	lea	rdi, .LC8[rip]
	mov	eax, 0
	call	printf@PLT
	mov	rax, QWORD PTR -8[rbp]
	mov	eax, DWORD PTR [rax]
	mov	esi, eax
	lea	rdi, A[rip]
	call	writeArrayToConsole
	jmp	.L60
.L59:
	mov	rax, QWORD PTR -8[rbp]
	mov	edx, DWORD PTR [rax]
	mov	rax, QWORD PTR -16[rbp]
	lea	rsi, B[rip]
	mov	rdi, rax
	call	writeArrayToFile
.L60:
	mov	eax, 0
	leave
	ret
	.size	handleRandomInput, .-handleRandomInput
	.globl	getTimeDiff
	.type	getTimeDiff, @function
getTimeDiff:
	endbr64
	push	rbp
	mov	rbp, rsp
	mov	rax, rsi
	mov	r8, rdi
	mov	rsi, r8
	mov	rdi, r9
	mov	rdi, rax
	mov	QWORD PTR -32[rbp], rsi
	mov	QWORD PTR -24[rbp], rdi
	mov	QWORD PTR -48[rbp], rdx
	mov	QWORD PTR -40[rbp], rcx
	mov	rax, QWORD PTR -32[rbp]
	imul	rsi, rax, 1000
	mov	rcx, QWORD PTR -24[rbp]
	movabs	rdx, 4835703278458516699
	mov	rax, rcx
	imul	rdx
	sar	rdx, 18
	mov	rax, rcx
	sar	rax, 63
	sub	rdx, rax
	mov	rax, rdx
	add	rax, rsi
	mov	QWORD PTR -8[rbp], rax
	mov	rax, QWORD PTR -48[rbp]
	imul	rsi, rax, 1000
	mov	rcx, QWORD PTR -40[rbp]
	movabs	rdx, 4835703278458516699
	mov	rax, rcx
	imul	rdx
	sar	rdx, 18
	mov	rax, rcx
	sar	rax, 63
	sub	rdx, rax
	mov	rax, rdx
	add	rax, rsi
	mov	QWORD PTR -16[rbp], rax
	mov	rax, QWORD PTR -8[rbp]
	sub	rax, QWORD PTR -16[rbp]
	pop	rbp
	ret
	.size	getTimeDiff, .-getTimeDiff
	.globl	measureTime
	.type	measureTime, @function
measureTime:
	endbr64
	push	rbp
	mov	rbp, rsp
	sub	rsp, 48
	lea	rax, -32[rbp]
	mov	rsi, rax
	mov	edi, 1
	call	clock_gettime@PLT
	mov	DWORD PTR -4[rbp], 0
	jmp	.L65
.L66:
	mov	eax, 10000000
	mov	esi, eax
	lea	rdi, A[rip]
	call	fillArrayWithRandom
	mov	eax, 10000000
	mov	edi, eax
	call	makeB
	add	DWORD PTR -4[rbp], 1
.L65:
	mov	eax, 10
	cmp	DWORD PTR -4[rbp], eax
	jl	.L66
	lea	rax, -48[rbp]
	mov	rsi, rax
	mov	edi, 1
	call	clock_gettime@PLT
	mov	rax, QWORD PTR -32[rbp]
	mov	rdx, QWORD PTR -24[rbp]
	mov	rdi, QWORD PTR -48[rbp]
	mov	rsi, QWORD PTR -40[rbp]
	mov	rcx, rdx
	mov	rdx, rax
	call	getTimeDiff
	leave
	ret
	.size	measureTime, .-measureTime
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
	endbr64
	push	rbp
	mov	rbp, rsp
	sub	rsp, 80
	mov	DWORD PTR -68[rbp], edi
	mov	QWORD PTR -80[rbp], rsi
	mov	QWORD PTR -8[rbp], 0
	mov	QWORD PTR -16[rbp], 0
	mov	DWORD PTR -20[rbp], 0
	mov	DWORD PTR -24[rbp], 0
	mov	DWORD PTR -28[rbp], 0
	mov	DWORD PTR -32[rbp], 0
	mov	DWORD PTR -36[rbp], 42
	jmp	.L69
.L77:
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
.L72:
	mov	DWORD PTR -28[rbp], 1
	jmp	.L69
.L75:
	mov	DWORD PTR -20[rbp], 1
	mov	rax, QWORD PTR optarg[rip]
	lea	rsi, .LC9[rip]
	mov	rdi, rax
	call	fopen@PLT
	mov	QWORD PTR -8[rbp], rax
	jmp	.L69
.L73:
	mov	DWORD PTR -24[rbp], 1
	mov	rax, QWORD PTR optarg[rip]
	lea	rsi, .LC10[rip]
	mov	rdi, rax
	call	fopen@PLT
	mov	QWORD PTR -16[rbp], rax
	jmp	.L69
.L71:
	mov	rax, QWORD PTR optarg[rip]
	mov	rdi, rax
	call	atoi@PLT
	mov	DWORD PTR -36[rbp], eax
	jmp	.L69
.L70:
	mov	DWORD PTR -32[rbp], 1
	jmp	.L69
.L74:
	mov	eax, 0
	jmp	.L87
.L69:
	mov	rcx, QWORD PTR -80[rbp]
	mov	eax, DWORD PTR -68[rbp]
	lea	rdx, .LC11[rip]
	mov	rsi, rcx
	mov	edi, eax
	call	getopt@PLT
	mov	DWORD PTR -48[rbp], eax
	cmp	DWORD PTR -48[rbp], -1
	jne	.L77
	mov	eax, DWORD PTR -36[rbp]
	mov	edi, eax
	call	srand@PLT
	cmp	DWORD PTR -32[rbp], 0
	je	.L78
	mov	eax, 0
	call	measureTime
	mov	QWORD PTR -56[rbp], rax
	mov	rax, QWORD PTR -56[rbp]
	mov	rsi, rax
	lea	rdi, .LC12[rip]
	mov	eax, 0
	call	printf@PLT
	mov	eax, 0
	jmp	.L87
.L78:
	mov	rcx, QWORD PTR -16[rbp]
	mov	rdx, QWORD PTR -8[rbp]
	mov	esi, DWORD PTR -24[rbp]
	mov	eax, DWORD PTR -20[rbp]
	mov	edi, eax
	call	isFilesValid
	test	eax, eax
	je	.L79
	mov	eax, 0
	jmp	.L87
.L79:
	mov	DWORD PTR -40[rbp], 0
	cmp	DWORD PTR -20[rbp], 0
	je	.L80
	cmp	DWORD PTR -28[rbp], 1
	je	.L80
	lea	rdx, -60[rbp]
	mov	rax, QWORD PTR -8[rbp]
	mov	rsi, rdx
	mov	rdi, rax
	call	handleFileInput
	mov	DWORD PTR -40[rbp], eax
	jmp	.L81
.L80:
	cmp	DWORD PTR -28[rbp], 1
	je	.L82
	lea	rax, -60[rbp]
	mov	rdi, rax
	call	handleConsoleInput
	mov	DWORD PTR -40[rbp], eax
	jmp	.L81
.L82:
	mov	edx, DWORD PTR -24[rbp]
	mov	rcx, QWORD PTR -16[rbp]
	lea	rax, -60[rbp]
	mov	rsi, rcx
	mov	rdi, rax
	call	handleRandomInput
.L81:
	cmp	DWORD PTR -40[rbp], 0
	je	.L83
	mov	eax, 0
	jmp	.L87
.L83:
	mov	eax, DWORD PTR -60[rbp]
	mov	edi, eax
	call	makeB
	mov	DWORD PTR -44[rbp], 0
	cmp	DWORD PTR -24[rbp], 0
	jne	.L84
	mov	eax, DWORD PTR -60[rbp]
	mov	esi, eax
	lea	rdi, B[rip]
	call	writeArrayToConsole
	mov	DWORD PTR -44[rbp], eax
	jmp	.L85
.L84:
	mov	edx, DWORD PTR -60[rbp]
	mov	rax, QWORD PTR -16[rbp]
	lea	rsi, B[rip]
	mov	rdi, rax
	call	writeArrayToFile
	mov	DWORD PTR -44[rbp], eax
	mov	rax, QWORD PTR -16[rbp]
	mov	rdi, rax
	call	fclose@PLT
.L85:
	cmp	DWORD PTR -44[rbp], 0
	je	.L86
	lea	rdi, .LC13[rip]
	mov	eax, 0
	call	printf@PLT
.L86:
	mov	eax, 0
.L87:
	leave
	ret
	.size	main, .-main
	.ident	"GCC: (Ubuntu 9.4.0-1ubuntu1~20.04.1) 9.4.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	 1f - 0f
	.long	 4f - 1f
	.long	 5
0:
	.string	 "GNU"
1:
	.align 8
	.long	 0xc0000002
	.long	 3f - 2f
2:
	.long	 0x3
3:
	.align 8
4:
