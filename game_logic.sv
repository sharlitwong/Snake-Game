module game_logic (
    input logic [1:0] dir,
    input logic reset,
    input logic food_H,
    input logic food_V,
    input logic game_clk,
    output logic snake_H,
    output logic snake_V,
);

logic C, reset, move_dir;

//head movement logic module
head (
    .in_dir(dir),
    .C(),
    .reset(reset),
    .game_clk(game_clk),
    .move_dir(move_dir)
);

//logic to determine head/body positions

//collision check

//food collision

//wall collision or body collision


endmodule
