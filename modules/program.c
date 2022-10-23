#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <time.h>

static int A[10000000];
static int B[10000000];
const int MAX_N = 10000000;
const int SAMPLE_SIZE = 10;

extern int readArraySizeFromConsole(int *size);
extern int readArrayFromConsole(int *array, int size);
extern int writeArrayToConsole(int *array, int size);
extern int handleConsoleInput(int *size);

extern int readArraySizeFromFile(FILE *fin, int *size);
extern int readArrayFromFile(FILE *fin, int *array, int size);
extern int writeArrayToFile(FILE *fout, int *array, int size);
extern int isFilesValid(int flag_in, int flag_out, FILE *input, FILE *output);
extern int handleConsoleInput(int *size);

extern int getRandomArraySize();
extern void fillArrayWithRandom(int *array, int size);
extern int handleRandomInput(int *size, FILE *output, int flag_file_out);

extern int64_t getTimeDiff(struct timespec ts1, struct timespec ts2);
extern int64_t measureTime();

extern int validateInput(int code1, int code2);

int main(int argc, char *argv[]) {
    int opt;    
    FILE *input = NULL;
    FILE *output = NULL;
    int file_in_flag = 0;
    int file_out_flag = 0;
    int random_flag = 0;
    int test_flag = 0;
    int seed = 42;

    while ((opt = getopt(argc, argv, "rts:i:o:")) != -1) {
        switch(opt) {
            // Генерация случайного набора
            case 'r':               
                random_flag = 1;
                break;
            // Указание входного файла
            case 'i':               
                file_in_flag = 1;
                input = fopen(optarg, "r");
                break;
            // Указание выходного файла
            case 'o':               
                file_out_flag = 1;
                output = fopen(optarg, "w");
                break;
            // seed для рандома
            case 's':               
                seed = atoi(optarg);
                break;
            // Тестирование на больших входных данных 
            // некоторое количество раз для замера времени
            case 't':               
                test_flag = 1;
                break;
            // В случае ошибки
            case '?':
                return 0;
        }
    }
    
    srand(seed);

    if (test_flag) {
        int64_t elapsed = measureTime();
        printf("Elapsed time: %ld ms\n", elapsed);
        return 0;
    }

    if (isFilesValid(file_in_flag, file_out_flag, input, output) != 0) {
        return 0;
    }


    int n;
    int status_code = 0;
    if (file_in_flag && random_flag != 1) {
        status_code = handleFileInput(input, &n);
    } else if (random_flag != 1) {
        status_code = handleConsoleInput(&n);
    } else {
        handleRandomInput(&n, output, file_out_flag);
    }

    if (status_code != 0) {
        return 0;
    }
    
    makeB(n);

    int out_state = 0;
    if (file_out_flag == 0) {
        out_state = writeArrayToConsole(B, n);
    } else {
        out_state = writeArrayToFile(output, B, n);
        fclose(output);
    }

    if (out_state != 0) {
        printf("Cannot write a result to output stream");
    }

    return 0;
}
