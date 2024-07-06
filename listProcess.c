#include <stdio.h>
#include <stdlib.h>

// 比较函数，用于qsort排序
int compare(const void* a, const void* b) {
    double diff = *(double*)a - *(double*)b;
    return (diff > 0) - (diff < 0);
}

// 对数组进行排序和去重
__declspec(dllexport) double* sort_and_deduplicate(double* array, int* length) {
    // 对数组进行排序
    qsort(array, *length, sizeof(double), compare);

    // 去重后的数组长度不会超过原始长度
    double* unique_array = (double*)malloc(*length * sizeof(double));
    if (unique_array == NULL) {
        fprintf(stderr, "Memory allocation failed\n");
        exit(EXIT_FAILURE);
    }

    // 去重
    int unique_length = 0;
    for (int i = 0; i < *length; ++i) {
        if (i == 0 || array[i] != array[i - 1]) {
            unique_array[unique_length++] = array[i];
        }
    }

    // 更新长度
    *length = unique_length;

    // 释放原数组的内存
    free(array);

    return unique_array;
}
