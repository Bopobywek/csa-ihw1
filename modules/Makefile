%.o: %.s
	gcc -c -masm=intel "$<" -o "$@"

obj: main.o console_functions.o file_functions.o random_functions.o time_functions.o validators.o get_min.o make_b.o

program: main.o console_functions.o file_functions.o random_functions.o time_functions.o validators.o
	gcc -lc main.o console_functions.o file_functions.o random_functions.o time_functions.o validators.o get_min.o make_b.o -o program

.PHONY: obj