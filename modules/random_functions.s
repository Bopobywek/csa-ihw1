.intel_syntax noprefix

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
	push	rbx						# | Зачем-то в регистр сохраняется rbx, который потом нигде всё равно не используются. Загадка...
	sub	rsp, 40						# | UPD: теперь ясно зачем... callee-saved регистры
	
	mov	r14, rdi					# | r14 := rdi = int *array
	mov	r12d, esi					# |	r12d := esi = int size
	mov	r13d, 0						# | r13d := 0 = i // Заводим счётчик цикла
	jmp	.L42						# | Переходим к проверке условия выхода из цикла
.L45:
	mov	eax, r13d					# | eax := r13d = i
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
	mov	eax, r13d					# |
	cdqe							# |
	lea	rdx, 0[0+rax*4]				# |
	mov	rax, r14					# |
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
	mov	eax, r13d					# eax := r13d = i
	cmp	eax, r12d					# Сравниваем i (eax) и size (r12d)
	jl	.L45						# Если i < size, переходим к следующей итерации цикла
	
	add	rsp, 40						# |
	pop	rbx							# |		Эпилог
	pop	r13
	pop	rbp							# |
	ret								# \ 
# ^
# Вместо стека теперь используем регистры r12, r13, r14


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
	
	mov	rbx, rdi					# | rbx := rdi = int *size -- первый входной параметр загружаем в регистр
	mov	r15, rsi					# | r15 := rsi = FILE *output -- второй входной параметр загружаем в регистр
	mov	r13d, edx					# |	r13d := edx = int flag_file_out -- третий входной параметр загружаем в регистр
	mov	eax, 0						# | eax := 0
	call	getRandomArraySize		# | Вызываем getRandomArraySize()
	
	mov	rdx, rbx					# | rdx := rbx = size
	mov	DWORD PTR [rdx], eax		# |	[rdx] := eax <=> *size = getRandomArraySize()
	mov	rax, rbx					# | rax := rbx = size
	mov	eax, DWORD PTR [rax]		# | eax := [rax] = *size
	mov	esi, eax					# |	esi := eax = *size
	lea	rdi, A[rip]					# | rdi := &rip[A] -- адрес на начало массива A
	call	fillArrayWithRandom		# | fillArrayWithRandom(rdi=&rip[A], esi=*size)
	
	cmp	r13d, 0						# | Сравниваем flag_file_out(rbp[-20) и 0
	jne	.L59						# |	Если не равны, переходим к else на метку .L59
	
	mov	rax, rbx					# | rax := rbx = size
	mov	eax, DWORD PTR [rax]		# | eax := [rax] = *size
	mov	esi, eax					# | esi := eax
	lea	rdi, .LC8[rip]				# | rdi := &rip[.LC8] -- адрес начала строки для печати
	mov	eax, 0						# | eax := 0
	call	printf@PLT				# | printf(rdi=&rip[.LC8], esi=*size)
	
	mov	rax, rbx					# | rax := rbx = size
	mov	eax, DWORD PTR [rax]		# | eax := [rax] = *size
	mov	esi, eax					# | esi := eax
	lea	rdi, A[rip]					# | rdi = &rip[A] -- адрес начала массива A
	call	writeArrayToConsole		# | writeArrayToConsole(rdi=&rip[A], esi=*size)
	
	jmp	.L60						# | Переходим на метку с эпилогом

.L59:								# | else				
	mov	rax, rbx		# | rax := rbx = size
	mov	edx, DWORD PTR [rax]		# | edx := [rax] = *size
	mov	rax, r15		# | rax := r15 = output
	lea	rsi, A[rip]					# | rsi := &rip[A] -- адрес начала массива
	mov	rdi, rax					# | rdi := rax
	call	writeArrayToFile		# | writeArrayToFile(rdi=output, rsi=&rip[A], edx=*size)
.L60:
	mov	eax, 0						# | Возвращаем 0 // return 0
	
	leave							# | Эпилог
	ret								# \
# ^
# Вместо стека теперь используем регистры rbx, r13, r15	
