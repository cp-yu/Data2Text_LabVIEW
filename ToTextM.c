#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// #include "helper.h"

__declspec(dllexport) void ToTextM(double* lists, int length, int num_columns, const char* title, const char* extra_info, const char* col_names) {
    FILE *file = fopen(title, "w");
    if (file) {
        // Write extra info
        fprintf(file, "%s\n", extra_info);
        fflush(file);  // Flush the file buffer to ensure data is written immediately
        printf("Wrote extra info: %s\n", extra_info);

        // Write column names
        char* col_names_copy = strdup(col_names);
        char* token = strtok(col_names_copy, ",");
        for (int i = 0; i < num_columns; i++) {
            if (token != NULL) {
                fprintf(file, "%s%s", token, (i == num_columns - 1) ? "\n" : "\t");
                token = strtok(NULL, ",");
            } else {
                fprintf(file, "Column%d%s", i + 1, (i == num_columns - 1) ? "\n" : "\t");
            }
            fflush(file);  // Flush the file buffer to ensure data is written immediately
            printf("Wrote column name: %s\n", token ? token : "NULL");
        }
        free(col_names_copy);

        // Write data rows
        for (int i = 0; i < length; i++) {
            for (int j = 0; j < num_columns; j++) {
                fprintf(file, "%f%s", lists[i + j * length], (j == num_columns - 1) ? "\n" : "\t");
            }
            fflush(file);  // Flush the file buffer to ensure data is written immediately
            printf("Wrote row %d\n", i);
        }
        fclose(file);
        printf("File %s closed\n", title);
    } else {
        printf("Failed to open file %s\n", title);
    }
}
