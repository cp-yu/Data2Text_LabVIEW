import ctypes
import os

# 加载DLL文件
dll_path = os.path.abspath('all_functions32.dll')
# dll_path = os.path.abspath('all_functions32.dll')
if not os.path.exists(dll_path):
    raise FileNotFoundError(f"The DLL file was not found: {dll_path}")

dcstatue = ctypes.CDLL(dll_path)

# 设置函数返回类型和参数类型
dcstatue.DCStatueBit.restype = ctypes.c_bool
dcstatue.DCStatueBit.argtypes = [ctypes.c_uint64, ctypes.c_int]

# 调用函数并测试
status = 0b1010  # 二进制表示的status值
heaterSetpoint = 0

# 调用DCStatueBit函数
result = dcstatue.DCStatueBit(status, heaterSetpoint)

# 输出结果
print(f"DCStatueBit({status}, {heaterSetpoint}) = {result}")
