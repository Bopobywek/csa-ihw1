extern int A[];

int getMin(int *array, int array_size) {
    int min = A[0];
    for (int i = 1; i < array_size; ++i) {
        if (min == 0 || (A[i] < min && A[i] != 0)) {
            min = A[i];
        }
    }

    return min;
}
