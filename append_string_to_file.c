#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// 导出函数
__declspec(dllexport) int append_string_to_file(const char* str, const char* file_name) {

    // 获取字符串长度
    size_t len = strlen(file_name);

    // 检查字符串长度是否至少为3，以便修改后缀
    if (len >= 3) {
        // 修改最后三个字符为"txt"
        strcpy(file_name + len - 3, "txt");
    } else {
        return -3; // 字符串长度不足
    }

    // 打开文件以追加模式写入
    FILE *file = fopen(file_name, "a");
    if (file == NULL) {
        return -1; // 文件打开失败
    }
    // 写入新字符串和换行符
    fprintf(file, "\n%s", str);

    // 释放内存并关闭文件
    fclose(file);

    return 0; // 成功
}
