.intel_syntax noprefix
	.section	.rodata
.LCFHJK:
	.string	"%d"
.LCFHJK1:
	.string	"%d "
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
	lea	rsi, .LCFHJK[rip]              # | rsi := &rip[.LCFHJK] -- адрес начала форматной строки (второй аргумент для вызова fscanf)
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



	.globl	readArrayFromFile
	.type	readArrayFromFile, @function
readArrayFromFile:
	                                # /
	push	rbp                     # |
	mov	rbp, rsp                    # | Пролог
	sub	rsp, 48                     # |
	
	mov	r12, rdi     				# | r12 := rdi <=> r12 := fin -- загружаем в регистр первый аргумент (указатель на FILE)
	mov	r13, rsi     				# | r13 := rsi <=> r13 := array -- загружаем в регистр второй аргумент (указатель на начало массива)
	mov	r14d, edx     				# | r14d := edx <=> r14d := size -- загружаем в регистр третий аргумент (размер массива)
	cmp	r12, 0       				# | Сравниваем fin (r12) и NULL (0)
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
	lea	rsi, .LCFHJK[rip]              # | rsi := &rip[.LCFHJK] -- второй аргумент для вызова fscanf (адрес начала форматной строки)
	mov	rdi, rax                    # | rdi := rax <=> rdi := fin -- первым аргументом передаем указатель на FILE
	mov	eax, 0                      # | eax := 0
	call	__isoc99_fscanf@PLT     # | Вызываем fscanf
	add	DWORD PTR -4[rbp], 1		# | ++i
.L28:
	mov	eax, DWORD PTR -4[rbp]      # | eax := i // rbp[-4] = i
	cmp	eax, r14d     				# | Сравниваем i (eax) и size (r14d)
	jl	.L29						# | Если i < size, прыгаем на метку .L29 -- тело цикла
	mov	eax, 0						# | Иначе возвращаем 0 -- знак, что всё прошло без ошибок
.L27:
	leave                           # | Эпилог функции
	ret                             # \

# ^
# Вместо стека теперь используем регистры r12, r13, r14

	.globl	writeArrayToFile
	.type	writeArrayToFile, @function
writeArrayToFile:
	                                # /
	push	rbp                     # |
	mov	rbp, rsp                    # | Пролог
	sub	rsp, 48                     # |
	
	mov	r12, rdi     				# | r12 := rdi -- первый переданный аргумент (FILE *fout) загружаем в регистр
	mov	r13, rsi     				# | r13 := rsi -- загружаем  в регистр второй переданный аргумент (int *array -- указатель на начало массива)
	mov	r15d, edx     				# | r15d := edx -- загружаем  в регистр третий переданный аргумент (int size -- размер массива)
	cmp	r12, 0       				# | Сравниваем fout (r12) и NULL (0)
	jne	.L35						# | Если fout не NULL, переходим к метке .L35
	mov	eax, 1                      # | Иначе возвращаем 1 через eax
	jmp	.L36						# | И прыгаем на эпилог
.L35:
	mov	r14d, 0        				# | r14d = 0 <=> int i = 0		
	jmp	.L37						# | Переходим на метку .L37
.L38:
	mov	eax, r14d      				# | eax := i
	cdqe                            # | rax := sign-extend of eax. Копирует знак (31 бит) в старшие 32 бита регистра rax
	lea	rdx, 0[0+rax*4]             # | rdx := rax * 4 // Подобным трюком вычисляется адрес (rax*4)[0], который равен rax * 4
	mov	rax, r13     				# | rax := array
	add	rax, rdx                    # | rax := rax + rdx // rax := &array[i]
	mov	edx, DWORD PTR [rax]        # | edx := [rax] <=> edx := *(rax + rdx) = array[i] -- третий аргумент для вызова fprintf
	mov	rax, r12     				# | rax := fout
	lea	rsi, .LCFHJK1[rip]              # | rsi := &rip[.LCFHJK1] -- второй аргумент для вызова fprintf (форматная строка)
	mov	rdi, rax                    # | rdi := rax = fout -- первый аргумент для вызова fprintf 
	mov	eax, 0                      # | eax := 0
	call	fprintf@PLT             # | Вызываем fprintf(rdi=fout, rsi=&rip[.LCFHJK1], rdx=array[i])
	add	r14d, 1        				# | ++i
