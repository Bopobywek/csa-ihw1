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
getMin:
	# endbr64       <============     Что-то про защиту от атак. 
                                    # В нашем прекрасном мире ИДЗ нет хакеров,
                                    # поэтому можем спокойно удалить :)

	push	rbp                     # | пролог функции
	mov	rbp, rsp                    # \

	mov	QWORD PTR -24[rbp], rdi     # rbp[-24] := rdi // Кладем int *array (первый аргумент) на стек
	mov	DWORD PTR -28[rbp], esi     # rbp[-28] := esi // Кладем int array_size (второй аргумент) на стек
	mov	eax, DWORD PTR A[rip]       # eax := A[0] // <=> int min = A[0]
	mov	DWORD PTR -4[rbp], eax      # rbp[-4] := eax // Помещаем на стек, rbp[-4] -- min 
	mov	DWORD PTR -8[rbp], 1        # rbp[-8] := 1 // Кладем на стек счётчик цикла. int i = 1
	jmp	.L2                         # Переходим на метку L2

.L6:                                # Метки L3, L4, L5, L6 -- тело цикла                                
	mov	eax, DWORD PTR -8[rbp]      # eax := rbp[-8] // Помещаем в регистр eax со стека значение счётчика
	cdqe                            # 
	lea	rdx, 0[0+rax*4]             #  
	lea	rax, A[rip]                 # rax := &rip[A] -- адрес первого элемента в массиве                 
	mov	eax, DWORD PTR [rdx+rax]    # eax := [rdx + rax] // eax := *(rax + rdx) -- A[i] 
	cmp	DWORD PTR -4[rbp], eax      # cmp min, A[i]
	jle	.L3                         # Прыжок на метку L3, если min <= A[i] // <=> !(A[i] < min)
                                    # Если не прыгнули ... 
	mov	eax, DWORD PTR -8[rbp]      # 
	cdqe
	lea	rdx, 0[0+rax*4]
	lea	rax, A[rip]
	mov	eax, DWORD PTR [rdx+rax]
	test	eax, eax
	jne	.L4
.L3:                                # Проверяем "ИЛИ"
	cmp	DWORD PTR -4[rbp], 0        # min == 0
	jne	.L5                         # Если все условия для обновления минимума не выполнились,
                                    # уходим на метку .L5 и увеличиваем счётчик. Иначе входим в тело if
.L4:                                # .L4 -- тело if
	mov	eax, DWORD PTR -8[rbp]      # eax := rbp[-8] // rbp[-8] -- счётчик i
	cdqe                            #
	lea	rdx, 0[0+rax*4]             # 
	lea	rax, A[rip]                 # rax := &rip[A] // Теперь в rax адрес на начало A
	mov	eax, DWORD PTR [rdx+rax]    # eax := [rdx+rax] // eax := *(rdx + rax) -- A[i]
	mov	DWORD PTR -4[rbp], eax      # rbp[-4] := eax // Обновляем минимум
.L5:
	add	DWORD PTR -8[rbp], 1        # Увеличиваем счётчик i // ++i
.L2:
	mov	eax, DWORD PTR -8[rbp]      # eax := rbp[-8] // В eax со стека помещаем значения счётчика
	cmp	eax, DWORD PTR -28[rbp]     # Сравниваем i и array_size
	jl	.L6                         # Выполняем тело цикла, если i < array_size
	mov	eax, DWORD PTR -4[rbp]
	pop	rbp
	ret
	.size	getMin, .-getMin
	.globl	makeB
	.type	makeB, @function
makeB:
	endbr64
	push	rbp
	mov	rbp, rsp
	sub	rsp, 24
	mov	DWORD PTR -20[rbp], edi
	mov	eax, DWORD PTR -20[rbp]
	mov	esi, eax
	lea	rdi, A[rip]
	call	getMin
	mov	DWORD PTR -8[rbp], eax
	mov	DWORD PTR -4[rbp], 0
	jmp	.L9
