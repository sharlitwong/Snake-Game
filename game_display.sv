module game_display (
//    input logic [9:0] snake_H,
//    input logic [9:0] snake_V,
//    input logic food_H,
//    input logic food_V,
    input logic clk,
    input logic [9:0] row,
    input logic [9:0] col,
    input logic valid,
    output logic [5:0] RGB,
    // input logic [18:0] vga_r_addr,
    // input logic [7:0] vga_r_data,

    //for testing
    input logic [1:0] dir
);    

/*********************************GAME_CLOCK***********************************/
    //initiate game clock
    logic [21:0] counter;
    logic game_clk;

    game_clk my_game_clk (
        .vga_clk(clk),
        .count(counter),
        .game_clk(game_clk)
    );

/*********************************ROM******************************************/

    // Instantiate ROM
    logic [5:0] rom_data;
    logic [8:0] rom_addr;
    logic [5:0] rom_data_score;
    logic [10:0] rom_addr_score;


/*********************************APPLE****************************************/

    //initiate the variables for food position
    logic [9:0] newfood_H;
    logic [9:0] newfood_V;
    logic [9:0] APPLE1_X0 = 40;   // OK (200 % 20 = 0)
    logic [9:0] APPLE1_Y0 = 40;   // OK (140 % 20 = 0)
    localparam SIZE = 20;        // 20×20 superpixel of the game frame    
    
    //apple internal coordinates
    logic [4:0] x_in_sprite1;
    logic [4:0] y_in_sprite1;
    logic inside_apple1;    

    //Initialize apple ROM
    redapple my_apple (
        .clk(clk),
        .addr(rom_addr),
        .data(rom_data)
    );

    //module to generate random apple positions
    random my_random (
        .game_clk(game_clk),
        .newfood_H(newfood_H),
        .newfood_V(newfood_V)
    );
    
    //new position updated every clock cycle
    always_ff @(posedge game_clk) begin
            APPLE1_X0 <= (newfood_H) * 20;
            APPLE1_Y0 <= newfood_V * 20;
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

/*********************************SNAKE****************************************/
    //Variables for snake positions
    logic [9:0] GREEN_X0 = 10 * SIZE;
    logic [9:0] GREEN_Y0 = 10 * SIZE;
    logic inside_green;
    logic [9:0] snake_H;
    logic [9:0] snake_V;

    // always_comb begin
    //     if (dir == 2'b00) begin
    //         snake_H = GREEN_Y0 + 20;
    //         snake_V = GREEN_X0 + 20;
    //     end else begin
    //         snake_H = GREEN_Y0;
    //         snake_V = GREEN_X0;
    //     end
    // end

    // next position logic
    always_comb begin
        snake_H = GREEN_X0;
        snake_V = GREEN_Y0;

        case (dir)
            2'b00: snake_V = GREEN_Y0 - 20;   // up
            2'b01: snake_V = GREEN_Y0 + 20;   // down
            2'b10: snake_H = GREEN_X0 - 20;   // left
            2'b11: snake_H = GREEN_X0 + 20;   // right
        endcase
    end

    //new position updated every clock cycle
    always_ff @(posedge game_clk) begin
            GREEN_X0 <= snake_V;
            GREEN_Y0 <= snake_H;
    end

    //determine if is inside snake
    assign inside_green =
        (col >= GREEN_X0) &&
        (col <  GREEN_X0 + SIZE) &&
        (row >= GREEN_Y0) &&
        (row <  GREEN_Y0 + SIZE);

/**********************************STRIPE**************************************/
    localparam STRIPE_COL = 21;
    localparam STRIPE_X0  = STRIPE_COL * SIZE;   // SIZE = 20

    logic inside_stripe;

    assign inside_stripe =
        (col >= STRIPE_X0) &&
        (col <  STRIPE_X0 + SIZE);

/********************************SCORE_DISPLAY*********************************/
    logic [9:0] SCORE_X0 = 480;   // OK (200 % 20 = 0)
    logic [9:0] SCORE_Y0 = 40;   // OK (140 % 20 = 0)
    logic inside_score;
    localparam SCORE_SIZE_X = 100;
    localparam SCORE_SIZE_Y = 20;
    logic [6:0] x_in_score;
    logic [4:0] y_in_score;

    //Initialize score ROM
    score my_score (
        .clk(clk),
        .addr(rom_addr_score),
        .data(rom_data_score)
    );

    //determine if is inside snake
    assign inside_score =
        (col >= SCORE_X0) &&
        (col <  SCORE_X0 + SCORE_SIZE_X) &&
        (row >= SCORE_Y0) &&
        (row <  SCORE_Y0 + SCORE_SIZE_Y);

    // Compute local coordinates
    always_comb begin
        x_in_score = col - SCORE_X0;
        y_in_score = row - SCORE_Y0;
    end    

    // Address ROM
    always_comb begin
        if (inside_score) 
            rom_addr_score = y_in_score * SCORE_SIZE_X + x_in_score;  // 0..399
        else
            rom_addr_score = 0;
    end

/**********************************DISPLAY*************************************/  
    always_comb begin
        RGB = 6'd0;  // background
        if (valid && inside_score)
            RGB = rom_data_score;

        // Stripe (solid white)
        if (valid && inside_stripe)
            RGB = 6'b11_1111;   // white

        // Green square (solid)
        else if (valid && inside_green)
            RGB = 6'b00_1100;  // green (choose any)   \

        // Apple (sprite)
        else if (valid && inside_apple1)
            RGB = rom_data;

        //moving the snake
        // if(valid) begin
        //     if (board_value != 8'd0)
        //     RGB = 6'b00_1111;
        // end 
    end

endmodule