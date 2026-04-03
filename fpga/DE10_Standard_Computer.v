module DE10_Standard_Computer (
    // Clock
    input               CLOCK_50,

    // Seven Segment Displays
    output      [ 6: 0] HEX0,
    output      [ 6: 0] HEX1,
    output      [ 6: 0] HEX2,
    output      [ 6: 0] HEX3,
    output      [ 6: 0] HEX4,
    output      [ 6: 0] HEX5,

    // Pushbuttons
    input       [ 3: 0] KEY,

    // LEDs
    output      [ 9: 0] LEDR,

    // Slider Switches
    input       [ 9: 0] SW,

    // 40-pin header (used for time_bcd input)
    inout       [35: 0] GPIO
);

    wire [1:0] clock_mode;
    wire       edit_increment;
    wire       edit_decrement;
	 
	 reg 		alarm_activated;
	 wire 	alarm_reset;

    input_handler input_handler_inst (
        .clk(CLOCK_50),
        .buttons(KEY[3:0]),
        .switches(SW[2:0]),
        .clock_mode(clock_mode),
        .edit_increment(edit_increment),
        .edit_decrement(edit_decrement)
    );
	 
	 alarm_clock alarm_clock_inst (
        .clk(CLOCK_50),
        .clock_mode(clock_mode[1:0]),
        .switches(SW[2:0]),
        .edit_increment(edit_increment),
        .edit_decrement(edit_decrement),
        .time_bcd(GPIO[23:0]),
		  .alarm_reset(alarm_reset),
        .second_ones_segment(HEX0[6:0]),
        .second_tens_segment(HEX1[6:0]),
        .minute_ones_segment(HEX2[6:0]),
        .minute_tens_segment(HEX3[6:0]),
        .hour_ones_segment(HEX4[6:0]),
        .hour_tens_segment(HEX5[6:0]),
		  .alarm_activated(alarm_activated)
    );
	 
	 alarm_activation alarm_activation_inst(
		.clk(CLOCK_50),
		.leds(LEDR[9:0]),
		.alarm_activated(alarm_activated),
		.alarm_reset(alarm_reset)
	 );

endmodule