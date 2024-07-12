import ctypes
import os

# 加载DLL
dll_path = os.path.abspath('all_functions32.dll')
if not os.path.exists(dll_path):
    raise FileNotFoundError(f"The DLL file was not found: {dll_path}")

dll = ctypes.CDLL(dll_path)

# 定义函数参数和返回类型
dll.append_string_to_file.argtypes = [ctypes.c_char_p, ctypes.c_char_p]
dll.append_string_to_file.restype = ctypes.c_int

# 测试函数
def test_append_string_to_file():
    test_file = './test_file.sdf'
    test_string = 'This is a test string.'

    # 确保测试文件存在
    if not os.path.exists(test_file):
        with open(test_file, 'w') as f:
            f.write('Original content.')

    # 调用DLL函数
    result = dll.append_string_to_file(test_string.encode('utf-8'), test_file.encode('utf-8'))

    # 检查结果
    if result == 0:
        print('String appended successfully.')
    else:
        print(f'Error appending string. Error code: {result}')

    # 打印文件内容
    with open(test_file, 'r') as f:
        content = f.read()
        print('File content:')
        print(content)

# 运行测试
test_append_string_to_file()