.L12:
	mov	eax, DWORD PTR -4[rbp]
	cdqe
	lea	rdx, 0[0+rax*4]
	lea	rax, A[rip]
	mov	eax, DWORD PTR [rdx+rax]
	test	eax, eax
	jne	.L10
	mov	eax, DWORD PTR -4[rbp]
	cdqe
	lea	rcx, 0[0+rax*4]
	lea	rdx, B[rip]
	mov	eax, DWORD PTR -8[rbp]
	mov	DWORD PTR [rcx+rdx], eax
	jmp	.L11
.L10:
	mov	eax, DWORD PTR -4[rbp]
	cdqe
	lea	rdx, 0[0+rax*4]
	lea	rax, A[rip]
	mov	eax, DWORD PTR [rdx+rax]
	mov	edx, DWORD PTR -4[rbp]
	movsx	rdx, edx
	lea	rcx, 0[0+rdx*4]
	lea	rdx, B[rip]
	mov	DWORD PTR [rcx+rdx], eax
.L11:
	add	DWORD PTR -4[rbp], 1
.L9:
	mov	eax, DWORD PTR -4[rbp]
	cmp	eax, DWORD PTR -20[rbp]
	jl	.L12
	nop
	nop
	leave
	ret
	.size	makeB, .-makeB
	.section	.rodata
.LC0:
	.string	"%d"
	.text
	.globl	readArraySizeFromConsole
	.type	readArraySizeFromConsole, @function
readArraySizeFromConsole:
	endbr64
	push	rbp
	mov	rbp, rsp
	sub	rsp, 16
	mov	QWORD PTR -8[rbp], rdi
	mov	rax, QWORD PTR -8[rbp]
	mov	rsi, rax
	lea	rdi, .LC0[rip]
	mov	eax, 0
	call	__isoc99_scanf@PLT
	mov	rax, QWORD PTR -8[rbp]
	mov	edx, DWORD PTR [rax]
	mov	eax, DWORD PTR MAX_N[rip]
	cmp	edx, eax
	jle	.L14
	mov	eax, 1
	jmp	.L15
.L14:
	mov	eax, 0
.L15:
	leave
	ret
	.size	readArraySizeFromConsole, .-readArraySizeFromConsole
	.globl	readArraySizeFromFile
	.type	readArraySizeFromFile, @function
readArraySizeFromFile:
	endbr64
	push	rbp
	mov	rbp, rsp
	sub	rsp, 16
	mov	QWORD PTR -8[rbp], rdi
	mov	QWORD PTR -16[rbp], rsi
	mov	rdx, QWORD PTR -16[rbp]
	mov	rax, QWORD PTR -8[rbp]
	lea	rsi, .LC0[rip]
	mov	rdi, rax
	mov	eax, 0
	call	__isoc99_fscanf@PLT
	mov	rax, QWORD PTR -16[rbp]
	mov	edx, DWORD PTR [rax]
	mov	eax, DWORD PTR MAX_N[rip]
	cmp	edx, eax
	jle	.L17
	mov	eax, 1
	jmp	.L18
.L17:
	mov	eax, 0
.L18:
	leave
	ret
	.size	readArraySizeFromFile, .-readArraySizeFromFile
	.globl	readArrayFromConsole
	.type	readArrayFromConsole, @function
readArrayFromConsole:
	endbr64
	push	rbp
	mov	rbp, rsp
	sub	rsp, 32
	mov	QWORD PTR -24[rbp], rdi
	mov	DWORD PTR -28[rbp], esi
	mov	DWORD PTR -4[rbp], 0
	jmp	.L20
.L21:
	mov	eax, DWORD PTR -4[rbp]
	cdqe
	lea	rdx, 0[0+rax*4]
	mov	rax, QWORD PTR -24[rbp]
	add	rax, rdx
	mov	rsi, rax
	lea	rdi, .LC0[rip]
	mov	eax, 0
	call	__isoc99_scanf@PLT
	add	DWORD PTR -4[rbp], 1
.L20:
	mov	eax, DWORD PTR -4[rbp]
	cmp	eax, DWORD PTR -28[rbp]
	jl	.L21
	mov	eax, 0
	leave
	ret
	.size	readArrayFromConsole, .-readArrayFromConsole
	.globl	readArrayFromFile
	.type	readArrayFromFile, @function
