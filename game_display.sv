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

    logic [25:0] counter;

    count t_counter (
        .clk(clk),
        .counter(counter)
    );
    
    
    localparam APPLE1_X0 = 0;   // OK (200 % 20 = 0)
    localparam APPLE1_Y0 = 0;   // OK (140 % 20 = 0)
    localparam SIZE = 20;        // 20×20 superpixel

    always_comb begin
        if(counter[20] == 1) begin
            APPLE1_X0 = APPLE1_X0 + 20;
            APPLE1_Y0 = APPLE1_Y0 + 20;
        end
    end

    logic [4:0] x_in_sprite1;
    logic [4:0] y_in_sprite1;

    logic inside_apple1;

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