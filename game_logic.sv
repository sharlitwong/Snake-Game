module game_logic #(
    parameter BOARD_W = 24,
    parameter BOARD_H = 24,
    parameter ADDR_WIDTH = 10
) (
    input logic clk, //fast clock
    input logic game_clk, //6Hz
    input logic [1:0] dir,
    input logic reset,
    //not used yet
    input logic [4:0] food_H,
    input logic [4:0] food_V,

    output logic [4:0] snake_H,
    output logic [4:0] snake_V,

    // RAM interface (game side)
    output logic [ADDR_WIDTH-1:0] game_r_addr,
    input logic [7:0] game_r_data, // not used yet
    output logic [ADDR_WIDTH-1:0] game_w_addr,
    output logic [7:0] game_w_data,
    output logic game_w_enable
);

logic C;
logic [1:0] move_dir;

//this is later going to be changed to the nes logic
assign C = 1'b0;

//converting the 2d board coordinates into 1d ram address
function automatic [ADDR_WIDTH-1:0] cell_addr (
    input logic [4:0] x,
    input logic [4:0] y
);
    cell_addr = y * BOARD_W + x; // y*24 + x
endfunction

//head positions
logic [4:0] head_x, head_y;
logic [4:0] prev_x, prev_y;

assign snake_H = head_x;
assign snake_V = head_y;
//detecting clock edges
logic game_clk_prev;
wire game_tick = game_clk & ~game_clk_prev;

//data read from nes
// nes_read my_nes (
//     .data,
//     .nes_data(dir),
//     .reset(reset),
//     .clock,
//     .latch    
// );


//head movement logic module
head my_head (
    .in_dir(dir),
    .C(C),
    // .reset(reset),
    .game_clk(game_clk),
    .move_dir(move_dir)
);

//fsm: wait -> clear old cell -> set new cell
typedef enum logic [1:0] {IDLE, CLEAR_OLD, SET_NEW} state_t;
state_t state;

always @(posedge clk) begin
    if (1'b0) begin
        // start head somewhere near middle
        head_x <= 5'd5;
        head_y <= 5'd5;
        prev_x <= 5'd5;
        prev_y <= 5'd5;

        game_clk_prev <= 1'b0;
        state <= SET_NEW; // first thing: draw initial head

        game_w_enable <= 1'b0;
        game_w_addr <= '0;
        game_w_data <= 8'd0;
    end else begin
        game_clk_prev <= game_clk;
        game_w_enable <= 1'b0;

        case (state)
            // wait for the next slow tick
            IDLE: begin
                if (game_tick) begin
                    state <= CLEAR_OLD;
                end
            end

            // one fast-clock cycle: clear the old head cell
            CLEAR_OLD: begin
                game_w_enable <= 1'b1;
                game_w_addr <= cell_addr(prev_x, prev_y);
                game_w_data <= 8'd0;
                state <= SET_NEW;
            end

            // one fast-clock cycle: move head and draw new cell
            SET_NEW: begin
                // remember current as previous
                prev_x <= head_x;
                prev_y <= head_y;

                // move RIGHT, wrapping at BOARD_W
                if (head_x == BOARD_W-1)
                    head_x <= 0;
                else
                    head_x <= head_x + 1;

                // draw new head cell with nonzero value (snake)
                game_w_enable <= 1'b1;
                game_w_addr <= cell_addr(head_x, head_y);
                game_w_data <= 8'd10; // any nonzero value
                state <= IDLE;
            end
        endcase
    end
end

assign game_r_addr = cell_addr(head_x, head_y);

//logic to determine head/body positions (RAM)

//collision check

//food collision

//wall collision or body collision


endmodule
