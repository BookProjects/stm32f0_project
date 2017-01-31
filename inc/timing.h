#include <stdint.h>

/* Wait for however many ticks are specified.
 *
 */
void timing_delay(uint32_t ticks);

/* Bind to SysTickHandler in interrupt configuration
 *
 */
void timing_systick_handler();

/* Configure the duration of a tick. By defining the number that can occur
 * within a second.
 *
 * Warning: This uses integer division, so it won't be exact unless it evenly
 * divides into the clock frequency, which defaults to 48MHz.
 */
void timing_configure_systick(uint32_t num_per_sec);

/* Configure an input capture timer.
 *
 *
 */
void timing_configure_input_capture();

void timing_get_capture_val(uint32_t *val);
