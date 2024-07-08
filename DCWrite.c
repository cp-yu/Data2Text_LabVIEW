#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <direct.h>  // For _mkdir on Windows

__declspec(dllexport) char* DCWrite(const char* target_data, const char* temperature_data, const char* frequency_data, const char* real_temperatureData, const char* title_type, const char* extra_info, const char* col_names) {
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

        // Split temperature, real temperature and frequency data
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

        // Allocate memory for temperature, real temperature and frequency data
        char** temp_tokens = (char**)malloc(temp_count * sizeof(char*));
        char** real_temp_tokens = (char**)malloc(temp_count * freq_count * sizeof(char*));
        char** freq_tokens = (char**)malloc(freq_count * sizeof(char*));

        temp_data_copy = strdup(temperature_data);
        char* real_temp_data_copy = strdup(real_temperatureData);
        freq_data_copy = strdup(frequency_data);

        // Split temperature data into tokens and remove \r \n characters
        int i = 0;
        token = strtok(temp_data_copy, "\t");
        while (token != NULL) {
            size_t len = strlen(token);
            temp_tokens[i] = (char*)malloc((len + 1) * sizeof(char));
            strcpy(temp_tokens[i], token);
            // Remove any \r or \n characters
            temp_tokens[i][strcspn(temp_tokens[i], "\r\n")] = 0;
            i++;
            token = strtok(NULL, "\t");
        }

        // Split real temperature data into tokens and remove \r \n characters
        int idx = 0;
        token = strtok(real_temp_data_copy, "\t");
        while (token != NULL) {
            size_t len = strlen(token);
            real_temp_tokens[idx] = (char*)malloc((len + 1) * sizeof(char));
            strcpy(real_temp_tokens[idx], token);
            // Remove any \r or \n characters
            real_temp_tokens[idx][strcspn(real_temp_tokens[idx], "\r\n")] = 0;
            idx++;
            token = strtok(NULL, "\t");
        }

        // Fill remaining real_temp_tokens with NULL if there are not enough tokens
        for (int j = idx; j < temp_count * freq_count; j++) {
            real_temp_tokens[j] = NULL;
        }

        // Split frequency data into tokens and remove \r \n characters
        i = 0;
        token = strtok(freq_data_copy, "\t");
        while (token != NULL) {
            size_t len = strlen(token);
            freq_tokens[i] = (char*)malloc((len + 1) * sizeof(char));
            strcpy(freq_tokens[i], token);
            // Remove any \r or \n characters
            freq_tokens[i][strcspn(freq_tokens[i], "\r\n")] = 0;
            i++;
            token = strtok(NULL, "\t");
        }

        // Split target data into sections using ",\s0,\s0]" as delimiter
        char* target_data_copy = strdup(target_data);
        char* sections[3] = {0};
        sections[0] = strtok(target_data_copy, ",\\s0,\\s0]");
        sections[1] = strtok(NULL, ",\\s0,\\s0]");
        sections[2] = strtok(NULL, ",\\s0,\\s0]");

        // Skip the first section which is useless
        char* target1_data = sections[1];
        char* target2_data = sections[2];

        // Write first section
        fprintf(file, "[%s]\n", col_name_1);
        fprintf(file, "Temperature(℃)\tReal Temperature(℃)\tFrequency(Hz)\t%s\n", col_name_1);

        char* line = strtok(target1_data, "\r\n");
        idx = 0; // Reset idx for writing real temperatures
        for (int i = 0; i < temp_count; i++) {
            for (int j = 0; j < freq_count; j++) {
                if (line) {
                    char* value = strtok(line, "\t");
                    for (int k = 0; k < j; k++) {
                        value = strtok(NULL, "\t");
                    }
                    if (value) {
                        fprintf(file, "%s\t%s\t%s\t%s\n", temp_tokens[i], real_temp_tokens[idx] ? real_temp_tokens[idx] : "NULL", freq_tokens[j], value);
                    } else {
                        fprintf(file, "%s\t%s\t%s\t%s\n", temp_tokens[i], real_temp_tokens[idx] ? real_temp_tokens[idx] : "NULL", freq_tokens[j], "0.000000E+0");
                    }
                } else {
                    fprintf(file, "%s\t%s\t%s\t%s\n", temp_tokens[i], real_temp_tokens[idx] ? real_temp_tokens[idx] : "NULL", freq_tokens[j], "0.000000E+0");
                }
                idx++;
            }
            line = strtok(NULL, "\r\n");
        }

        // Write second section
        fprintf(file, "[%s]\n", col_name_2);
        fprintf(file, "Temperature(℃)\tReal Temperature(℃)\tFrequency(Hz)\t%s\n", col_name_2);

        line = strtok(target2_data, "\r\n");
        idx = 0; // Reset idx for writing real temperatures
        for (int i = 0; i < temp_count; i++) {
            for (int j = 0; j < freq_count; j++) {
                if (line) {
                    char* value = strtok(line, "\t");
                    for (int k = 0; k < j; k++) {
                        value = strtok(NULL, "\t");
                    }
                    if (value) {
                        fprintf(file, "%s\t%s\t%s\t%s\n", temp_tokens[i], real_temp_tokens[idx] ? real_temp_tokens[idx] : "NULL", freq_tokens[j], value);
                    } else {
                        fprintf(file, "%s\t%s\t%s\t%s\n", temp_tokens[i], real_temp_tokens[idx] ? real_temp_tokens[idx] : "NULL", freq_tokens[j], "0.000000E+0");
                    }
                } else {
                    fprintf(file, "%s\t%s\t%s\t%s\n", temp_tokens[i], real_temp_tokens[idx] ? real_temp_tokens[idx] : "NULL", freq_tokens[j], "0.000000E+0");
                }
                idx++;
            }
            line = strtok(NULL, "\r\n");
        }

        // Free allocated memory
        free(target_data_copy);
        for (int i = 0; i < temp_count; i++) {
            free(temp_tokens[i]);
        }
        for (int i = 0; i < temp_count * freq_count; i++) {
            if (real_temp_tokens[i] != NULL) {
                free(real_temp_tokens[i]);
            }
        }
        for (int i = 0; i < freq_count; i++) {
            free(freq_tokens[i]);
        }
        free(temp_tokens);
        free(real_temp_tokens);
        free(freq_tokens);
        if (col_name_1) free(col_name_1);
        if (col_name_2) free(col_name_2);
        free(temp_data_copy);
        free(real_temp_data_copy);
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
