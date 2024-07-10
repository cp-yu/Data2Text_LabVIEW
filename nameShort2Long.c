#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// 定义映射结构
typedef struct {
    const char* key;
    const char* value;
} Mapping;

// 定义映射表
Mapping mappingsUnit[] = {
    {"L", "Inductance (H)"},
    {"C", "Capacitance (F)"},
    {"R", "Resistance (Ω)"},
    {"Z", "Impedance (Ω)"},
    {"Y", "Admittance (S)"},
    {"X", "Reactance (Ω)"},
    {"G", "Conductance (S)"},
    {"B", "Susceptance (S)"},
    {"Q", "Quality Factor"},
    {"D", "Dissipation Factor"},
    {"Angle", "Phase Angle (°)"}
};
Mapping mappings[] = {
    {"L", "Inductance"},
    {"C", "Capacitance"},
    {"R", "Resistance"},
    {"Z", "Impedance"},
    {"Y", "Admittance"},
    {"X", "Reactance"},
    {"G", "Conductance"},
    {"B", "Susceptance"},
    {"Q", "Quality Factor"},
    {"D", "Dissipation Factor"},
    {"Angle", "Phase Angle"}
};

__declspec(dllexport) const char* nameShort2LongUnit(const char* input) {
    for (size_t i = 0; i < (sizeof(mappings) / sizeof(mappings[0])); ++i) {
        if (strcmp(input, mappingsUnit[i].key) == 0) {
            return mappings[i].value;
        }
    }
    return "Unknown Parameter";
}

__declspec(dllexport) const char* nameShort2Long(const char* input) {
    for (size_t i = 0; i < (sizeof(mappings) / sizeof(mappings[0])); ++i) {
        if (strcmp(input, mappings[i].key) == 0) {
            return mappings[i].value;
        }
    }
    return "Unknown Parameter";
}