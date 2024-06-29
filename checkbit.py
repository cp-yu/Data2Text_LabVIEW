import pefile

def check_dll_architecture(file_path):
    pe = pefile.PE(file_path)
    if pe.FILE_HEADER.Machine == 0x014c:
        return "x86 (32-bit)"
    elif pe.FILE_HEADER.Machine == 0x8664:
        return "x64 (64-bit)"
    else:
        return "Unknown architecture"

file_path = "ToText.dll"
print(check_dll_architecture(file_path))
