#include <stdio.h>
#include <stdlib.h>
#include <string.h>

__declspec(dllexport) void ToText(double** lists, int* lengths, int num_columns, const char* title, const char* extra_info, const char** col_names) {
    FILE *file = fopen(title, "w");
    if (file) {
        fprintf(file, "%s\n", extra_info);

        // Write column names
        for (int i = 0; i < num_columns; i++) {
            fprintf(file, "%s%s", col_names[i], (i == num_columns - 1) ? "\n" : "\t");
        }

        // Find the minimum length among all columns
        int min_len = lengths[0];
        for (int i = 1; i < num_columns; i++) {
            if (lengths[i] < min_len) {
                min_len = lengths[i];
            }
        }

        // Write data rows
        for (int i = 0; i < min_len; i++) {
            for (int j = 0; j < num_columns; j++) {
                fprintf(file, "%f%s", lists[j][i], (j == num_columns - 1) ? "\n" : "\t");
            }
        }
        fclose(file);
    } else {
        printf("Failed to open file %s\n", title);
    }
}