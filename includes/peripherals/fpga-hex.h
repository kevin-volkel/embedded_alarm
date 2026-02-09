#ifndef FGPA_HEX_H
#define FGPA_HEX_H

#include <stdint.h>

// Typedef
typedef struct {
    void *reg_addr;
    int initialized;
    int fd;
    uint32_t last_value;  // Store last written value for read-modify-write
} hex_handle_t;

// Init and Close
int init_hex(hex_handle_t *hex_handle);
int close_hex(hex_handle_t *hex_handle);

// Write
int hex_display_write(hex_handle_t *hex_handle, int unit, int value);
int hex_display_clear(hex_handle_t *hex_handle);

#endif /* FGPA_HEX_H */
