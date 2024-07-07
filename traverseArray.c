#include <stdbool.h>



__declspec(dllexport) bool traverse_array(int row_size, int col_size, int* idx1, int* idx2) {
    // If indices are already at the end, return true
    if (*idx1 >= row_size || *idx2 >= col_size) {
        return true;
    }

    // Update indices
    (*idx2)++;
    if (*idx2 >= col_size) {
        *idx2 = 0;
        (*idx1)++;
    }

    // Check if we have reached the end
    if (*idx1 >= row_size) {
        return true;
    }

    return false;
}
