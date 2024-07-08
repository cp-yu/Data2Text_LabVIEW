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
        // printf("Wrote extra info: %s\n", extra_info);

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

        // Count rows and columns
        int row_count = 0;
        int col_count = 0;

        char* lists_copy = strdup(lists);
        char* temp = lists_copy;

        // Count rows
        while (*temp) {
            if (*temp == '\n') row_count++;
            temp++;
        }
        row_count++;  // For the last row

        // Count columns (assuming all rows have the same number of columns)
        temp = lists_copy;
        char* line = strtok(temp, "\r\n");
        while (line) {
            if (col_count == 0) {
                char* temp_line = strdup(line);
                char* col_token = strtok(temp_line, "\t");
                while (col_token) {
                    col_count++;
                    col_token = strtok(NULL, "\t");
                }
                free(temp_line);
            }
            line = strtok(NULL, "\r\n");
        }
        free(lists_copy);

        // Allocate memory for data array
        char*** data = (char***)malloc(row_count * sizeof(char**));
        for (int i = 0; i < row_count; i++) {
            data[i] = (char**)malloc(col_count * sizeof(char*));
        }

        // Split lists into data array
        lists_copy = strdup(lists);
        line = strtok(lists_copy, "\r\n");
        int row = 0;
        while (line) {
            int col = 0;
            char* col_token = strtok(line, "\t");
            while (col_token) {
                data[row][col] = strdup(col_token);
                col_token = strtok(NULL, "\t");
                col++;
            }
            line = strtok(NULL, "\r\n");
            row++;
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
            for (int j = 0; j < col_count; j++) {
                free(data[i][j]);
            }
            free(data[i]);
        }
        free(data);

        fclose(file);
        // printf("File %s closed\n", filename);
    } else {
        // printf("Failed to open file %s\n", filename);
        return NULL;
    }

    // Change the file extension to .bmp
    static char bmp_filename[256];
    snprintf(bmp_filename, sizeof(bmp_filename), "data\\%s_%04d%02d%02d_%02d%02d%02d.bmp", 
             title_type, tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday, 
             tm.tm_hour, tm.tm_min, tm.tm_sec);

    return bmp_filename;
}
