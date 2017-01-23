#include "std_utils.h"

void itoa(uint32_t val, char *c_str) {
    int i = 0;
    if(val == 0) {
        c_str[i++] = '0';
    }
    while(val) {
        c_str[i++] = '0' + (val % 10);
        val /= 10;
    }
    c_str[i] = '\0';  // Terminate
    // Reverse
    i --;
    for(int j = 0; j < i / 2 + 1; ++j) {
        char temp = c_str[j];
        c_str[j] = c_str[i-j];
        c_str[i-j] = temp;
    }
}
