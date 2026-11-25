module tracker_sensor(
    input logic clk,
    input logic rst,
    input logic [4:0] IR_outs,
    output logic [2:0] state
);
    // TODO: Receive IR outputs and make your own policy.
    // Hint: You can use output state to change your action.
    always_comb begin
        case (IR_outs)
            // Forward
            5'b11011,
            5'b10001,
            5'b00000: state = 3'b001;

            // Turn left
            5'b10111,
            5'b10011,
            5'b00011,
            5'b00001: state = 3'b101;

            // Rotate left
            5'b01111,
            5'b00111: state = 3'b011;

            // Turn right
            5'b11101,
            5'b11001,
            5'b11000,
            5'b10000: state = 3'b110;

            // Rotate right
            5'b11110,
            5'b11100: state = 3'b100;

            // Lost track
            5'b11111: state = 3'b000;

            default: state = 3'b000;
        endcase
    end
endmodule
