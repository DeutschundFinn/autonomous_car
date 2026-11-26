module lab6_advanced(
    input logic clk,
    input logic rst,
    input logic IR_out1,    // far-left
    input logic IR_out2,    // inner-left  
    input logic IR_out3,    // center
    input logic IR_out4,    // inner-right
    input logic IR_out5,    // far-right
    input logic echo,
    output logic trig,
    output logic IN1,
    output logic IN2,
    output logic IN3,
    output logic IN4,
    output logic left_pwm,  // ENA
    output logic right_pwm, // ENB

    output logic [6:0] DISPLAY,
    output logic [3:0] DIGIT,
    output logic [15:0] LED
    // You may modify or add more input/ouput yourself.
);
    logic rst_de, rst_op;
    debounce de(.clk(clk), .pb(rst), .pb_debounced(rst_de));
    one_pulse op(.clk(clk), .pb_in(rst_de), .pb_out(rst_op));
    
    // We have connected the tracker_sensor, sonic_top, and motor modules in the template file for you.
    // TODO: control the motors with the information you get from ultrasonic sensor and 5-way track sensor.
    logic [2:0] state;      // output of track_sensor
    logic [2:0] mode;       // input of motor
    logic [19:0] distance;  // output of sonic_top
    localparam brake_distance = 10;
    assign mode = (distance < brake_distance) ? 3'b000 : state;
    assign LED[4:0] = {IR_out1, IR_out2, IR_out3, IR_out4, IR_out5};
    assign LED[5] = 0;
    assign LED[8:6] = state;
    assign LED[9] = 0;
    assign LED[12:10] = mode;
    assign LED[14:13] = '0;
    assign LED[15] = (distance <= 20);

    localparam ONE_MS = 100_000;
    logic [16:0] count, next_count;
    logic tick1ms;
    always_ff @(posedge clk, posedge rst)begin
        if(rst) count <= '0;
        else count <= next_count;
    end
    assign next_count = (count==ONE_MS) ? '0: count+17'd1;
    assign tick1ms = count==ONE_MS;

    //binary to bcd converter
    logic [15:0] distance_display;
    logic [3:0] i;
    always_comb begin
        distance_display = '0;
        for(i=0; i<4'd9; i++)begin
            if(distance_display[11:8] >= 4'd5) distance_display[11:8] = distance_display[11:8] + 4'd3;
            if(distance_display[7:4] >= 4'd5) distance_display[7:4] = distance_display[7:4] + 4'd3;
            if(distance_display[3:0] >= 4'd5) distance_display[3:0] = distance_display[3:0] + 4'd3;
            distance_display = distance_display << 1;
            distance_display[0] = distance[4'd8-i];
        end
        distance_display[15:12] = 4'd10;
    end

    logic [3:0] display_num;
    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            DIGIT <= 4'b1111;
            display_num <= 4'd10;
        end
        else if(tick1ms) begin
            case(DIGIT)
                4'b1110: begin
                    DIGIT <= 4'b1101;
                    display_num <= distance_display[7:4];
                end
                4'b1101: begin
                    DIGIT <= 4'b1011;
                    display_num <= distance_display[11:8];
                end
                4'b1011: begin
                    DIGIT <= 4'b0111;
                    display_num <= distance_display[15:12];
                end
                4'b0111: begin
                    DIGIT <= 4'b1110;
                    display_num <= distance_display[3:0];
                end
                default: begin
                    DIGIT <= 4'b1110;
                    display_num <= distance_display[3:0];
                end
            endcase
        end
    end

    always_comb begin
        case(display_num)
            4'd0: DISPLAY = 7'b1000000;
            4'd1: DISPLAY = 7'b1111001;
            4'd2: DISPLAY = 7'b0100100;
            4'd3: DISPLAY = 7'b0110000;
            4'd4: DISPLAY = 7'b0011001;
            4'd5: DISPLAY = 7'b0010010;
            4'd6: DISPLAY = 7'b0000010;
            4'd7: DISPLAY = 7'b1111000;
            4'd8: DISPLAY = 7'b0000000;
            4'd9: DISPLAY = 7'b0010000;
            default: DISPLAY = 7'b1111111;
        endcase
    end
    tracker_sensor A(
        .clk(clk),
        .rst(rst_op),
        .IR_outs({IR_out1, IR_out2, IR_out3, IR_out4, IR_out5}),
        .state(state)
    );

    sonic_top B(
        .clk(clk), 
        .rst(rst_op), 
        .echo(echo), 
        .trig(trig),
        .distance(distance)
    );

    motor C(
        .clk(clk),
        .rst(rst_op),
        .mode(mode),
        .pwm({left_pwm, right_pwm}),
        .l_IN({IN1, IN2}),
        .r_IN({IN3, IN4})
    );

endmodule