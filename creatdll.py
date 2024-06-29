# build_dll.py
from cffi import FFI

ffibuilder = FFI()

# 声明函数接口
ffibuilder.cdef("""
    void ToText(double* list_a, int len_a, double* list_b, int len_b, 
                const char* title, const char* extra_info, const char* col_name_a, const char* col_name_b);
""")

# 定义C函数的实现
ffibuilder.set_source("dlltest", """
    #include <stdio.h>
    #include <string.h>

    void ToText(double* list_a, int len_a, double* list_b, int len_b, 
                const char* title, const char* extra_info, const char* col_name_a, const char* col_name_b) {
        FILE *file = fopen(title, "w");
        if (file) {
            fprintf(file, "%s\\n", extra_info);
            fprintf(file, "%s\\t%s\\n", col_name_a, col_name_b);
            int min_len = len_a < len_b ? len_a : len_b;
            for (int i = 0; i < min_len; i++) {
                fprintf(file, "%f\\t%f\\n", list_a[i], list_b[i]);
            }
            fclose(file);
        } else {
            printf("Failed to open file %s\\n", title);
        }
    }
""")

# 编译生成DLL
ffibuilder.compile()
