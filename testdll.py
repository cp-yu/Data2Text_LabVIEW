import ctypes
import os
import platform
print(platform.architecture())

# DLL文件的完整路径
dll_path = "C:/Users/22327/Desktop/新建文件夹/builds/未命名项目 1/我的DLL2/SharedLib.dll"

# 确保DLL文件存在
if not os.path.exists(dll_path):
    raise FileNotFoundError(f"The DLL file was not found: {dll_path}")

# 加载DLL文件
my_dll = ctypes.CDLL(dll_path)

# 定义test函数的参数和返回类型
my_dll.test.argtypes = [ctypes.c_double, ctypes.c_double]
my_dll.test.restype = ctypes.c_double

# 调用test函数
result = my_dll.test(1.5, 2.5)

print(f"Result: {result}")
