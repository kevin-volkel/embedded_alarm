module alarm_activation(
	input 	wire 			clk,
	input		wire			alarm_activated,
	output 	reg	[9:0] leds,
	output 	reg			alarm_reset
);

	parameter ALARM_TIME = 25_000_000;
	parameter LED_FLASHES = 16;
   reg [24:0] counter = 0;
	reg [4:0]  led_counter = 0;

	always @(posedge clk) begin
	
		if(alarm_activated) begin
			counter <= counter + 1;
			if (counter == ALARM_TIME - 1) begin
				counter <= 0;
				leds <= ~leds;
				led_counter <= led_counter + 1;
				if(led_counter == LED_FLASHES - 1) begin
					led_counter <= 0;
					alarm_reset <= 1'b1;
					leds <= 10'b0;
				end
			end
		end else begin
			leds <= 10'b0;
			counter <= 0;
			led_counter <= 0;
			if (!alarm_activated) begin
            alarm_reset <= 1'b0;
         end
		end
	end

endmodule