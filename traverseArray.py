import ctypes
import os

# 加载DLL文件
dll_path = os.path.abspath('all_functions32.dll')
if not os.path.exists(dll_path):
    raise FileNotFoundError(f"The DLL file was not found: {dll_path}")

dll = ctypes.CDLL(dll_path)

# Define the function argument and return types
dll.traverse_array.argtypes = [ctypes.c_int, ctypes.c_int, ctypes.POINTER(ctypes.c_int), ctypes.POINTER(ctypes.c_int)]
dll.traverse_array.restype = ctypes.c_bool

def test_traverse(row_size, col_size):
    idx1 = ctypes.c_int(0)
    idx2 = ctypes.c_int(0)
    
    # Create a list to keep track of indices
    indices = []

    while not dll.traverse_array(row_size, col_size, ctypes.byref(idx1), ctypes.byref(idx2)):
        # Store the current indices
        indices.append((idx1.value, idx2.value))
        print(f"Current index: [{idx1.value}, {idx2.value}]")
    
    # Final state
    indices.append((idx1.value, idx2.value))
    print(f"Traversal completed at index: [{idx1.value}, {idx2.value}]")
    
    return indices

# Test the function with a 3x3 array
indices = test_traverse(3, 3)
print("All indices visited:", indices)
