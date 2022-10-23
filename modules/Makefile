%.s: %.c
	gcc -S -masm=intel "$<" -o "$@"

%.o: %.s
	gcc -c -masm=intel "$<" -o "$@"

asm: main.s console_functions.s file_functions.s random_functions.s time_functions.s validators.s get_min.s make_b.s

obj: main.o console_functions.o file_functions.o random_functions.o time_functions.o validators.o get_min.o make_b.o

program: main.o console_functions.o file_functions.o random_functions.o time_functions.o validators.o
	gcc -lc main.o console_functions.o file_functions.o random_functions.o time_functions.o validators.o get_min.o make_b.o -o program

.PHONY: asm obj