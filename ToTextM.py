import ctypes
import numpy as np
import os

# 加载DLL文件
dll_path = os.path.abspath('ToTextM32.dll')
if not os.path.exists(dll_path):
    raise FileNotFoundError(f"The DLL file was not found: {dll_path}")

totext_dll = ctypes.CDLL(dll_path)

# Define the ToText function argument types
totext_dll.ToText.argtypes = [
    ctypes.POINTER(ctypes.POINTER(ctypes.c_double)),  # double** lists
    ctypes.POINTER(ctypes.c_int),  # int* lengths
    ctypes.c_int,  # int num_columns
    ctypes.c_char_p,  # const char* title
    ctypes.c_char_p,  # const char* extra_info
    ctypes.POINTER(ctypes.c_char_p)  # const char** col_names
]

# Example data
list_a = np.array([1.0, 2.0, 3.0], dtype=np.float64)
list_b = np.array([4.0, 5.0, 6.0], dtype=np.float64)
list_c = np.array([7.0, 8.0, 9.0], dtype=np.float64)
lists = [list_a, list_b, list_c]
lengths = np.array([len(list_a), len(list_b), len(list_c)], dtype=np.int32)
col_names = b"Column A,Column B,Column C"

# Convert lists to ctypes format
list_pointers = (ctypes.POINTER(ctypes.c_double) * len(lists))(*[lst.ctypes.data_as(ctypes.POINTER(ctypes.c_double)) for lst in lists])
lengths_pointers = lengths.ctypes.data_as(ctypes.POINTER(ctypes.c_int))
col_names_pointers = (ctypes.c_char_p * len(col_names))(*col_names)

# Call the ToText function
totext_dll.ToText(
    list_pointers,
    lengths_pointers,
    len(lists),
    b"output.txt",  # title
    b"This is some extra info",  # extra_info
    col_names_pointers
)

print("Data has been written to output.txt")
