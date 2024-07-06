import ctypes
import os

# 加载DLL文件
dll_path = os.path.abspath('Tofile32.dll')
if not os.path.exists(dll_path):
    raise FileNotFoundError(f"The DLL file was not found: {dll_path}")

dll = ctypes.CDLL(dll_path)

# 定义函数参数和返回类型
dll.Tofile.restype = ctypes.c_char_p
dll.Tofile.argtypes = [ctypes.c_char_p, ctypes.c_char_p, ctypes.c_char_p, ctypes.c_char_p]

# 测试数据
lists = b"0.000000E+0\t0.000000E+0\t0.000000E+0\t0.000000E+0\t-1.000000E+0\n" \
        b"0.000000E+0\t0.000000E+0\t0.000000E+0\t0.000000E+0\t1.000000E+0\n" \
        b"0.000000E+0\t0.000000E+0\t0.000000E+0\t0.000000E+0\t3.000000E+0"
title_type = b"test"
extra_info = b"Extra information"
col_names = b"Column1,Column2,Column3"

# 调用函数
bmp_filename = dll.Tofile(lists, title_type, extra_info, col_names)

# 输出结果
if bmp_filename:
    print(f"BMP file created: {bmp_filename.decode('utf-8')}")
else:
    print("Failed to create BMP file")