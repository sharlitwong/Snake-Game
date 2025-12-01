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
input logic clock_in,
//input logic reset,
output logic HSYNC,
output logic VSYNC,
output logic [5:0] RGB
);
//clocks
logic clock_out;
logic game_clk;
logic [21:0] count;

logic [9:0] row, col;
logic valid;

//board address
//converting vga pixel coordinates into a ram address for the 24x24 game board
localparam int SUPERPIXEL = 20;
localparam int BOARD_W = 24;

logic [4:0] cell_x, cell_y;
logic [9:0] vga_board_addr;
logic [7:0] board_value_from_ram;

assign cell_x = col / SUPERPIXEL;
assign cell_y = row / SUPERPIXEL;

assign vga_board_addr = cell_y * BOARD_W + cell_x;

//ram
logic [9:0] r_addr, w_addr;
logic [7:0] r_data, w_data;
logic w_enable;

logic [1:0] dir;
logic food_H, food_V;

assign dir = 2'b11; // TEMP: always "move right"
assign food_H = 1'b0;
assign food_V = 1'b0;

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

ramdp ram_inst (
.clk (clock_out),

.r_addr (r_addr),
.r_data (r_data),
.w_addr (w_addr),
.w_data (w_data),
.w_enable (w_enable),

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

.snake_H (), // ignore for now
.snake_V (),

.game_r_addr (game_r_addr),
.game_r_data (game_r_data),
.game_w_addr (game_w_addr),
.game_w_data (game_w_data),
.game_w_enable (game_w_enable)
);

game_display my_display (
.clk(clock_out),
.row(row),
.col(col),
.valid(valid),
.RGB(RGB)
);

endmodule