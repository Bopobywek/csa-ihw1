	.file	"main.c"
	.intel_syntax noprefix
	.text
	.comm	A,40000000,32
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
.LC0:
	.string	"r"
.LC1:
	.string	"w"
.LC2:
	.string	"rts:i:o:"
.LC3:
	.string	"Elapsed time: %ld ms\n"
	.align 8
.LC4:
	.string	"Cannot write a result to output stream"
	.text
	.globl	main
	.type	main, @function
main:
.LFB6:
	.cfi_startproc
	endbr64
	push	rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	mov	rbp, rsp
	.cfi_def_cfa_register 6
	sub	rsp, 96
	mov	DWORD PTR -84[rbp], edi
	mov	QWORD PTR -96[rbp], rsi
	mov	rax, QWORD PTR fs:40
	mov	QWORD PTR -8[rbp], rax
	xor	eax, eax
	mov	QWORD PTR -32[rbp], 0
	mov	QWORD PTR -24[rbp], 0
	mov	DWORD PTR -64[rbp], 0
	mov	DWORD PTR -60[rbp], 0
	mov	DWORD PTR -56[rbp], 0
	mov	DWORD PTR -52[rbp], 0
	mov	DWORD PTR -48[rbp], 42
	jmp	.L2
.L11:
	cmp	DWORD PTR -36[rbp], 63
	je	.L3
	cmp	DWORD PTR -36[rbp], 63
	jl	.L2
	cmp	DWORD PTR -36[rbp], 116
	jg	.L2
	cmp	DWORD PTR -36[rbp], 105
	jl	.L2
	mov	eax, DWORD PTR -36[rbp]
	sub	eax, 105
	cmp	eax, 11
	ja	.L2
	mov	eax, eax
	lea	rdx, 0[0+rax*4]
	lea	rax, .L5[rip]
	mov	eax, DWORD PTR [rdx+rax]
	cdqe
	lea	rdx, .L5[rip]
	add	rax, rdx
	notrack jmp	rax
	.section	.rodata
	.align 4
	.align 4
.L5:
	.long	.L9-.L5
	.long	.L2-.L5
	.long	.L2-.L5
	.long	.L2-.L5
	.long	.L2-.L5
	.long	.L2-.L5
	.long	.L8-.L5
	.long	.L2-.L5
	.long	.L2-.L5
	.long	.L7-.L5
	.long	.L6-.L5
	.long	.L4-.L5
	.text
.L7:
	mov	DWORD PTR -56[rbp], 1
	jmp	.L2
.L9:
	mov	DWORD PTR -64[rbp], 1
	mov	rax, QWORD PTR optarg[rip]
	lea	rsi, .LC0[rip]
	mov	rdi, rax
	call	fopen@PLT
	mov	QWORD PTR -32[rbp], rax
	jmp	.L2
.L8:
	mov	DWORD PTR -60[rbp], 1
	mov	rax, QWORD PTR optarg[rip]
	lea	rsi, .LC1[rip]
	mov	rdi, rax
	call	fopen@PLT
	mov	QWORD PTR -24[rbp], rax
	jmp	.L2
.L6:
	mov	rax, QWORD PTR optarg[rip]
	mov	rdi, rax
	call	atoi@PLT
	mov	DWORD PTR -48[rbp], eax
	jmp	.L2
.L4:
	mov	DWORD PTR -52[rbp], 1
	jmp	.L2
.L3:
	mov	eax, 0
	jmp	.L21
.L2:
	mov	rcx, QWORD PTR -96[rbp]
	mov	eax, DWORD PTR -84[rbp]
	lea	rdx, .LC2[rip]
	mov	rsi, rcx
	mov	edi, eax
	call	getopt@PLT
	mov	DWORD PTR -36[rbp], eax
	cmp	DWORD PTR -36[rbp], -1
	jne	.L11
	mov	eax, DWORD PTR -48[rbp]
	mov	edi, eax
	call	srand@PLT
	cmp	DWORD PTR -52[rbp], 0
	je	.L12
	mov	eax, 0
	call	measureTime@PLT
	mov	QWORD PTR -16[rbp], rax
	mov	rax, QWORD PTR -16[rbp]
	mov	rsi, rax
	lea	rdi, .LC3[rip]
	mov	eax, 0
	call	printf@PLT
	mov	eax, 0
	jmp	.L21
.L12:
	mov	rcx, QWORD PTR -24[rbp]
	mov	rdx, QWORD PTR -32[rbp]
	mov	esi, DWORD PTR -60[rbp]
	mov	eax, DWORD PTR -64[rbp]
	mov	edi, eax
	call	isFilesValid@PLT
	test	eax, eax
	je	.L13
	mov	eax, 0
	jmp	.L21
.L13:
	mov	DWORD PTR -44[rbp], 0
	cmp	DWORD PTR -64[rbp], 0
	je	.L14
	cmp	DWORD PTR -56[rbp], 1
	je	.L14
	lea	rdx, -68[rbp]
	mov	rax, QWORD PTR -32[rbp]
	mov	rsi, rdx
	mov	rdi, rax
	call	handleFileInput@PLT
	mov	DWORD PTR -44[rbp], eax
	jmp	.L15
.L14:
	cmp	DWORD PTR -56[rbp], 1
	je	.L16
	lea	rax, -68[rbp]
	mov	rdi, rax
	call	handleConsoleInput@PLT
	mov	DWORD PTR -44[rbp], eax
	jmp	.L15
.L16:
	mov	edx, DWORD PTR -60[rbp]
	mov	rcx, QWORD PTR -24[rbp]
	lea	rax, -68[rbp]
	mov	rsi, rcx
	mov	rdi, rax
	call	handleRandomInput@PLT
.L15:
	cmp	DWORD PTR -44[rbp], 0
	je	.L17
	mov	eax, 0
	jmp	.L21
.L17:
	mov	eax, DWORD PTR -68[rbp]
	mov	edi, eax
	call	makeB@PLT
	mov	DWORD PTR -40[rbp], 0
	cmp	DWORD PTR -60[rbp], 0
	jne	.L18
	mov	eax, DWORD PTR -68[rbp]
	mov	esi, eax
	lea	rdi, B[rip]
	call	writeArrayToConsole@PLT
	mov	DWORD PTR -40[rbp], eax
	jmp	.L19
.L18:
	mov	edx, DWORD PTR -68[rbp]
	mov	rax, QWORD PTR -24[rbp]
	lea	rsi, B[rip]
	mov	rdi, rax
	call	writeArrayToFile@PLT
	mov	DWORD PTR -40[rbp], eax
	mov	rax, QWORD PTR -24[rbp]
	mov	rdi, rax
	call	fclose@PLT
.L19:
	cmp	DWORD PTR -40[rbp], 0
	je	.L20
	lea	rdi, .LC4[rip]
	mov	eax, 0
	call	printf@PLT
.L20:
	mov	eax, 0
.L21:
	mov	rcx, QWORD PTR -8[rbp]
	xor	rcx, QWORD PTR fs:40
	je	.L22
	call	__stack_chk_fail@PLT
.L22:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE6:
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
