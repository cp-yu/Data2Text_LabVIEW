#include <stdio.h>
#include <stdlib.h>

__declspec(dllexport) void step(double start, double step, double end, double* array, int length) {
    int i = 0;
    double value = start;

    while (value <= end && i < length) {
        array[i] = value;
        value += step;
        i++;
    }

    // Fill remaining array slots with 0.0 if end is reached before filling the array
    for (; i < length; i++) {
        array[i] = end;
    }
}
