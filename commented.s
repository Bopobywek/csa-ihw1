	.file	"program.c"
	.intel_syntax noprefix
	.text
	.local	A
	.comm	A,4000000,32
	.local	B
	.comm	B,4000000,32
	.data
	.align 4
	.type	MAX_N, @object
	.size	MAX_N, 4
MAX_N:
	.long	1000000
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
	lea	rdx, 0[0+rax*4]             # 
	lea	rax, A[rip]                 # rax := &rip[A] -- адрес начала массива
	mov	eax, DWORD PTR [rdx+rax]    # eax := [rdx + rax] // <=> eax := A[i]
	cmp	DWORD PTR -4[rbp], eax      # Сравниваем min (rbp[-4]) и A[i] (eax)
	jle	.L4                         # Если min <= A[i], условие не выполняется и мы переходим на следуюзую итерацию
	                                # Иначе проверяем, второй операнд &&
    mov	eax, DWORD PTR -8[rbp]      # eax := rbp[-8] // <=> eax := i
	cdqe                            # rax := sign-extend of eax. Копирует знак (31 бит) в старшие 32 бита регистра rax 
	lea	rdx, 0[0+rax*4]             # 
	lea	rax, A[rip]                 #
	mov	eax, DWORD PTR [rdx+rax]    # eax := [rdx + rax] // <=> eax := A[i]
	test	eax, eax                # 
	je	.L4                         #

.L3:                                # Тело условного оператора
	mov	eax, DWORD PTR -8[rbp]      # eax := rbp[-8] // <=> eax := i
	cdqe                            # rax := sign-extend of eax. Копирует знак (31 бит) в старшие 32 бита регистра rax
	lea	rdx, 0[0+rax*4]             # 
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
	lea	rdx, 0[0+rax*4]             #
	lea	rax, A[rip]                 # | rax := &rip[A] -- адрес начала массива
	mov	eax, DWORD PTR [rdx+rax]    # | eax := [rdx + rax] // <=> eax := A[i]
	test	eax, eax                #
	jne	.L9                         #
	mov	eax, DWORD PTR -4[rbp]      # | eax := rbp[-4] // <=> eax := i
	cdqe                            # | rax := sign-extend of eax. Копирует знак (31 бит) в старшие 32 бита регистра rax
	lea	rcx, 0[0+rax*4]             # 
	lea	rdx, B[rip]                 # | rdx := &rip[B] -- адрес начала массива B
	mov	eax, DWORD PTR -8[rbp]      # | eax := rbp[-8] // <=> eax := min
	mov	DWORD PTR [rcx+rdx], eax    # | [rcx + rdx] := eax // <=> B[i] = min
	jmp	.L10                        # | Переходим на метку увеличения счётчика

.L9:                                # | метка .L9 -- else
	mov	eax, DWORD PTR -4[rbp]      # | eax := rbp[-4] // eax := i
	cdqe                            # | rax := sign-extend of eax. Копирует знак (31 бит) в старшие 32 бита регистра rax
	lea	rdx, 0[0+rax*4]             #
	lea	rax, A[rip]                 # | rax := &rip[A] -- адрес начала массива A
	mov	eax, DWORD PTR [rdx+rax]    # | eax := [rdx + rax] <=> eax := A[i]
	mov	edx, DWORD PTR -4[rbp]      # | edx := rbp[-4] <=> edx := i
	movsx	rdx, edx                # | rdx := edx // Тот же mov, но уже со знаковым расширением (sign-extend).
                                    # | Предположительно используется потому, что cdqe нельзя использовать из-за того, что он занят
	lea	rcx, 0[0+rdx*4]             # 
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

	mov	rax, QWORD PTR -8[rbp]      # | rax := rbp[-8] <=> rax := size
	mov	edx, DWORD PTR [rax]        # | edx := [eax] <=> edx := *(eax) // size -- указатель, поэтому нужно разыменовать его.
	mov	eax, DWORD PTR MAX_N[rip]   # | eax := rip[MAX_N] // копируем число из статики -- максимально допустимый размер массива.
	cmp	edx, eax                    # | Сравниваем *size (edx) и MAX_N (eax)
	jle	.L13                        # | Если *size <= MAX_N, условие не выполнилось, переходим к другой метке.
	mov	eax, 1                      # | Иначе return 1
	jmp	.L14                        # | Переходим к метке с эпилогом
.L13:                               
	mov	eax, 0                      # | return 0
