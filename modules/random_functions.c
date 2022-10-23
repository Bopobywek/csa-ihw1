#include <stdio.h>
#include <stdlib.h>

extern int A[];
extern int writeArrayToFile(FILE *fout, int *array, int size);
extern int writeArrayToConsole(int *array, int size);

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
