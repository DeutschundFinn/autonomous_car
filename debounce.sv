module debounce #(
    parameter n = 8
)(
    input logic clk,
    input logic pb,
    output logic pb_debounced
);

    // 100 MHz clock → sample every 1 ms
    localparam integer SAMPLE_COUNT = 100_000;

    logic [16:0] cnt = 0;
    logic [n-1:0] shift_reg = '0;

    always_ff @(posedge clk) begin
        if (cnt == SAMPLE_COUNT - 1) begin
            cnt <= 0;
            shift_reg <= {shift_reg[n-2:0], pb};
        end else begin
            cnt <= cnt + 1'b1;
        end
    end

    assign pb_debounced = &shift_reg;

endmodule