.L14:
	leave                           # | Эпилог
	ret                             # \
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
	mov	rdx, QWORD PTR -16[rbp]     # | rdx := rbp[-16] <=> rdx := size (третий аргумент для вызова fscanf)
	mov	rax, QWORD PTR -8[rbp]      # | rax := rbp[-8] <=> rax := fin
	lea	rsi, .LC0[rip]              # | rsi := &rip[.LC0] -- адрес начала форматной строки (второй аргумент для вызова fscanf)
	mov	rdi, rax                    # | rdi := rax -- указатель на файл (первый аргумент для вызова fscanf) 
	mov	eax, 0                      # | Обнуляем eax
	call	__isoc99_fscanf@PLT     # | Вызываем fscanf

	mov	rax, QWORD PTR -16[rbp]     # | rax := rbp[-16] <=> rax := size
	mov	edx, DWORD PTR [rax]        # | edx := [edx] <=> edx := *size -- разыменовываем указатель
	mov	eax, DWORD PTR MAX_N[rip]   # | eax := rip[MAX_N] <=> eax := MAX_N
	cmp	edx, eax                    # | Сравниваем *size (edx) и MAX_N (eax)
	jle	.L16                        # | Если *size <= MAX_N
	mov	eax, 1                      # | return 1
	jmp	.L17                        # | Переходим к эпилогу функции

.L16:
	mov	eax, 0                      # | return 0

.L17:
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
	jmp	.L19                        # | Переходим на метку, в которой проверяется условие цикла
.L20:
	mov	eax, DWORD PTR -4[rbp]      # | eax := i // rbp[-4] = i
	cdqe                            # | 
	lea	rdx, 0[0+rax*4]             # |
	mov	rax, QWORD PTR -24[rbp]     # | rax := array
	add	rax, rdx                    # | rax += rdx // теперь в rax адрес i-ой ячейки массива
	mov	rsi, rax                    # | rsi := rax
	lea	rdi, .LC0[rip]              # | rdi := &rip[.LC0]
	mov	eax, 0                      # | eax := 0
	call	__isoc99_scanf@PLT      # | Вызываем scanf(rdi=&rip[.LC0], rsi=&array[i])
	add	DWORD PTR -4[rbp], 1        # | ++i // rbp[-4] = i
.L19:
	mov	eax, DWORD PTR -4[rbp]      # | eax := rbp[-4] <=> eax := i
	cmp	eax, DWORD PTR -28[rbp]     # | Сравниваем i (eax) и size (rbp[-28]) 
	jl	.L20                        # | Если i < size, переходим к следующей итерации цикла
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
	jne	.L23                        # | Если fin не NULL, идем дальше -- на метку .L23
	mov	eax, 1                      # | Иначе кладем в eax 1 для возврата.
	jmp	.L24                        # | И прыгаем на метку .L24 -- эпилог функции
.L23:
	mov	DWORD PTR -4[rbp], 0        # | rbp[-4] := 0 -- заводим счётчик i 
	jmp	.L25                        # | Переходим к метке, в которой проверяется условие цикла
.L26:
	mov	eax, DWORD PTR -4[rbp]      # | eax := i // rbp[-4] = i
	cdqe                            # |
	lea	rdx, 0[0+rax*4]             # |
	mov	rax, QWORD PTR -32[rbp]     # | rax := array 
	add	rdx, rax                    # | rdx := rax + rdx // rdx = &array[i]
	mov	rax, QWORD PTR -24[rbp]     # | rax := fin
	lea	rsi, .LC0[rip]              # | rsi := &rip[.LC0] -- второй аргумент для вызова fscanf (адрес начала форматной строки)
	mov	rdi, rax                    # | rdi := rax <=> rdi := fin -- первым аргументом передаем указатель на FILE
	mov	eax, 0                      # | eax := 0
	call	__isoc99_fscanf@PLT     # | Вызываем fscanf
	add	DWORD PTR -4[rbp], 1
.L25:
	mov	eax, DWORD PTR -4[rbp]      # | eax := i // rbp[-4] = i
	cmp	eax, DWORD PTR -36[rbp]     # | Сравниваем i (eax) и size (rbp[-36])
	jl	.L26                        # | Если i < size, прыгаем на метку .L26 -- тело цикла
	mov	eax, 0                      # | Иначе возвращаем 0 -- знак, что всё прошло без ошибок
.L24:
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
	jmp	.L28                        # | Переходим на метку .L28, в которой проверится условие выхода из цикла
