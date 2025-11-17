module game_logic (
    input logic [1:0] dir,
    input logic reset,
    input logic food_H,
    input logic food_V,
    input logic game_clk,
    output logic snake_H,
    output logic snake_V,
);

