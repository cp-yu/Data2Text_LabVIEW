import ctypes
import os

# 加载DLL文件
dll_path = os.path.abspath('Tofile32.dll')
if not os.path.exists(dll_path):
    raise FileNotFoundError(f"The DLL file was not found: {dll_path}")

dll = ctypes.CDLL(dll_path)

# 定义函数参数和返回类型
dll.ToText.argtypes = [ctypes.c_char_p, ctypes.c_char_p, ctypes.c_char_p, ctypes.c_char_p]
dll.ToText.restype = ctypes.c_char_p

# 测试数据
lists = b"1.0,2.0,3.0\n4.0,5.0,6.0"
title_type = b"test_title"
extra_info = b"This is some extra information"
col_names = b"Column1,Column2,Column3"

# 调用DLL函数
bmp_filename = dll.ToText(lists, title_type, extra_info, col_names)

if bmp_filename:
    bmp_filename = bmp_filename.decode('utf-8')  # 将返回的字节字符串解码为普通字符串
    print(f"Generated BMP file name: {bmp_filename}")
else:
    print("Failed to generate the file.")

# 检查生成的文件
output_dir = "data"
if not os.path.exists(output_dir):
    print(f"Directory {output_dir} does not exist.")
else:
    files = os.listdir(output_dir)
    if not files:
        print(f"No files found in directory {output_dir}.")
    else:
        latest_file = max([os.path.join(output_dir, f) for f in files], key=os.path.getctime)
        print(f"Latest file created: {latest_file}")
        with open(latest_file, 'r') as f:
            content = f.read()
            print("File content:\n", content)
