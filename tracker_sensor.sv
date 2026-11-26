module tracker_sensor(
    input logic clk,
    input logic rst,
    input logic [4:0] IR_outs,
    output logic [2:0] state
);
    // TODO: Receive IR outputs and make your own policy.
    // Hint: You can use output state to change your action.
    logic [2:0] next_state;
    always_ff @ (posedge clk, posedge rst) begin
        if(rst) state <= '0;
        else state <= next_state;
    end

    always_comb begin
        case (IR_outs)
            //forward
            5'b11011: next_state = 3'b001;
            //rotate left
            5'b10011, 
            5'b10111: next_state = 3'b011;
            //rotate right
            5'b11001, 
            5'b11101: next_state = 3'b100; 
            //turn left
            5'b00111, 
            5'b01111: next_state = 3'b101;
            //turn right
            5'b11100, 
            5'b11110: next_state = 3'b110;
            //lost track -> backwards
            5'b11111: next_state = 3'b010;
            default: next_state = state;
        endcase
    end
endmodule
