#include <stdio.h>

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
