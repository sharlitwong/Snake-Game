module ramdp #(
    parameter WORD_SIZE = 8, 
    parameter N_WORDS = 576, //24 x 24
    parameter ADDR_WIDTH = 10
) (
    input logic vga_clk,
    input logic game_clk,
    input logic [ADDR_WIDTH - 1:0] r_addr,
    output logic [WORD_SIZE - 1:0] r_data,
    input logic [ADDR_WIDTH - 1:0] w_addr,
    input logic [WORD_SIZE - 1:0] w_data,
    input logic [18:0] vga_r_addr,
    output logic [WORD_SIZE - 1:0] vga_r_data,
    input logic w_enable);

    logic [WORD_SIZE-1:0] mem [N_WORDS-1:0];
    // single clocked block: write + 2 reads

    localparam int ROWS = 24;
    localparam int COLS = 24;
    // snake head position
    logic [4:0] head_row;
    logic [4:0] head_col;

    typedef enum logic [7:0] {
        EMPTY = 8'h00,
        SNAKE = 8'h01,
        FOOD  = 8'h02,
        WALL  = 8'h03
    } pixel_state;

    always_ff @(posedge game_clk) begin
    // write from game side
        if (w_enable) begin
            mem[w_addr] <= w_data;
        end
        // synchronous reads
        r_data <= mem[r_addr];
    end

    always_ff @(posedge vga_clk) begin
        vga_r_data <= mem[vga_r_addr];
    end
endmodule