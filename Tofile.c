#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <direct.h>  // For _mkdir on Windows

__declspec(dllexport) char* Tofile(char* lists, const char* title_type, const char* extra_info, const char* col_names) {
    // Create data directory if it does not exist
    _mkdir("data");

    // Get current time and format it
    time_t t = time(NULL);
    struct tm tm = *localtime(&t);
    char filename[256];
    snprintf(filename, sizeof(filename), "data/%s_%04d%02d%02d_%02d%02d%02d.txt", 
             title_type, tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday, 
             tm.tm_hour, tm.tm_min, tm.tm_sec);

    FILE *file = fopen(filename, "w");
    if (file) {
        // Write extra info
        fprintf(file, "%s\n", extra_info);
        fflush(file);  // Flush the file buffer to ensure data is written immediately
        printf("Wrote extra info: %s\n", extra_info);

        // Write column names
        char* col_names_copy = strdup(col_names);
        char* token = strtok(col_names_copy, ",");
        while (token != NULL) {
            fprintf(file, "%s\t", token);
            fflush(file);  // Flush the file buffer to ensure data is written immediately
            printf("Wrote column name: %s\n", token);
            token = strtok(NULL, ",");
        }
        fprintf(file, "\n");
        free(col_names_copy);

        // Write data with row and column swapping
        char* rows[100];  // Assuming max 100 rows
        int row_count = 0;
        
        // Split rows by newline
        char* lists_copy = strdup(lists);
        token = strtok(lists_copy, "\n");
        while (token != NULL) {
            rows[row_count++] = strdup(token);
            token = strtok(NULL, "\n");
        }

        // Tokenize each row and store columns
        char* data[100][100];  // Assuming max 100 rows and 100 columns
        int col_count = 0;

        for (int i = 0; i < row_count; i++) {
            int col_index = 0;
            token = strtok(rows[i], "\t");
            while (token != NULL) {
                data[i][col_index++] = strdup(token);
                token = strtok(NULL, "\t");
            }
            col_count = col_index > col_count ? col_index : col_count;
        }

        // Write data by swapping rows and columns
        for (int i = 0; i < col_count; i++) {
            for (int j = 0; j < row_count; j++) {
                fprintf(file, "%s\t", data[j][i]);
                fflush(file);  // Flush the file buffer to ensure data is written immediately
            }
            fprintf(file, "\n");
        }

        // Free allocated memory
        free(lists_copy);
        for (int i = 0; i < row_count; i++) {
            free(rows[i]);
        }

        fclose(file);
        printf("File %s closed\n", filename);
    } else {
        printf("Failed to open file %s\n", filename);
        return NULL;
    }

    // Change the file extension to .bmp
    static char bmp_filename[256];
    snprintf(bmp_filename, sizeof(bmp_filename), "data\\%s_%04d%02d%02d_%02d%02d%02d.bmp", 
             title_type, tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday, 
             tm.tm_hour, tm.tm_min, tm.tm_sec);

    return bmp_filename;
}