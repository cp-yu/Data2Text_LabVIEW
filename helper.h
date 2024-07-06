
#ifndef HELPER_H
#define HELPER_H

#ifdef __cplusplus
extern "C" {
#endif

__declspec(dllexport) char* Tofile(char* lists, const char* title_type, const char* extra_info, const char* col_names);
__declspec(dllexport) void ToText(double* list_a, int len_a, double* list_b, int len_b, 
                                  const char* title, const char* extra_info, const char* col_name_a, const char* col_name_b);
__declspec(dllexport) void ToTextM(double* lists, int length, int num_columns, const char* title, const char* extra_info, const char* col_names);

#ifdef __cplusplus
}
#endif

#endif // EXAMPLE_H
