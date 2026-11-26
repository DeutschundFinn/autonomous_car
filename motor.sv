// This module take "mode" input and control two motors accordingly.
// clk should be 100MHz for PWM_gen module to work correctly.
// You can modify / add more inputs and outputs by yourself.
module motor(
    input logic clk,
    input logic rst,
    input logic [2:0] mode, //0: stop 1: forward 2: backward 3: rotate left 4: rotate right 5: turn left 6: turn right 7: not implemented
    output logic [1:0] pwm,
    output logic [1:0] r_IN,
    output logic [1:0] l_IN
);
    logic [9:0] left_motor, right_motor;
    logic left_pwm, right_pwm;
    assign pwm = {left_pwm, right_pwm};

    PWM_gen m0 (
        .clk(clk),
        .rst(rst),
        .freq(32'd25000),
        .duty(left_motor),
        .PWM(left_pwm)
    );
    
    PWM_gen m1 (
        .clk(clk),
        .rst(rst),
        .freq(32'd25000),
        .duty(right_motor),
        .PWM(right_pwm)
    );

    // TODO: trace the rest of motor.v and control the speed and direction of the two motors
    // current duty cycle: ~60%
    always_comb begin
        case(mode)
            3'b000: begin
                r_IN = '0;
                l_IN = '0;
            end
            3'b001: begin
                r_IN = 2'b01;
                l_IN = 2'b01;
            end
            3'b010: begin
                r_IN = 2'b10;
                l_IN = 2'b10;
            end
            3'b011: begin
                r_IN = 2'b01;
                l_IN = 2'b10;
            end
            3'b100: begin
                r_IN = 2'b10;
                l_IN = 2'b01;
            end
            3'b101: begin
                r_IN = 2'b01;
                l_IN = '0;
            end
            3'b110: begin
                r_IN = '0;
                l_IN = 2'b01;
            end
            default: begin
                r_IN = '0;
                l_IN = '0;
            end
        endcase

        left_motor = (|l_IN) ? 10'd615:'0;
        right_motor = (|r_IN) ? 10'd615:'0;
    end
    
endmodule


//generte PWM by input frequency & duty cycle
module PWM_gen (
    input logic clk,
    input logic rst,
	input logic [31:0] freq,
    input logic [9:0] duty,
    output logic PWM
);
    logic [31:0] count_max = 100_000_000 / freq;
    logic [31:0] count_duty = count_max * duty / 1024;
    logic [31:0] count;
    
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            count <= 0;
            PWM <= 0;
        end else begin
            if (count >= (count_max - 32'd1)) begin
                count <= 0;
                PWM <= 0;
            end else begin
                count <= count + 1;
                // TODO: set <PWM> accordingly
                if(count >= count_duty - 32'd1) PWM <= 0;
                else PWM <= 1;
            end
        end
    end
endmodule

