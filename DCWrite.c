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

        // Split target data into sections
        char* target_data_copy = strdup(target_data);
        char* delimiter = "\r\n\r\n";
        char* sections[2] = {0};

        char* pos = strstr(target_data_copy, delimiter);
        if (pos) {
            *pos = '\0'; // Terminate the first section
            sections[0] = target_data_copy;
            sections[1] = pos + strlen(delimiter);
        } else {
            sections[0] = target_data_copy;
            sections[1] = NULL;
        }

        // Function to split a section into lines and store in an array
        char** split_section(const char* section, int* line_count) {
            char* section_copy = strdup(section);
            *line_count = 0;

            // Count lines
            char* line = strtok(section_copy, "\r\n");
            while (line) {
                (*line_count)++;
                line = strtok(NULL, "\r\n");
            }

            free(section_copy);

            // Allocate memory for lines
            char** lines = (char**)malloc(*line_count * sizeof(char*));
            section_copy = strdup(section);
            line = strtok(section_copy, "\r\n");
            int index = 0;
            while (line) {
                lines[index] = strdup(line);
                index++;
                line = strtok(NULL, "\r\n");
            }

            free(section_copy);
            return lines;
        }

        int line_count_1, line_count_2;
        char** lines_1 = split_section(sections[0], &line_count_1);
        char** lines_2 = split_section(sections[1], &line_count_2);

        // First section
        fprintf(file, "[%s]\n", col_name_1);
        fprintf(file, "Temperature(¡æ)\tReal Temperature(¡æ)\tFrequency(Hz)\t%s\n", col_name_1);

        idx = 0; // Reset idx for writing real temperatures
        for (int i = 1; i < line_count_1; i++) { // Start from 1 to skip the header
            char* line = lines_1[i];
            char* value = strtok(line, "\t");
            for (int j = 0; j < freq_count; j++) {
                if (value) {
                    fprintf(file, "%s\t%s\t%s\t%s\n", temp_tokens[i - 1], real_temp_tokens[idx] ? real_temp_tokens[idx] : "NULL", freq_tokens[j], value);
                    value = strtok(NULL, "\t");
                } else {
                    fprintf(file, "%s\t%s\t%s\t%s\n", temp_tokens[i - 1], real_temp_tokens[idx] ? real_temp_tokens[idx] : "NULL", freq_tokens[j], "None");
                }
                idx++;
            }
        }

        // Second section
        fprintf(file, "[%s]\n", col_name_2);
        fprintf(file, "Temperature(¡æ)\tReal Temperature(¡æ)\tFrequency(Hz)\t%s\n", col_name_2);

        idx = 0; // Reset idx for writing real temperatures
        for (int i = 1; i < line_count_2; i++) { // Start from 1 to skip the header
            char* line = lines_2[i];
            char* value = strtok(line, "\t");
            for (int j = 0; j < freq_count; j++) {
                if (value) {
                    fprintf(file, "%s\t%s\t%s\t%s\n", temp_tokens[i - 1], real_temp_tokens[idx] ? real_temp_tokens[idx] : "NULL", freq_tokens[j], value);
                    value = strtok(NULL, "\t");
                } else {
                    fprintf(file, "%s\t%s\t%s\t%s\n", temp_tokens[i - 1], real_temp_tokens[idx] ? real_temp_tokens[idx] : "NULL", freq_tokens[j], "None");
                }
                idx++;
            }
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

        // Free line arrays
        for (int i = 0; i < line_count_1; i++) {
            free(lines_1[i]);
        }
        free(lines_1);
        for (int i = 0; i < line_count_2; i++) {
            free(lines_2[i]);
        }
        free(lines_2);

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
