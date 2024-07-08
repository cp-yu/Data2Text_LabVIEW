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
lists = b"3.803274E+9\t3.803274E+9\t3.803274E+9\t3.803274E+9\t3.803274E+9\t3.803274E+9\t3.803274E+9\t3.803274E+9\t3.803274E+9\t3.803274E+9\t3.803274E+9\t3.803274E+9\t3.803274E+9\t3.803274E+9\t3.803274E+9\t3.803274E+9\t3.803274E+9\t3.803274E+9\t3.803274E+9\t3.803274E+9\t3.803274E+9\t3.803274E+9\t3.803274E+9\t3.803274E+9\t3.803274E+9\t3.803274E+9\t3.803274E+9\t3.803274E+9\t3.803274E+9\t3.803274E+9\t3.803274E+9\t3.803274E+9\t3.803274E+9\r\n-8.016943E-13\t-7.418393E-13\t-7.405401E-13\t-7.083177E-13\t-7.043121E-13\t-6.950616E-13\t-7.160665E-13\t-7.065891E-13\t-7.250070E-13\t-7.076623E-13\t-7.218597E-13\t-7.161618E-13\t-7.130623E-13\t-6.535650E-13\t-7.830024E-13\t-7.334828E-13\t-7.276655E-13\t-7.409811E-13\t-6.575465E-13\t-7.109644E-13\t-6.871223E-13\t-7.128239E-13\t-6.818416E-13\t-6.935834E-13\t-7.008671E-13\t-7.079125E-13\t-7.245302E-13\t-7.181288E-13\t-7.106901E-13\t-7.028340E-13\t-7.490039E-13\t-7.028819E-13\t-6.517767E-13\r\n3.256707E+1\t3.256995E+1\t3.271461E+1\t3.285892E+1\t3.313698E+1\t3.334632E+1\t3.352680E+1\t3.381716E+1\t3.403993E+1\t3.433186E+1\t3.448946E+1\t3.470993E+1\t3.496923E+1\t3.519013E+1\t3.543218E+1\t3.557368E+1\t3.568322E+1\t3.577915E+1\t3.581420E+1\t3.578295E+1\t3.574547E+1\t3.570677E+1\t3.566901E+1\t3.563084E+1\t3.559111E+1\t3.555000E+1\t3.550714E+1\t3.546751E+1\t3.542880E+1\t3.539066E+1\t3.535337E+1\t3.531456E+1\t3.529426E+1\r\n"
title_type = b"test"
extra_info = b"Extra information"
col_names = b"Time(s),Current(A),Temperatrue(C)"

# 调用函数
bmp_filename = dll.Tofile(lists, title_type, extra_info, col_names)

# 输出结果
if bmp_filename:
    print(f"BMP file created: {bmp_filename.decode('utf-8')}")
else:
    print("Failed to create BMP file")