readArrayFromFile:
	endbr64
	push	rbp
	mov	rbp, rsp
	sub	rsp, 48
	mov	QWORD PTR -24[rbp], rdi
	mov	QWORD PTR -32[rbp], rsi
	mov	DWORD PTR -36[rbp], edx
	cmp	QWORD PTR -24[rbp], 0
	jne	.L24
	mov	eax, 1
	jmp	.L25
.L24:
	mov	DWORD PTR -4[rbp], 0
	jmp	.L26
.L27:
	mov	eax, DWORD PTR -4[rbp]
	cdqe
	lea	rdx, 0[0+rax*4]
	mov	rax, QWORD PTR -32[rbp]
	add	rdx, rax
	mov	rax, QWORD PTR -24[rbp]
	lea	rsi, .LC0[rip]
	mov	rdi, rax
	mov	eax, 0
	call	__isoc99_fscanf@PLT
	add	DWORD PTR -4[rbp], 1
.L26:
	mov	eax, DWORD PTR -4[rbp]
	cmp	eax, DWORD PTR -36[rbp]
	jl	.L27
	mov	eax, 0
.L25:
	leave
	ret
	.size	readArrayFromFile, .-readArrayFromFile
	.section	.rodata
.LC1:
	.string	"%d "
	.text
	.globl	writeArrayToConsole
	.type	writeArrayToConsole, @function
writeArrayToConsole:
	endbr64
	push	rbp
	mov	rbp, rsp
	sub	rsp, 32
	mov	QWORD PTR -24[rbp], rdi
	mov	DWORD PTR -28[rbp], esi
	mov	DWORD PTR -4[rbp], 0
	jmp	.L29
.L30:
	mov	eax, DWORD PTR -4[rbp]
	cdqe
	lea	rdx, 0[0+rax*4]
	mov	rax, QWORD PTR -24[rbp]
	add	rax, rdx
	mov	eax, DWORD PTR [rax]
	mov	esi, eax
	lea	rdi, .LC1[rip]
	mov	eax, 0
	call	printf@PLT
	add	DWORD PTR -4[rbp], 1
.L29:
	mov	eax, DWORD PTR -4[rbp]
	cmp	eax, DWORD PTR -28[rbp]
	jl	.L30
	mov	edi, 10
	call	putchar@PLT
	mov	eax, 0
	leave
	ret
	.size	writeArrayToConsole, .-writeArrayToConsole
	.globl	writeArrayToFile
	.type	writeArrayToFile, @function
writeArrayToFile:
	endbr64
	push	rbp
	mov	rbp, rsp
	sub	rsp, 48
	mov	QWORD PTR -24[rbp], rdi
	mov	QWORD PTR -32[rbp], rsi
	mov	DWORD PTR -36[rbp], edx
	cmp	QWORD PTR -24[rbp], 0
	jne	.L33
	mov	eax, 1
	jmp	.L34
.L33:
	mov	DWORD PTR -4[rbp], 0
	jmp	.L35
.L36:
	mov	eax, DWORD PTR -4[rbp]
	cdqe
	lea	rdx, 0[0+rax*4]
	mov	rax, QWORD PTR -32[rbp]
	add	rax, rdx
	mov	edx, DWORD PTR [rax]
	mov	rax, QWORD PTR -24[rbp]
	lea	rsi, .LC1[rip]
	mov	rdi, rax
	mov	eax, 0
	call	fprintf@PLT
	add	DWORD PTR -4[rbp], 1
.L35:
	mov	eax, DWORD PTR -4[rbp]
	cmp	eax, DWORD PTR -36[rbp]
	jl	.L36
	mov	rax, QWORD PTR -24[rbp]
	mov	rsi, rax
	mov	edi, 10
	call	fputc@PLT
	mov	eax, 0
.L34:
	leave
	ret
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
	je	.L38
	lea	rdi, .LC2[rip]
	call	puts@PLT
	mov	eax, 0
	jmp	.L40
.L38:
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
.L40:
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
