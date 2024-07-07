#include <stdint.h>
#include <stdbool.h>

__declspec(dllexport) bool DCStatueBit(uint64_t status, int heaterSetpoint) {
    return (status & ((uint64_t)1 << heaterSetpoint)) != 0;
}