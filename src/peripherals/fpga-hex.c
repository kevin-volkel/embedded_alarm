#include "../../includes/peripherals/fpga-hex.h"
#include "../../includes/hal/hal-api.h"
#include <stdio.h>
#include <stdint.h>
#include "../../lib/address_map_arm.h"

static hal_map_t hex_map;

// Init and Close
int init_hex(hex_handle_t *hex_handle) {
    if (!hex_handle) return -1;

    /* Open HAL mapping once for both left/right */
    if (!hex_handle->initialized) {
        if (hal_open(&hex_map) != 0) {
            fprintf(stderr, "init_hex: hal_open failed\n");
            return -1;
        }
    }

    /* Get virtual address for JP1 register block */
    void *addr = hal_get_virtual_addr(&hex_map, JP1_BASE);
    if (!addr) {
        fprintf(stderr, "init_hex: hal_get_virtual_addr failed, JP1_BASE=0x%x\n", JP1_BASE);
        return -1;
    }


    hex_handle->reg_addr = addr;
    hex_handle->initialized = 1;

    /* Configure GPIO pins as outputs: set direction register (offset +1) */
    volatile uint32_t *jp1_reg = (volatile uint32_t *)addr;
    volatile uint32_t *jp1_direction = (volatile uint32_t *)((char *)addr + 4);  // offset +1 word = +4 bytes
    
    /* Set GPIO[23:0] as outputs (0xFFFFFF = 24 pins for 3 units of 8 bits each) */
    *jp1_direction = 0x00FFFFFF;
    /* GPIO[23:0] configured as outputs (unit 0: bits[7:0], unit 1: bits[15:8], unit 2: bits[23:16]) */

    return 0;
}

int close_hex(hex_handle_t *hex_handle) {
    if (!hex_handle || !hex_handle->initialized) return -1;

    hex_handle->reg_addr = NULL;
    hex_handle->initialized = 0;

    /* Close the shared HAL mapping for this handle */
    if (hal_close(&hex_map) != 0) {
        fprintf(stderr, "close_hex: hal_close failed\n");
        return -1;
    }

    return 0;
}

// Write
/* Write time value to 7-segment display
 * unit: 0 = seconds, 1 = minutes, 2 = hours
 * value: time value in range 0-59 (seconds/minutes) or 0-23 (hours)
 */
/* Write a single digit (4 bits) to the 7-segment set driven by the FPGA.
 * Digit/unit mapping (unit is digit index):
 *  0 = seconds ones      -> bits [3:0]
 *  1 = seconds tens      -> bits [7:4]
 *  2 = minutes ones      -> bits [11:8]
 *  3 = minutes tens      -> bits [15:12]
 *  4 = hours ones        -> bits [19:16]
 *  5 = hours tens        -> bits [23:20]
 *
 * value: the numeric digit to display (0-9 for most, tens fields limited)
 */
int hex_display_write(hex_handle_t *hex_handle, int unit, int value) {
    if (!hex_handle || !hex_handle->initialized || !hex_handle->reg_addr) {
        fprintf(stderr, "hex_display_write: invalid handle\n");
        return -1;
    }

    if (unit < 0 || unit > 5) {
        fprintf(stderr, "hex_display_write: invalid unit (0-5)\n");
        return -1;
    }

    /* Per-digit validation:
     * - ones digits (units 0,2,4): 0-9
     * - tens digits for seconds/minutes (units 1,3): 0-5
     * - hours tens (unit 5): 0-2
     * Note: combined-hour-range validation (e.g., 24-hour max) requires
     * reading the other hour digit and is left to higher-level logic.
     */
    switch (unit) {
        case 0: /* seconds ones */
        case 2: /* minutes ones */
        case 4: /* hours ones */
            if (value < 0 || value > 9) {
                fprintf(stderr, "hex_display_write: invalid digit value (0-9) for unit %d\n", unit);
                return -1;
            }
            break;
        case 1: /* seconds tens */
        case 3: /* minutes tens */
            if (value < 0 || value > 5) {
                fprintf(stderr, "hex_display_write: invalid tens value (0-5) for unit %d\n", unit);
                return -1;
            }
            break;
        case 5: /* hours tens */
            if (value < 0 || value > 2) {
                fprintf(stderr, "hex_display_write: invalid hour-ten value (0-2) for unit %d\n", unit);
                return -1;
            }
            break;
        default:
            break;
    }

    // Cast void pointer to a volatile 32-bit integer pointer
    volatile uint32_t *jp1_reg = (volatile uint32_t *)hex_handle->reg_addr;

    // READ: Get current register value to preserve other digits
    uint32_t current_val = *jp1_reg;

    // Calculate bit offsets based on unit (4 bits per digit)
    int bit_offset = unit * 4;
    uint32_t mask = (0xFu << bit_offset);

    // Clear the bits for this digit and write the new 4-bit value
    current_val &= ~mask;
    current_val |= ((uint32_t)(value & 0xFu) << bit_offset);

    *jp1_reg = current_val;

    return 0;
}

int hex_display_clear(hex_handle_t *hex_handle){
    /* Write 0xF (all segments off/blank) to each of the 6 digits */
    for (int unit = 0; unit < 6; ++unit) {
        hex_display_write(hex_handle, unit, 0xF);
    }
    return 1;
}