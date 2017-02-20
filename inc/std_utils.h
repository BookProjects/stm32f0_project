#ifndef __STD_UTILS_H
#define __STD_UTILS_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

/* Get the string value of a uint32_t.
 * Required: c_str must be able to fit the resulting value.
 */
void itoa(uint32_t val, char *c_str);

#ifdef __cplusplus
}
#endif

#endif  // __STD_UTILS_H
