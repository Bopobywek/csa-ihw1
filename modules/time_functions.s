.intel_syntax noprefix

	.globl	getTimeDiff
	.type	getTimeDiff, @function
getTimeDiff:
	                                # /
	push	rbp                     # |
	mov	rbp, rsp                    # | Пролог
	
									
	mov	rax, rsi					# | rax := rsi = ts1.tv_nsec
	mov	r8, rdi						# | r8 := rdi = ts1.tv_sec
	mov	rsi, r8						# | rsi := r8 = ts1.tv_sec
	mov	rdi, r9						# | rdi := r9
	mov	rdi, rax					# | rdi := rax = ts1.tv_nsec
	
	mov	r12, rsi					# | r12 := rsi = ts1.tv_sec
	mov	r13, rdi					# | r13 := rsi = ts1.tv_nsec
	mov	r14, rdx					# | r14 := rdx = ts2.tv_sec
	mov	r15, rcx					# | r15 := rdx = ts2.tv_nsec
	
	
	mov	rax, r12					# | rax := r12 = ts1.tv_sec
	imul	rsi, rax, 1000			# | rsi := rax * 1000 = ts1.tv_sec * 1000
	mov	rcx, r13					# | rcx := r13 = ts1.tv_nsec
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
	mov	rax, r14     				# | rax := r14 = ts2.tv_sec
	imul	rsi, rax, 1000			# |	rsi := rax * 1000
	mov	rcx, r15					# \ rcx := r15 = ts2.tv_nsec
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
# ^
# Вместо стека теперь используем регистры r12, r13, r14, r15	
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
	