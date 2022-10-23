	.intel_syntax noprefix
	.text
	.comm	A,40000000,32
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
	call	measureTime@PLT			# | measureTime()
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
	call	isFilesValid@PLT			# | isFilesValid(rdi=file_in_flag, esi=file_out_flag, rdx=input, rcx=output)
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
	call	handleFileInput@PLT			# | handleFileInput(rdi=input, rsi=&n)
	
	mov	DWORD PTR -40[rbp], eax		# | status_code = rbp[-40] := eax -- handleFileInput вернула значение через eax
	jmp	.L81
.L80:
	cmp	DWORD PTR -28[rbp], 1		# | Сравниваем random_flag (rbp[-28]) и 1
	je	.L82						# | Если равны, переходим к else (.L82)
	lea	rax, -60[rbp]				# | rax := &rbp[-60] = &n
	mov	rdi, rax					# | rdi := rax = &n
	call	handleConsoleInput@PLT		# | handleConsoleInput(rdi=&n)
	
	mov	DWORD PTR -40[rbp], eax 	# | status_code = rbp[-40] := eax -- handleFileInput вернула значение через eax    
	jmp	.L81
.L82: # else
	mov	edx, DWORD PTR -24[rbp] 	# | edx := rbp[-24] = file_out_flag
	mov	rcx, QWORD PTR -16[rbp]		# | rcx := rbp[-16] = output
	lea	rax, -60[rbp]				# | rax := &rbp[-60] = &n
	mov	rsi, rcx					# | rsi := rcx = output
	mov	rdi, rax					# | rdi := rax = &n
	call	handleRandomInput@PLT		# | handleRandomInput(rdi=&n, rsi=output, rdx=file_out_flag)
.L81:
	cmp	DWORD PTR -40[rbp], 0		# | Сравниваем status_code (rbp[-40]) и 0
	je	.L83						# | Если status_code == 0, переходим на метку .L83
	mov	eax, 0						# | Иначе возвращаем 0 через eax и переходим к эпилогу .L87
	jmp	.L87
.L83:
	mov	eax, DWORD PTR -60[rbp]		# | eax := rbp[-60] = n
	mov	edi, eax					# | edi := eax = n
	call	makeB@PLT					# | makeB(edi=n)
	
	mov	DWORD PTR -44[rbp], 0		# | out_state = rbp[-44] := 0
	cmp	DWORD PTR -24[rbp], 0		# | Сравниваем file_out_flag (rbp[-24]) и 0
	jne	.L84						# | Если не равны, переходим к else
	mov	eax, DWORD PTR -60[rbp]		# | eax := rbp[-60] = n
	mov	esi, eax					# | esi := eax = n
	lea	rdi, B[rip]					# | rdi := &rip[B] -- адрес на начало массива B
	call	writeArrayToConsole@PLT		# | writeArrayToConsole(rdi=&rip[B], rsi=n)
	
	mov	DWORD PTR -44[rbp], eax		# | out_state = rbp[-44] := eax -- функция вернула значение через eax 
	jmp	.L85
.L84:
	mov	edx, DWORD PTR -60[rbp] 	# | edx := rbp[-60] = n
	mov	rax, QWORD PTR -16[rbp]		# | rax := rbp[-16] =  output
	lea	rsi, B[rip]					# | rsi := &rip[B] -- адрес начала массива B
	mov	rdi, rax					# | rdi := rax = output
	call	writeArrayToFile@PLT		# | writeArrayToFile(rdi=output, rsi=&rip[B], edx=n)
	
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
