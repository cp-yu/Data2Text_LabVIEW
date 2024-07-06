#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <direct.h>  // For _mkdir on Windows

__declspec(dllexport) char* DCWrite(const char* target_data, const char* temperature_data, const char* frequency_data, const char* title_type, const char* extra_info, const char* col_names) {
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
        char* col_token = strtok(col_names_copy, ",");
        char* col_name_1 = col_token ? strdup(col_token) : NULL;
        col_token = strtok(NULL, ",");
        char* col_name_2 = col_token ? strdup(col_token) : NULL;
        free(col_names_copy);

        // Split temperature and frequency data
        int temp_count = 0;
        int freq_count = 0;

        char* temp_data_copy = strdup(temperature_data);
        char* freq_data_copy = strdup(frequency_data);

        // Count temperature tokens
        char* token = strtok(temp_data_copy, "\t");
        while (token != NULL) {
            temp_count++;
            token = strtok(NULL, "\t");
        }

        // Count frequency tokens
        token = strtok(freq_data_copy, "\t");
        while (token != NULL) {
            freq_count++;
            token = strtok(NULL, "\t");
        }

        free(temp_data_copy);
        free(freq_data_copy);

        // Allocate memory for temperature and frequency data
        char** temp_tokens = (char**)malloc(temp_count * sizeof(char*));
        char** freq_tokens = (char**)malloc(freq_count * sizeof(char*));

        temp_data_copy = strdup(temperature_data);
        freq_data_copy = strdup(frequency_data);

        // Split temperature data into tokens
        int i = 0;
        token = strtok(temp_data_copy, "\t");
        while (token != NULL) {
            temp_tokens[i++] = strdup(token);
            token = strtok(NULL, "\t");
        }

        // Split frequency data into tokens
        i = 0;
        token = strtok(freq_data_copy, "\t");
        while (token != NULL) {
            freq_tokens[i++] = strdup(token);
            token = strtok(NULL, "\t");
        }

        // Split target data into sections
        char* target_data_copy = strdup(target_data);
        char* section = strtok(target_data_copy, "\n");

        // First section
        fprintf(file, "[%s]\n", col_name_1);
        fprintf(file, "Temperature(℃)\tFrequency(Hz)\t%s\n", col_name_1);

        while (section != NULL && strncmp(section, "[", 1) != 0) {
            char* line = strdup(section);
            char* value = strtok(line, "\t");
            for (int i = 0; i < temp_count; i++) {
                for (int j = 0; j < freq_count; j++) {
                    fprintf(file, "%s\t%s\t%s\n", temp_tokens[i], freq_tokens[j], value);
                    value = strtok(NULL, "\t");
                }
            }
            free(line);
            section = strtok(NULL, "\n");
        }

        // Second section
        fprintf(file, "[%s]\n", col_name_2);
        fprintf(file, "Temperature(℃)\tFrequency(Hz)\t%s\n", col_name_2);

        section = strtok(NULL, "\n");
        while (section != NULL && strncmp(section, "[", 1) != 0) {
            char* line = strdup(section);
            char* value = strtok(line, "\t");
            for (int i = 0; i < temp_count; i++) {
                for (int j = 0; j < freq_count; j++) {
                    fprintf(file, "%s\t%s\t%s\n", temp_tokens[i], freq_tokens[j], value);
                    value = strtok(NULL, "\t");
                }
            }
            free(line);
            section = strtok(NULL, "\n");
        }

        // Free allocated memory
        free(target_data_copy);
        for (int i = 0; i < temp_count; i++) {
            free(temp_tokens[i]);
        }
        for (int i = 0; i < freq_count; i++) {
            free(freq_tokens[i]);
        }
        free(temp_tokens);
        free(freq_tokens);
        if (col_name_1) free(col_name_1);
        if (col_name_2) free(col_name_2);
        free(temp_data_copy);
        free(freq_data_copy);

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

// Example usage
int main() {
    char target_data[] = "[0, 0, 0]\n"
                         "0.000000E+0\t1.000000E+0\t2.000000E+0\t3.000000E+0\t0.000000E+0\n"
                         "4.000000E+0\t5.000000E+0\t6.000000E+0\t7.000000E+0\t0.000000E+0\n"
                         "8.000000E+0\t9.000000E+0\t1.000000E+1\t1.100000E+1\t0.000000E+0\n"
                         "1.200000E+1\t1.300000E+1\t1.400000E+1\t1.500000E+1\t0.000000E+0\n"
                         "[1, 0, 0]\n"
                         "0.000000E+0\t0.000000E+0\t0.000000E+0\t0.000000E+0\t0.000000E+0\n"
                         "0.000000E+0\t0.000000E+0\t0.000000E+0\t0.000000E+0\t0.000000E+0\n"
                         "0.000000E+0\t0.000000E+0\t0.000000E+0\t0.000000E+0\t0.000000E+0\n"
                         "0.000000E+0\t0.000000E+0\t0.000000E+0\t0.000000E+0\t1.000000E+0";
    char temperature_data[] = "0.000000E+0\t1.000000E+0\t2.000000E+0\t3.000000E+0";
    char frequency_data[] = "0.000000E+0\t1.000000E+0\t2.000000E+0\t3.000000E+0\t0.000000E+0";
    const char* title_type = "test";
    const char* extra_info = "Extra information";
    const char* col_names = "Resistance,Inductance";

    char* bmp_filename = DCWrite(target_data, temperature_data, frequency_data, title_type, extra_info, col_names);
    if (bmp_filename != NULL) {
        printf("BMP file created: %s\n", bmp_filename);
    } else {
        printf("Failed to create BMP file\n");
    }

    return 0;
}