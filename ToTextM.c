#include <stdio.h>
#include <stdlib.h>
#include <string.h>

__declspec(dllexport) void ToText(double** lists, int* lengths, int num_columns, const char* title, const char* extra_info, const char* col_names) {
    FILE *file = fopen(title, "w");
    if (file) {
        fprintf(file, "%s\n", extra_info);

        // Write column names
                // Write column names
        char* col_names_copy = strdup(col_names);
        char* token = strtok(col_names_copy, ",");
        for (int i = 0; i < num_columns; i++) {
            if (token != NULL) {
                fprintf(file, "%s%s", token, (i == num_columns - 1) ? "\n" : "\t");
                token = strtok(NULL, ",");
            } else {
                fprintf(file, "Column%d%s", i+1, (i == num_columns - 1) ? "\n" : "\t");
            }
        }
        free(col_names_copy);


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