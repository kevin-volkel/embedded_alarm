#include <stdio.h>
#include <unistd.h>
#include <signal.h>
#include <stdlib.h>
#include <time.h>
#include <signal.h>

#include "../includes/peripherals/fpga-hex.h"
#include "../includes/peripherals/switch.h"
#include "../includes/peripherals/button.h"
#include "../includes/peripherals/lcd.h"


int main(void) {
    // Init hardware
    hex_handle_t hex_handle = {0};
    if (init_hex(&hex_handle) != 0) {
        fprintf(stderr, "main: init_hex failed\n");
        return 1;
    }

    // Display 12:34:56 on the 7-segment display.
    // Mapping: unit 5=hours tens, 4=hours ones, 3=min tens, 2=min ones, 1=sec tens, 0=sec ones
    hex_display_write(&hex_handle, 5, 1); // hours tens = 1
    hex_display_write(&hex_handle, 4, 2); // hours ones = 2
    hex_display_write(&hex_handle, 3, 3); // minutes tens = 3
    hex_display_write(&hex_handle, 2, 4); // minutes ones = 4
    hex_display_write(&hex_handle, 1, 5); // seconds tens = 5
    hex_display_write(&hex_handle, 0, 6); // seconds ones = 6

    // Keep the value displayed briefly for observation, then clean up.
    sleep(5);
    close_hex(&hex_handle);
    return 0;
}