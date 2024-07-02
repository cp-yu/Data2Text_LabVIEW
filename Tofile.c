#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <direct.h>  // For _mkdir on Windows

__declspec(dllexport) char* ToText(char* lists, const char* title_type, const char* extra_info, const char* col_names) {
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

        // Write data
        char* lists_copy = strdup(lists);
        token = strtok(lists_copy, ",");
        while (token != NULL) {
            fprintf(file, "%s\t", token);
            fflush(file);  // Flush the file buffer to ensure data is written immediately
            printf("Wrote data: %s\n", token);
            token = strtok(NULL, ",");
        }
        fprintf(file, "\n");
        free(lists_copy);

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
