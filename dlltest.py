import ctypes

# 加载DLL文件
dll = ctypes.CDLL('./dlltest.dll')

# 定义函数原型
# void ToText(double* list_a, int len_a, double* list_b, int len_b, 
#             const char* title, const char* extra_info, const char* col_name_a, const char* col_name_b);
dll.ToText.argtypes = [
    ctypes.POINTER(ctypes.c_double), ctypes.c_int,
    ctypes.POINTER(ctypes.c_double), ctypes.c_int,
    ctypes.c_char_p, ctypes.c_char_p, ctypes.c_char_p, ctypes.c_char_p
]
dll.ToText.restype = None

# 创建测试数据
list_a = [1.1, 2.2, 3.3]
list_b = [4.4, 5.5, 6.6]
title = "test_output.txt"
extra_info = "Extra Information"
col_name_a = "Column A"
col_name_b = "Column B"

# 将Python列表转换为C类型数组
array_a = (ctypes.c_double * len(list_a))(*list_a)
array_b = (ctypes.c_double * len(list_b))(*list_b)

# 调用DLL函数
dll.ToText(
    array_a, len(list_a),
    array_b, len(list_b),
    title.encode('utf-8'), extra_info.encode('utf-8'), col_name_a.encode('utf-8'), col_name_b.encode('utf-8')
)

print(f"The function has been called. Check the output file: {title}")
