import ctypes
import os

# 加载DLL文件
dll_path = os.path.abspath('all_functions32.dll')
if not os.path.exists(dll_path):
    raise FileNotFoundError(f"The DLL file was not found: {dll_path}")

dll = ctypes.CDLL(dll_path)

# Tofile函数
Tofile = dll.Tofile
Tofile.argtypes = [ctypes.c_char_p, ctypes.c_char_p, ctypes.c_char_p, ctypes.c_char_p]
Tofile.restype = ctypes.c_char_p

# 测试Tofile函数
lists = b"1,2,3,4,5"
title_type = b"test_title"
extra_info = b"extra information"
col_names = b"col1,col2,col3,col4,col5"

result = Tofile(lists, title_type, extra_info, col_names)
print(f"Tofile function result: {result.decode('utf-8')}")

# ToText函数
ToText = dll.ToText
ToText.argtypes = [ctypes.POINTER(ctypes.c_double), ctypes.c_int, ctypes.POINTER(ctypes.c_double), ctypes.c_int, ctypes.c_char_p, ctypes.c_char_p, ctypes.c_char_p, ctypes.c_char_p]
ToText.restype = None

# 测试ToText函数
list_a = (ctypes.c_double * 5)(1.1, 2.2, 3.3, 4.4, 5.5)
len_a = 5
list_b = (ctypes.c_double * 5)(5.5, 4.4, 3.3, 2.2, 1.1)
len_b = 5
title = b"output.txt"
extra_info = b"Extra information"
col_name_a = b"Column A"
col_name_b = b"Column B"

ToText(list_a, len_a, list_b, len_b, title, extra_info, col_name_a, col_name_b)
print(f"ToText function executed, output file: {title.decode('utf-8')}")

# ToTextM函数
ToTextM = dll.ToTextM
ToTextM.argtypes = [ctypes.POINTER(ctypes.c_double), ctypes.c_int, ctypes.c_int, ctypes.c_char_p, ctypes.c_char_p, ctypes.c_char_p]
ToTextM.restype = None

# 测试ToTextM函数
lists = (ctypes.c_double * 15)(1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9, 10.0, 11.1, 12.2, 13.3, 14.4, 15.5)
length = 5
num_columns = 3
title = b"outputM.txt"
extra_info = b"Extra information for ToTextM"
col_names = b"Column1,Column2,Column3"

ToTextM(lists, length, num_columns, title, extra_info, col_names)
print(f"ToTextM function executed, output file: {title.decode('utf-8')}")
