#include <stdio.h>
#include <stdlib.h>

// 创建一个包含起始值、步长和终点值的双精度数组
__declspec(dllexport) double* create_double_array(double start, double step, double end, int* length) {
    // 计算数组的长度
    int len = (int)((end - start) / step) + 1;
    *length = len;

    // 为数组分配内存
    double* array = (double*)malloc(len * sizeof(double));
    if (array == NULL) {
        fprintf(stderr, "Memory allocation failed\n");
        exit(EXIT_FAILURE);
    }

    // 填充数组
    for (int i = 0; i < len; ++i) {
        array[i] = start + i * step;
        if (array[i] > end) {
            array[i] = end;
            *length = i + 1;
            break;
        }
    }

    return array;
}