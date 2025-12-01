module game_display (
//    input logic snake_H,
//    input logic snake_V,
//    input logic food_H,
//    input logic food_V,
    input logic clk,
    input logic [9:0] row,
    input logic [9:0] col,
    input logic valid,
    output logic [5:0] RGB
);
    // Instantiate ROM
    logic [5:0] rom_data;
    logic [8:0] rom_addr;

    redapple my_apple (
        .clk(clk),
        .addr(rom_addr),
        .data(rom_data)
    );

    logic [21:0] counter;
    logic game_clk;
    logic [9:0] newfood_H;
    logic [9:0] newfood_V;

    game_clk my_game_clk (
        .vga_clk(clk),
        .count(counter),
        .game_clk(game_clk)
    );

    random my_random (
    .vga_clk(clk),
    .newfood_H(newfood_H),
    .newfood_V(newfood_V)
);
    
    logic [9:0] APPLE1_X0 = 40;   // OK (200 % 20 = 0)
    logic [9:0] APPLE1_Y0 = 40;   // OK (140 % 20 = 0)
    localparam SIZE = 20;        // 20×20 superpixel


    always_ff @(posedge game_clk) begin
            APPLE1_X0 <= newfood_H * 20;
            APPLE1_Y0 <= newfood_V * 20;
    end

    logic [4:0] x_in_sprite1;
    logic [4:0] y_in_sprite1;

    logic inside_apple1;

    logic [9:0] GREEN_X0 = 10 * SIZE;
    logic [9:0] GREEN_Y0 = 10 * SIZE;

    logic inside_green;

    assign inside_green =
        (col >= GREEN_X0) &&
        (col <  GREEN_X0 + SIZE) &&
        (row >= GREEN_Y0) &&
        (row <  GREEN_Y0 + SIZE);

    always_comb begin
        RGB = 6'd0;  // background

        // Apple (sprite)
        if (valid && inside_apple1)
            RGB = rom_data;

        // Green square (solid)
        else if (valid && inside_green)
            RGB = 6'b00_1100;  // green (choose any)
    end



    // Check bounds
    assign inside_apple1 = (col >= APPLE1_X0 &&
            col <  APPLE1_X0 + SIZE &&
            row >= APPLE1_Y0 &&
            row <  APPLE1_Y0 + SIZE);

    // Compute local coordinates
    always_comb begin
        x_in_sprite1 = col - APPLE1_X0;
        y_in_sprite1 = row - APPLE1_Y0;
    end
       
    // Address ROM
    always_comb begin
        if (inside_apple1) 
            rom_addr = y_in_sprite1 * SIZE + x_in_sprite1;  // 0..399
        else
            rom_addr = 0;
    end

    always_comb begin
        RGB = 6'd0;               // background
        if (valid && inside_apple1)
            RGB = rom_data;
    end

endmodule