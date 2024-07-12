#include <stdio.h>
#include <stdlib.h>

// 导出函数
__declspec(dllexport) int append_string_to_file(const char* str, const char* file_name) {
    // 打开文件以追加模式写入
    FILE *file = fopen(file_name, "a");
    if (file == NULL) {
        return -1; // 文件打开失败
    }

    // 写入新字符串和换行符
    fprintf(file, "\n%s", str);

    // 关闭文件
    fclose(file);

    return 0; // 成功
}
