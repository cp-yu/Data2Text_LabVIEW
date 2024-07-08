import ctypes
import os

# 加载DLL
dll_path = os.path.abspath('all_functions32.dll')
if not os.path.exists(dll_path):
    raise FileNotFoundError(f"The DLL file was not found: {dll_path}")

step_dll = ctypes.CDLL(dll_path)

# 定义step函数参数和返回类型
step_dll.step.argtypes = [ctypes.c_double, ctypes.c_double, ctypes.c_double, 
                          ctypes.POINTER(ctypes.c_double), ctypes.c_int]
step_dll.step.restype = None

# 测试数据
start = 0.0
step_size = 0.3
end = 2.5
length = 10
array_type = ctypes.c_double * length
array = array_type()

# 调用step函数
step_dll.step(ctypes.c_double(start), ctypes.c_double(step_size), 
              ctypes.c_double(end), array, ctypes.c_int(length))

# 打印结果
print("Generated array:")
for i in range(length):
    print(array[i])