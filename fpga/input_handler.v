module input_handler(
    input  wire       clk,
    input  wire [3:0] buttons,
    input  wire [2:0] switches,
    output wire [1:0] clock_mode,
    output reg        edit_increment,
    output reg        edit_decrement
);


    // DE10 pushbuttons are active-low
    wire [3:0] pressed_raw = ~buttons;
	 wire [3:0] pressed;
	 
	 debounce db0 (.clk(clk), .noisy(pressed_raw[0]), .clean(pressed[0]));
    debounce db1 (.clk(clk), .noisy(pressed_raw[1]), .clean(pressed[1]));
    debounce db2 (.clk(clk), .noisy(pressed_raw[2]), .clean(pressed[2]));
    debounce db3 (.clk(clk), .noisy(pressed_raw[3]), .clean(pressed[3]));
	 
	 reg  [3:0] pressed_prev = 4'b0000;

	 reg	[1:0] clock_mode_r = 2'b00;
	 assign clock_mode = clock_mode_r;
	 
    always @(posedge clk) begin
        // defaults: hold mode, no edit pulse
        edit_increment <= 1'b0;
        edit_decrement <= 1'b0;

        if (clock_mode_r == 2'b00 || clock_mode_r == 2'b01) begin
            // View modes:
            // KEY0 -> view clock, KEY1 -> view alarm, KEY2 -> edit clock, KEY3 -> edit alarm
            if (pressed[0] && !pressed_prev[0])
                clock_mode_r <= 2'b00;
            else if (pressed[1] && !pressed_prev[1])
                clock_mode_r <= 2'b01;
            else if (pressed[2] && !pressed_prev[2])
                clock_mode_r <= 2'b10;
            else if (pressed[3] && !pressed_prev[3])
                clock_mode_r <= 2'b11;

        end else begin
            // KEY0 confirm -> return to corresponding view mode
            // KEY2 increment selected fields
            // KEY3 decrement selected fields
            if (pressed[0] && !pressed_prev[0]) begin
					 clock_mode_r <= (clock_mode_r == 2'b10) ? 2'b00 : 2'b01;
            end
            else if (pressed[2] && !pressed_prev[2] && (|switches)) begin
                edit_increment <= 1'b1;
            end
            else if (pressed[3] && !pressed_prev[3] && (|switches)) begin
                edit_decrement <= 1'b1;
            end
        end

        pressed_prev <= pressed;
    end

endmodule
