#include <stdio.h>

extern int MAX_N;
extern int A[];
extern int validateInput(int code1, int code2);

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


int readArrayFromFile(FILE *fin, int *array, int size) {
    if (fin == NULL) {
        return 1;
    }

    for (int i = 0; i < size; ++i) {
        fscanf(fin, "%d", &array[i]);
    }

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

int handleFileInput(FILE *input, int *size) {
    int code1 = readArraySizeFromFile(input, size);
    int code2 = readArrayFromFile(input, A, *size);
    fclose(input);

    return validateInput(code1, code2);
}
