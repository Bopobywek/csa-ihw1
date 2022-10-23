#include <stdio.h>

extern int MAX_N;
extern int A[];
extern int validateInput(int code1, int code2);

int readArraySizeFromConsole(int *size) {
    scanf("%d", size);
    
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

int writeArrayToConsole(int *array, int size) {
    for (int i = 0; i < size; ++i) {
        printf("%d ", array[i]);
    }
    printf("\n");

    return 0;
}

int handleConsoleInput(int *size) {
    printf("Input array size 0 < size < 1'000'000: ");
    int code1 = readArraySizeFromConsole(size);
    printf("Enter the array elements in a row separated by a space:\n");
    int code2 = readArrayFromConsole(A, *size);

    return validateInput(code1, code2);
}
