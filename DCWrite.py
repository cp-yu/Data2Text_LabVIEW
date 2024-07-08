import ctypes
import os

# 加载DLL
dll_path = os.path.abspath('all_functions32.dll')
if not os.path.exists(dll_path):
    raise FileNotFoundError(f"The DLL file was not found: {dll_path}")

dcwrite_dll = ctypes.CDLL(dll_path)

# 定义函数参数和返回类型
dcwrite_dll.DCWrite.restype = ctypes.c_char_p
dcwrite_dll.DCWrite.argtypes = [
    ctypes.c_char_p,  # target_data
    ctypes.c_char_p,  # temperature_data
    ctypes.c_char_p,  # frequency_data
    ctypes.c_char_p,  # real_temperatureData
    ctypes.c_char_p,  # title_type
    ctypes.c_char_p,  # extra_info
    ctypes.c_char_p   # col_names
]

# 测试数据
target_data = b"[0,\s0,\s0]\r\n1.000296E+2\t1.000159E+2\t1.000289E+2\r\n\r\n[1,\s0,\s0]\r\n-5.099601E+3\t-1.838699E+3\t-1.414158E+3\r\n\r\n"

temperature_data = b"1.000000E+2\r\n"
real_temperature_data = b"0.000000E+0\t0.000000E+0\t0.000000E+0\r\n"
frequency_data = b"2.000000E+1\t7.000000E+1\t1.000000E+2\r\n"
title_type = b"test"
extra_info = b"Extra information"
col_names = b"Resistance,Inductance"

# 调用函数
bmp_filename = dcwrite_dll.DCWrite(
    target_data, 
    temperature_data, 
    frequency_data, 
    real_temperature_data,  # 新增参数
    title_type, 
    extra_info, 
    col_names
)

# 输出结果
if bmp_filename:
    print(f"BMP file created: {bmp_filename.decode('utf-8')}")
else:
    print("Failed to create BMP file")
