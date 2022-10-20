#include <stdio.h>


static int A[1000000];
static int B[1000000];
static int MAX_N = 1000000;

int getMin(int *array, int array_size) {
    int min = A[0];
    for (int i = 1; i < array_size; ++i) {
        if ((A[i] < min && A[i] != 0) || min == 0) {
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
    
    if (*size > MAX_N) {
        return 1;
    }

    return 0;
}


int readArraySizeFromFile(FILE *fin, int *size) {
    fscanf(fin, "%d", size);
    
    if (*size > MAX_N) {
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

int main(int argc, char *argv[]) {
    int n;
    if (readArraySizeFromConsole(&n) != 0) {
        printf("Incorrect size of array\n");
        return 0;
    }

    readArrayFromConsole(A, n);

    makeB(n);
    writeArrayToConsole(B, n);    
    return 0;
}

