module debounce (
    input  wire clk,
    input  wire noisy,
    output reg  clean
);
    // 20ms debounce at 50MHz = 1,000,000 cycles, so we need a 20-bit counter
    parameter DEBOUNCE_COUNT = 1_000_000;
    reg [20:0] counter = 0;
    reg        sync    = 0;

    always @(posedge clk) begin
        sync <= noisy;

        if (sync == clean) begin
            // Signal stable — reset counter
            counter <= 0;
        end else begin
            counter <= counter + 1;
            // Only commit the change once stable for full debounce period
            if (counter == DEBOUNCE_COUNT - 1)
                clean <= sync;
        end
    end
endmodule