module nes_read(
    output logic latch,
    output logic clock,
    output logic [7:0] buttons,
    output logic button_up,
    output logic button_down,
    output logic button_left,
    output logic button_right,
    output logic button_select,
    output logic button_start,
    output logic button_B,
    output logic button_A,    
    input logic data,
    input logic clk

);

    localparam int N = 18;
    logic [N:0] ctr;
    always_ff @(posedge clk) ctr <= ctr + 1'b1;

    logic NESclk;
    logic [N-9:0] NEScount;
    assign NESclk = ctr[8];
    assign NEScount = ctr[N:9];

    // latch - 1 NESclk period at start of frame
    assign latch = (NEScount == 0);

    // clock - 8 NESclk pulses after latch
    assign clock = NESclk && (NEScount >= 1) && (NEScount <= 8);


    logic [7:0] shift_reg;
    always_ff @(posedge NESclk) begin

        if (latch) begin
            shift_reg <= 8'b0;

        end else if ((NEScount >= 1) && (NEScount <= 8)) begin
            shift_reg <= {shift_reg[6:0], data};  // puts new bit at LSB

        end
    end

    //copy to a stable holding register after 8 bits
    always_ff @(posedge NESclk) begin
        if (NEScount == 9) begin
            buttons <= shift_reg;
        end
    end

    assign button_up = ~buttons[3];
    assign button_down = ~buttons[2];
    assign button_right = ~buttons[0];
    assign button_left = ~buttons[1];
    assign button_start = ~buttons[4];

endmodule