#include <time.h>
#include <stdlib.h>

extern int MAX_N;
extern int SAMPLE_SIZE;
extern int A[];
extern void fillArrayWithRandom(int *array, int size);
extern void makeB(int array_size);

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