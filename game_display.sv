module game_display (
    input logic snake_H,
    input logic snake_V,
    input logic food_H,
    input logic food_V,
    input logic [9:0] row,
    input logic [9:0] col,
    input logic valid,
    output logic [5:0] RGB
);