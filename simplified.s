	.intel_syntax noprefix
	.text
	.local	A
	.comm	A,4000000,32
	.local	B
	.comm	B,4000000,32
	.data
	.type	MAX_N, @object
	.size	MAX_N, 4
MAX_N:
	.long	1000000
	.text
	.globl	getMin
	.type	getMin, @function
getMin:                             # Функция нахождения минимума в массиве
	push	rbp                     # /
	mov	rbp, rsp                    # | Пролог
	
    mov	QWORD PTR -24[rbp], rdi     # rbp[-24] := rdi // Положили на стек первый аргумент -- int *array
	mov	DWORD PTR -28[rbp], esi     # rbp[-28] := esi // Положили на стек второй агрумент -- int array_size
	mov	eax, DWORD PTR A[rip]       # eax := A[rip] // <=> int min = A[0]
	mov	DWORD PTR -4[rbp], eax      # rbp[-4] := eax // Кладем на стек min
	mov	DWORD PTR -8[rbp], 1        # rbp[-8] := 1 // Положили на стек значение счётчика i
	
    # На текущий момент состояние следующее
    # rbp[-24] -- int *array, rbp[-28] -- int array_size
    # rbp[-4] -- min, rbp[-8] -- i
    # eax пока тоже хранит значение минимума, но скоро будет использоваться для других целей.
    
    jmp	.L2                         # Переходим на метку, в которой будет проверяться условие цикла
.L5:
	cmp	DWORD PTR -4[rbp], 0        # Сравниваем min (rbp[-4]) и 0
	je	.L3                         # min == 0 => условие истинно, переходим в тело условного оператора
	mov	eax, DWORD PTR -8[rbp]      # eax := rbp[-8] // <=> eax := i
	cdqe                            # 
	lea	rdx, 0[0+rax*4]             #
	lea	rax, A[rip]                 #
	mov	eax, DWORD PTR [rdx+rax]    # eax := [rdx + rax] // <=> eax := A[i]
	cmp	DWORD PTR -4[rbp], eax      # Сравниваем min (rbp[-4]) и A[i] (eax)
	jle	.L4                         # Если min <= A[i], условие не выполняется и мы переходим на следуюзую итерацию
	                                # Иначе проверяем, второй операнд &&
    mov	eax, DWORD PTR -8[rbp]      # eax := rbp[-8] // <=> eax := i
	cdqe                            # 
	lea	rdx, 0[0+rax*4]             # 
	lea	rax, A[rip]                 #
	mov	eax, DWORD PTR [rdx+rax]    # eax := [rdx + rax] // <=> eax := A[i]
	test	eax, eax                # 
	je	.L4
.L3:                                # Тело условного оператора
	mov	eax, DWORD PTR -8[rbp]      # eax := rbp[-8] // <=> eax := i
	cdqe                            #
	lea	rdx, 0[0+rax*4]             # 
	lea	rax, A[rip]                 #
	mov	eax, DWORD PTR [rdx+rax]    #
	mov	DWORD PTR -4[rbp], eax      #
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
	.globl	makeB
	.type	makeB, @function
makeB:
	endbr64                         # / 
	push	rbp                     # | Пролог функции
	mov	rbp, rsp                    # |
	sub	rsp, 24                     # |


	mov	DWORD PTR -20[rbp], edi     # rbp[-20] := edi -- положили на стек первый аргумент -- int array_size
	mov	eax, DWORD PTR -20[rbp]     # eax := rbp[-20] --  в регистр только что полженный на стек array_size
	mov	esi, eax                    # 
	lea	rdi, A[rip]
	call	getMin
	mov	DWORD PTR -8[rbp], eax
	mov	DWORD PTR -4[rbp], 0
	jmp	.L8
.L11:
	mov	eax, DWORD PTR -4[rbp]
	cdqe
	lea	rdx, 0[0+rax*4]
	lea	rax, A[rip]
	mov	eax, DWORD PTR [rdx+rax]
	test	eax, eax
	jne	.L9
	mov	eax, DWORD PTR -4[rbp]
	cdqe
	lea	rcx, 0[0+rax*4]
	lea	rdx, B[rip]
	mov	eax, DWORD PTR -8[rbp]
	mov	DWORD PTR [rcx+rdx], eax
	jmp	.L10
.L9:
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
.L10:
	add	DWORD PTR -4[rbp], 1
.L8:
	mov	eax, DWORD PTR -4[rbp]
	cmp	eax, DWORD PTR -20[rbp]
	jl	.L11                        # 
	nop                             #
	nop                             #

    leave                           # | Эпилог функции
	ret                             # \
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
	jle	.L13
	mov	eax, 1
	jmp	.L14
.L13:
	mov	eax, 0
.L14:
	leave
	ret
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
	jle	.L16
	mov	eax, 1
	jmp	.L17
.L16:
	mov	eax, 0
.L17:
	leave
	ret
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
	jmp	.L19
.L20:
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
.L19:
	mov	eax, DWORD PTR -4[rbp]
	cmp	eax, DWORD PTR -28[rbp]
	jl	.L20
	mov	eax, 0
	leave
	ret
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
	jne	.L23
	mov	eax, 1
	jmp	.L24
.L23:
	mov	DWORD PTR -4[rbp], 0
	jmp	.L25
.L26:
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
.L25:
	mov	eax, DWORD PTR -4[rbp]
	cmp	eax, DWORD PTR -36[rbp]
	jl	.L26
	mov	eax, 0
.L24:
	leave
	ret
	.section	.rodata
.LC1:
	.string	"%d "
	.text
	.globl	writeArrayToConsole
	.type	writeArrayToConsole, @function
writeArrayToConsole:
	push	rbp
	mov	rbp, rsp
	sub	rsp, 32
	mov	QWORD PTR -24[rbp], rdi
	mov	DWORD PTR -28[rbp], esi
	mov	DWORD PTR -4[rbp], 0
	jmp	.L28
.L29:
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
.L28:
	mov	eax, DWORD PTR -4[rbp]
	cmp	eax, DWORD PTR -28[rbp]
	jl	.L29
	mov	edi, 10
	call	putchar@PLT
	mov	eax, 0
	leave
	ret
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
	jne	.L32
	mov	eax, 1
	jmp	.L33
.L32:
	mov	DWORD PTR -4[rbp], 0
	jmp	.L34
.L35:
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
.L34:
	mov	eax, DWORD PTR -4[rbp]
	cmp	eax, DWORD PTR -36[rbp]
	jl	.L35
	mov	rax, QWORD PTR -24[rbp]
	mov	rsi, rax
	mov	edi, 10
	call	fputc@PLT
	mov	eax, 0
.L33:
	leave
	ret
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