.L37:
	mov	eax, r14d      				# | eax := i
	cmp	eax, r15d     				# | Сравниваем eax (i) и size (r15d)
	jl	.L38						# | Если i < size, переходим к следующей итерации цикла
	mov	rax, r12     				# | Иначе rax := fout
	mov	rsi, rax                    # | rsi := rax -- второй аргумент (fout) для вызова fputc
	mov	edi, 10                     # | edi := 10 -- первый аргумент (10 = '\n') для вызова fputc
	call	fputc@PLT               # | Вызываем fputc(rdi='\n', rsi=fout)
	mov	eax, 0                      # | Возвращаем 0 через eax
.L36:
	leave                           # | Эпилог
	ret                             # \
# ^
# Вместо стека теперь используем регистры r12, r13, r14, r15


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
	
	mov	r12d, edi					# | Загружаем первый переданный аргумент int flag_in в регистр. r12d := edi = flag_in
	mov	r13d, esi					# | Загружаем второй переданный аргумент int flag_in в регистр. r13d := esi = flag_out
	mov	r14, rdx					# | r14 := rdx = input -- аналогично загружаем в регистр третий переданный агрумент (указатель на FILE)
	mov	r15, rcx					# | Загружаем в регистр 4 переданный аргумент FILE *output. r15 := rcx = output
	cmp	r12d, 1						# | Сравниваем flag_in (r12d) и 1
	jne	.L47						# | Если не равны, && не является истинной, поэтому прыгаем на метку .L47 -- следующий if
	cmp	r14, 0						# | Иначе сравниваем input (r14) и NULL (0)
	jne	.L47						# | Если не равны, && не является истинной, поэтому прыгаем на метку .L47 -- следующий if
	lea	rdi, .LC2[rip]				# | Иначе, загружаем в rdi первый аргумент для вызова printf -- адрес на начало строки для печати: rdi := &rip[.LC2]
	mov	eax, 0						# | eax := 0
	call	printf@PLT				# | Вызываем printf(rdi=&rip[.LC2])
	mov	eax, 1						# | Возвращаем через eax 1 -- знак того, что файл не является валидным
	jmp	.L48						# | Переходим на метку с эпилогом
.L47:
	cmp	r13d, 1						# | Сравниваем flag_out (r13d) и 1
	jne	.L49						# | Если не равны, && не является истинной, переходим на метку с возвратом
	cmp	r15, 0						# | Иначе сравниваем output (r15) и NULL (0)
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
# ^
# Вместо стека теперь используем регистры r12, r13, r14, r15

.globl	handleFileInput
	.type	handleFileInput, @function
handleFileInput:
	                                # /
	push	rbp                     # |
	mov	rbp, rsp                    # | Пролог
	sub	rsp, 32						# |
	
	mov	r15, rdi					# | r15 := rdi = FILE *input -- первый входной параметр загружаем в регистр
	mov	r14, rsi					# | r14 := rsi = int *size -- второй входной параметр загружаем в регистр
	mov	rdx, r14					# | rdx := r14 = size
	mov	rax, r15					# | rax := r15 = input
	mov	rsi, rdx					# |	rsi := rdx = size
	mov	rdi, rax					# |	rdi := rax = input
	call	readArraySizeFromFile   # | Вызываем readArraySizeFromFile(rdi=input, rsi=size)
	
	mov	ebx, eax					# | r14 := eax <=> int code1 = возвращенное значение от readArraySizeFromFile
	mov	rax, r14					# | rax := r14 = size
	mov	edx, DWORD PTR [rax]		# | edx := [rax] = *size
	mov	rax, r15					# |	rax := r15 = input
	lea	rsi, A[rip]					# |	rsi := &rip[A] -- адрес на начало массива A
	mov	rdi, rax					# | rdi := rax = input
	call	readArrayFromFile		# | Вызываем readArrayFromFile(rdi=input, rsi=&rip[A], edx=*size)
	
	mov	r12d, eax					# | r12d := eax <=> int code1 = возвращенное значение от readArraySizeFromFile
	mov	rax, r15					# | rax := r15 = input
	mov	rdi, rax					# |	rdi := rax = input
	call	fclose@PLT				# | Вызываем fclose(rdi=input)
	
	mov	edx, r12d					# | edx := r12d = code1
	mov	eax, ebx					# | eas := r14 = code2
	mov	esi, edx					# |	esi := edx = code2
	mov	edi, eax					# | edi := eax = code1
	call	validateInput			# | Вызываем validateInput(edi=code1, esi=code2)
									# | Значение возвращаем через eax так же, как и validateInput, поэтому ничего не делаем и переходим к эпилогу 
	leave							# | Эпилог
	ret								# \
# ^
# Вместо стека теперь используем регистры r12, r14, r15
