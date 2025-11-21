module top (
    input logic clock_in,
    output logic clock_out,
    output logic HSYNC,
    output logic VSYNC,
    output logic [5:0] RGB
);

    logic [9:0] row, col;
    logic valid;

    logic [9:0] row, col;
    logic valid;

    mypll my_pll (
        .clock_in(clock_in),
        .clock_out(clock_out)
    );

    vga my_vga (
        .clk(clock_out),
        .HSYNC(HSYNC),
        .VSYNC(VSYNC),
        .col(col),
        .row(row),
        .valid(valid)
    );

    game_display my_display (
        .clk(clock_out),
        .row(row),
        .col(col),
        .valid(valid),
        .RGB(RGB)
    );

endmodule
