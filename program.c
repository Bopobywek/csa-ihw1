#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <time.h>

static int A[10000000];
static int B[10000000];
const int MAX_N = 10000000;
const int SAMPLE_SIZE = 10;

int getMin(int *array, int array_size) {
    int min = A[0];
    for (int i = 1; i < array_size; ++i) {
        if (min == 0 || (A[i] < min && A[i] != 0)) {
            min = A[i];
        }
    }

    return min;
}

void makeB(int array_size) {
    int min = getMin(A, array_size);

    for (int i = 0; i < array_size; ++i) {
        if (A[i] == 0) {
            B[i] = min;
        } else {
            B[i] = A[i];
        }
    }
}

int readArraySizeFromConsole(int *size) {
    scanf("%d", size);
    
    if (*size > MAX_N || *size < 1) {
        return 1;
    }

    return 0;
}


int readArraySizeFromFile(FILE *fin, int *size) {
    if (fin == NULL) {
        return 1;
    }

    fscanf(fin, "%d", size);
    
    if (*size > MAX_N || *size < 1) {
        return 1;
    }

    return 0;
}

int readArrayFromConsole(int *array, int size) {
    for (int i = 0; i < size; ++i) {
        scanf("%d", &array[i]);
    }

    return 0;
}

int readArrayFromFile(FILE *fin, int *array, int size) {
    if (fin == NULL) {
        return 1;
    }

    for (int i = 0; i < size; ++i) {
        fscanf(fin, "%d", &array[i]);
    }

    return 0;
}

int writeArrayToConsole(int *array, int size) {
    for (int i = 0; i < size; ++i) {
        printf("%d ", array[i]);
    }
    printf("\n");

    return 0;
}

int writeArrayToFile(FILE *fout, int *array, int size) {
    if (fout == NULL) {
        return 1;
    }

    for (int i = 0; i < size; ++i) {
        fprintf(fout, "%d ", array[i]);
    }
    fprintf(fout, "\n"); 

    return 0;
}

int getRandomArraySize() {
    return (rand() % 20) + 1;
}

void fillArrayWithRandom(int *array, int size) {
    for (int i = 0; i < size; ++i) {
        if ((i + 1) % 3 == 0) {
            array[i] = 0;
        } else {
            array[i] = (rand() % 200) - (rand() % 250);
        }
    }
}

int isFilesValid(int flag_in, int flag_out, FILE *input, FILE *output) {
    if (flag_in == 1 && input == NULL) {
        printf("Incorrect input file");
        return 1;
    }

    if (flag_out == 1 && output == NULL) {
        printf("Incorrect output file");
        return 1;
    }

    return 0;
}

int validateInput(int code1, int code2) {
    if (code1 == 1) {
        printf("Incorrect size of array");
        return 1;
    } else if (code2 == 1) {
        printf("Incorrect element in array");
        return 1;
    }

    return 0;
}

int handleFileInput(FILE *input, int *size) {
    int code1 = readArraySizeFromFile(input, size);
    int code2 = readArrayFromFile(input, A, *size);
    fclose(input);

    return validateInput(code1, code2);
}

int handleConsoleInput(int *size) {
    printf("Input array size 0 < size < 1'000'000: ");
    int code1 = readArraySizeFromConsole(size);
    printf("Enter the array elements in a row separated by a space:\n");
    int code2 = readArrayFromConsole(A, *size);

    return validateInput(code1, code2);
}

int handleRandomInput(int *size, FILE *output, int flag_file_out) {
    *size = getRandomArraySize();
    fillArrayWithRandom(A, *size);
    if (flag_file_out == 0) {
        printf("Random array with size %d:\n", *size);
        writeArrayToConsole(A, *size);
    } else {
        writeArrayToFile(output, A, *size);
    }

    return 0;
}

int64_t getTimeDiff(struct timespec ts1, struct timespec ts2) {
    int64_t ts1_ms = ts1.tv_sec * 1000 + ts1.tv_nsec / 1000000;
    int64_t ts2_ms = ts2.tv_sec * 1000 + ts2.tv_nsec / 1000000;

    return ts1_ms - ts2_ms;
}

int64_t measureTime() {
    struct timespec start;
    struct timespec end;
	int64_t elapsed = 0;

    for (int i = 0; i < SAMPLE_SIZE; ++i) {
        fillArrayWithRandom(A, MAX_N);
		clock_gettime(CLOCK_MONOTONIC, &start);
        makeB(MAX_N);
		clock_gettime(CLOCK_MONOTONIC, &end);
		elapsed += getTimeDiff(end, start);
    }
    

    return elapsed;
}

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
