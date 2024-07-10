import ctypes
import os

# 加载DLL文件
dll_path = os.path.abspath('all_functions32.dll')
if not os.path.exists(dll_path):
    raise FileNotFoundError(f"The DLL file was not found: {dll_path}")

convert = ctypes.CDLL(dll_path)

# 设置函数参数和返回类型
convert.nameShort2LongUnit.argtypes = [ctypes.c_char_p]
convert.nameShort2LongUnit.restype = ctypes.c_char_p

# 测试函数
def test_convert():
    test_cases = ["L", "C", "R", "Z", "Y", "X", "G", "B", "Q", "D", "Angle"]
    expected_outputs = [
        "Inductance (H)",
        "Capacitance (F)",
        "Resistance (Ω)",
        "Impedance (Ω)",
        "Admittance (S)",
        "Reactance (Ω)",
        "Conductance (S)",
        "Susceptance (S)",
        "Quality Factor",
        "Dissipation Factor",
        "Phase Angle (°)"
    ]
    
    for input_str, expected_output in zip(test_cases, expected_outputs):
        result = convert.nameShort2LongUnit(input_str.encode('utf-8')).decode('utf-8')
        print(f"Input: {input_str}, Output: {result}, Expected: {expected_output}")
        assert result == expected_output, f"Test failed for input {input_str}"

# 执行测试
if __name__ == "__main__":
    test_convert()
    print("All tests passed!")