.L29:
	mov	eax, DWORD PTR -4[rbp]      # | eax := i
	cdqe                            # | 
	lea	rdx, 0[0+rax*4]             # |
	mov	rax, QWORD PTR -24[rbp]     # | rax := array -- указатель на начало массива
	add	rax, rdx                    # | rax := rax + rdx -- вычисляем адрес i-ого элемента массива
	mov	eax, DWORD PTR [rax]        # | eax := *(rax) <=> eax := array[i]
	mov	esi, eax                    # | esi := eax -- второй аргумент (array[i]) для вызова printf   
	lea	rdi, .LC1[rip]              # | rdi := &rip[.LC1] -- первый аргумент (адрес начала форматной строки) для вызова printf
	mov	eax, 0                      # | eax := 0
	call	printf@PLT              # | Вызываем printf(rdi=&rip[.LC1], rsi=array[i])
	add	DWORD PTR -4[rbp], 1        # | ++i
.L28:
	mov	eax, DWORD PTR -4[rbp]      # | eax := i
	cmp	eax, DWORD PTR -28[rbp]     # | Сравниваем i (eax) и size (rbp[-28])
	jl	.L29                        # | Если i < size, переходим к следующей итерации цикла
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
	jne	.L32                        # | Если fout не NULL, переходим к метке .L32
	mov	eax, 1                      # | Иначе возвращаем 1 через eax
	jmp	.L33                        # | И прыгаем на эпилог
.L32:
	mov	DWORD PTR -4[rbp], 0        # | rbp[-4] = 0 <=> int i = 0
	jmp	.L34                        # | Переходим на метку .L34
.L35:
	mov	eax, DWORD PTR -4[rbp]      # | eax := i
	cdqe                            # | 
	lea	rdx, 0[0+rax*4]             # |
	mov	rax, QWORD PTR -32[rbp]     # | rax := array
	add	rax, rdx                    # | rax := rax + rdx // rax := &array[i]
	mov	edx, DWORD PTR [rax]        # | edx := [rax] <=> edx := *(rax + rdx) = array[i] -- третий аргумент для вызова fprintf
	mov	rax, QWORD PTR -24[rbp]     # | rax := fout
	lea	rsi, .LC1[rip]              # | rsi := &rip[.LC1] -- второй аргумент для вызова fprintf (форматная строка)
	mov	rdi, rax                    # | rdi := rax = fout -- первый аргумент для вызова fprintf 
	mov	eax, 0                      # | eax := 0
	call	fprintf@PLT             # | Вызываем fprintf(rdi=fout, rsi=&rip[.LC1], rdx=array[i])
	add	DWORD PTR -4[rbp], 1        # | ++i
.L34:
	mov	eax, DWORD PTR -4[rbp]      # eax := i
	cmp	eax, DWORD PTR -36[rbp]     # Сравниваем eax (i) и size (rbp[-36])
	jl	.L35                        # Если i < size, переходим к следующей итерации цикла
	mov	rax, QWORD PTR -24[rbp]     # Иначе rax := fout
	mov	rsi, rax                    # rsi := rax -- второй аргумент (fout) для вызова fputc
	mov	edi, 10                     # edi := 10 -- первый аргумент (10 = '\n') для вызова fputc
	call	fputc@PLT               # Вызываем fputc(rdi='\n', rsi=fout)
	mov	eax, 0                      # Возвращаем 0 через eax
.L33:       
	leave                           # | Эпилог
	ret                             # \
	.size	writeArrayToFile, .-writeArrayToFile
	.section	.rodata
.LC2:
	.string	"Incorrect size of array"
	.text
	.globl	main
	.type	main, @function
main:
	endbr64
	push	rbp
	mov	rbp, rsp
	sub	rsp, 32
	mov	DWORD PTR -20[rbp], edi
	mov	QWORD PTR -32[rbp], rsi
	lea	rax, -4[rbp]
	mov	rdi, rax
	call	readArraySizeFromConsole
	test	eax, eax
	je	.L37
	lea	rdi, .LC2[rip]
	call	puts@PLT
	mov	eax, 0
	jmp	.L39
.L37:
	mov	eax, DWORD PTR -4[rbp]
	mov	esi, eax
	lea	rdi, A[rip]
	call	readArrayFromConsole
	mov	eax, DWORD PTR -4[rbp]
	mov	edi, eax
	call	makeB
	mov	eax, DWORD PTR -4[rbp]
	mov	esi, eax
	lea	rdi, B[rip]
	call	writeArrayToConsole
	mov	eax, 0
.L39:
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
