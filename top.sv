// module top (
//     input logic clock_in,
//     output logic HSYNC,
//     output logic VSYNC,
//     output logic [5:0] RGB
// );

//     logic [9:0] row, col;
//     logic valid;
//     logic clock_out;

//     mypll my_pll (
//         .clock_in(clock_in),
//         .clock_out(clock_out)
//     );

//     vga my_vga (
//         .clk(clock_out),
//         .HSYNC(HSYNC),
//         .VSYNC(VSYNC),
//         .col(col),
//         .row(row),
//         .valid(valid)
//     );

//     game_display my_display (
//         .clk(clock_out),
//         .row(row),
//         .col(col),
//         .valid(valid),
//         .RGB(RGB)
//     );

// endmodule

module top (
    input logic clock_in,   //12MHz
    output logic clock_out;
    // input logic reset,
    output logic HSYNC,
    output logic VSYNC,
    output logic [5:0] RGB
);
//clocks
logic clock_out;
logic game_clk;
logic [21:0] count;
logic fast_clk;

logic [9:0] row, col;
logic valid;

//board address
//converting vga pixel coordinates into a ram address for the 24x24 game board
localparam int SUPERPIXEL = 20;
localparam int BOARD_W = 24;

 // RAM wires (game side)
    logic [9:0] game_r_addr, game_w_addr;
    logic [7:0] game_r_data, game_w_data;
    logic       game_w_enable;
    logic [18:0] vga_r_addr,
    logic [5:0]  vga_r_data,
    logic        vga_r_we

logic [1:0] dir;
logic [4:0] food_H, food_V, snake_H, snake_V;


game_clk game_clk_inst (
.vga_clk(clock_out),
.count (count),
.game_clk (game_clk)
);

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

    // HSOSC component -> On chip oscillator
    SB_HFOSC #(
        .CLKHF_DIV("0b00")
    ) osc (
        .CLKHFPU(1'b1), // Power up
        .CLKHFEN(1'b1), // Enable
        .CLKHF(fast_clk) // Clock output
    );

stuff my_stuff (
    .fast_clk(fast_clk),
    .food_H(food_H),
    .food_V(food_V),
    .snake_H(snake_H),
    .snake_V(snake_V),
    .vga_r_addr(vga_r_addr),
    .vga_r_data(vga_r_data),
    .vga_r_we(vga_r_we)
);

ramdp ram_inst (
    .clk        (clock_out),
    .r_addr     (game_r_addr),
    .r_data     (game_r_data),
    .w_addr     (game_w_addr),
    .w_data     (game_w_data),
    .w_enable   (game_w_enable),

    .vga_r_addr (vga_board_addr),
    .vga_r_data (board_value_from_ram)
);

game_logic #(
    .BOARD_W (24),
    .BOARD_H (24),
    .ADDR_WIDTH (10)
) game_inst (
    .clk (clock_out),
    .game_clk (game_clk),
    .dir (dir), // for now maybe constant
    //.reset (reset),
    .food_H (food_H),
    .food_V (food_V),

    .snake_H (snake_H), // ignore for now
    .snake_V (snake_V),

    // .reset(1'b0), //just this for now 
    .game_r_addr   (game_r_addr),
    .game_r_data   (game_r_data),
    .game_w_addr   (game_w_addr),
    .game_w_data   (game_w_data),
    .game_w_enable (game_w_enable)
);

game_display my_display (
    .clk(clock_out),
    .row(row),
    .col(col),
    .valid(valid),
    .RGB(RGB),
    .vga_r_addr(vga_r_addr),
    .vga_r_data(vga_r_data)
);

endmodule