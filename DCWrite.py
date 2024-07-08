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
target_data = b"[0, 0, 0]\r\n" \
              b"0.000000E+0\t1.000000E+0\t2.000000E+0\t3.000000E+0\t0.000000E+0\r\n" \
              b"4.000000E+0\t5.000000E+0\t6.000000E+0\t7.000000E+0\t0.000000E+0\r\n" \
              b"8.000000E+0\t9.000000E+0\t1.000000E+1\t1.100000E+1\t0.000000E+0\r\n" \
              b"1.200000E+1\t1.300000E+1\t1.400000E+1\t1.500000E+1\t0.000000E+0\r\n" \
              b"\r\n[1, 0, 0]\r\n" \
              b"0.000000E+0\t0.000000E+0\t0.000000E+0\t0.000000E+0\t0.000000E+0\r\n" \
              b"0.000000E+0\t0.000000E+0\t0.000000E+0\t0.000000E+0\t0.000000E+0\r\n" \
              b"0.000000E+0\t0.000000E+0\t0.000000E+0\t0.000000E+0\t0.000000E+0\r\n" \
              b"0.000000E+0\t0.000000E+0\t0.000000E+0\t0.000000E+0\t1.000000E+0\r\n"

temperature_data = b"0.000000E+0\t1.000000E+0\t2.000000E+0\t3.000000E+0"
real_temperature_data = b"0.500000E+0\t1.500000E+0\t2.500000E+0\t3.500000E+0\t" \
                        b"0.600000E+0\t1.600000E+0\t2.600000E+0\t3.600000E+0\t" \
                        b"0.700000E+0\t1.700000E+0\t2.700000E+0\t3.700000E+0\t" \
                        b"0.800000E+0\t1.800000E+0\t2.800000E+0\t3.800000E+0\t" #\
                        # b"0.900000E+0\t1.900000E+0\t2.900000E+0\t3.900000E+0"
frequency_data = b"0.000000E+0\t1.000000E+0\t2.000000E+0\t3.000000E+0\t0.000000E+0"
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
