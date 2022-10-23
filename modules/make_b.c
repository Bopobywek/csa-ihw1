extern int A[];
extern int B[];
extern int getMin(int *array, int size);

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