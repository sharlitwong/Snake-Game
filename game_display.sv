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
    input logic [2:0] dir,
    output logic outside_frame
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

/*********************************SCORE NUMBERS *******************************/
    //coordinates of the three digit score
    //most significant digit of score
    logic [9:0] digit_2X = 540;
    logic [9:0] digit_2Y = 80;
    logic [9:0] digit_1X = 560;
    logic [9:0] digit_1Y = 80;
    logic [9:0] digit_0X = 580;
    logic [9:0] digit_0Y = 80;
    //least significant digit of score

    logic [9:0] current_score = 0; //initialize score (0 - 576)

    localparam num_SIZE = 20; //(length = width) of one score pixel (superpixel)
    logic inside_digit2; //"booleans" for whether the vga is currently rendering
    logic inside_digit1; //within where these numbers should be
    logic inside_digit0;

    assign inside_digit2 = 
        (col >= digit_2X) &&
        (col <  digit_2X + num_SIZE) &&
        (row >= digit_2Y) &&
        (row <  digit_2Y + num_SIZE);

    assign inside_digit1 =
        (col >= digit_1X) &&
        (col <  digit_1X + num_SIZE) &&
        (row >= digit_1Y) &&
        (row <  digit_1Y + num_SIZE);

    assign inside_digit0 =
        (col >= digit_0X) &&
        (col <  digit_0X + num_SIZE) &&
        (row >= digit_0Y) &&
        (row <  digit_0Y + num_SIZE);

    logic [5:0] rom_data_zero;
    //Initialize zero ROM
    zero my_zero (
        .clk(clk),
        .addr(digit_addr),
        .data(rom_data_zero)
    );

    logic [5:0] rom_data_one;
    //Initialize one ROM
    one my_one (
        .clk(clk),
        .addr(digit_addr),
        .data(rom_data_one)
    );

    logic [5:0] rom_data_two;
    //Initialize two ROM
    two my_two (
        .clk(clk),
        .addr(digit_addr),
        .data(rom_data_two)
    );

    logic [5:0] rom_data_three;
    //Initialize three ROM
    three my_three (
        .clk(clk),
        .addr(digit_addr),
        .data(rom_data_three)
    );

    logic [5:0] rom_data_four;
    //Initialize four ROM
    four my_four (
        .clk(clk),
        .addr(digit_addr),
        .data(rom_data_four)
    );

    logic [5:0] rom_data_five;
    //Initialize five ROM
    five my_five (
        .clk(clk),
        .addr(digit_addr),
        .data(rom_data_five)
    );

    logic [5:0] rom_data_six;
    //Initialize six ROM
    six my_six (
        .clk(clk),
        .addr(digit_addr),
        .data(rom_data_six)
    );

    logic [5:0] rom_data_seven;
    //Initialize seven ROM
    seven my_seven (
        .clk(clk),
        .addr(digit_addr),
        .data(rom_data_seven)
    );

    logic [5:0] rom_data_eight;
    //Initialize eight ROM
    eight my_eight (
        .clk(clk),
        .addr(digit_addr),
        .data(rom_data_eight)
    );

    logic [5:0] rom_data_nine;
    //Initialize nine ROM
    nine my_nine (
        .clk(clk),
        .addr(digit_addr),
        .data(rom_data_nine)
    );

    logic [3:0] ones_value; //digit 0 actual numerical value
    logic [3:0] tens_value; //digit 1
    logic [3:0] hundreds_value; //digit 2

    divide my_divide(
        .score(current_score),
        .ones(ones_value),
        .tens(tens_value),
        .hundreds(hundreds_value),
    );

    logic [4:0] x_in_digit2; //local x for most significant digit
    logic [4:0] y_in_digit2; //local y for most significant digit

    logic [4:0] x_in_digit1; //local x for middle digit
    logic [4:0] y_in_digit1; //local y for midde digit

    logic [4:0] x_in_digit0; //local x for least significant digit
    logic [4:0] y_in_digit0; //local y for least significant digit

    // Compute local coordinates within a digit 
    always_comb begin
        x_in_digit2 = col - digit_2X;
        y_in_digit2 = row - digit_2Y;

        x_in_digit1 = col - digit_1X;
        y_in_digit1 = row - digit_1Y;

        x_in_digit0 = col - digit_0X;
        y_in_digit0 = row - digit_0Y;
    end  

    logic [8:0] digit_addr;
    always_comb begin
        if (inside_digit2)
            digit_addr = y_in_digit2 * num_SIZE + x_in_digit2;
        else if (inside_digit1)
            digit_addr = y_in_digit1 * num_SIZE + x_in_digit1;
        else if (inside_digit0)
            digit_addr = y_in_digit0 * num_SIZE + x_in_digit0;
        else
            digit_addr = 9'd0;
    end

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
        if (GREEN_X0 == APPLE1_X0 && GREEN_Y0 == APPLE1_Y0) begin
            APPLE1_X0 <= (newfood_H) * 20;
            APPLE1_Y0 <= newfood_V * 20;
            current_score <= current_score + 1;
        end else begin
            APPLE1_X0 <= APPLE1_X0;
            APPLE1_Y0 <= APPLE1_Y0;
        end
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
    logic [9:0] snake_H = GREEN_X0;
    logic [9:0] snake_V = GREEN_Y0;

    logic [2:0] move_dir;
    //assign move_dir = 3'b011;

    head my_head(
        .in_dir(dir), //input from NES
        .game_clk(game_clk),
        .move_dir(move_dir) //state of snake head movement
    );

    //new position updated every clock cycle
    always_ff @(posedge game_clk) begin
        case (move_dir) //should be move_dir
            3'b000: GREEN_Y0 <= GREEN_Y0 - 20;   // up
            3'b001: GREEN_Y0 <= GREEN_Y0 + 20;   // down
            3'b010: GREEN_X0 <= GREEN_X0 - 20;   // left
            3'b011: GREEN_X0 <= GREEN_X0 + 20;   // right
            3'b100: begin //idle
                GREEN_X0 <= GREEN_X0;
                GREEN_Y0 <= GREEN_Y0;
            end
        endcase
    end

    //determine if is inside snake
    assign inside_green =
        (col >= GREEN_X0) &&
        (col <  GREEN_X0 + SIZE) &&
        (row >= GREEN_Y0) &&
        (row <  GREEN_Y0 + SIZE);

/**********************************STRIPE**************************************/
    localparam STRIPE_COL = 24;
    localparam STRIPE_X0  = STRIPE_COL * SIZE;   // SIZE = 20

    logic inside_stripe;

    assign inside_stripe =
        (col >= STRIPE_X0) &&
        (col <  STRIPE_X0 + SIZE);

/********************************SCORE_DISPLAY (label)*************************/
    logic [9:0] SCORE_X0 = 520;   // OK (200 % 20 = 0)
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

    // assign outside_frame = (GREEN_X0 >= 24*20) ||
    //     (GREEN_X0 <=  20) ||
    //     (GREEN_Y0 >= 24*20) ||
    //     (GREEN_Y0 <=  20);

    assign outside_frame =
    (GREEN_X0 >= 24*20) ||   // X >= 480
    (GREEN_Y0 >= 24*20) ||
    (GREEN_X0 <= 0) ||
    (GREEN_Y0 <= 0);     // Y >= 480

    always_comb begin
        // Default background color
        RGB = 6'd0;

        // HIGHEST PRIORITY: outside frame
        if (valid && outside_frame)
            RGB = 6'b11_0000;  // red

        // Next priority: score display
        else if (valid && inside_score)
            RGB = rom_data_score;

        // Stripe
        else if (valid && inside_stripe)
            RGB = 6'b11_1111;  // white

        // Green square (snake)
        else if (valid && inside_green)
            RGB = 6'b00_1100;  // green

        // Apple sprite
        else if (valid && inside_apple1)
            RGB = rom_data;

        //most significant digit of score
        else if (valid && inside_digit2)
            case(hundreds_value)
                4'b0000: RGB = rom_data_zero;
                4'b0001: RGB = rom_data_one;
                4'b0010: RGB = rom_data_two;
                4'b0011: RGB = rom_data_three;
                4'b0100: RGB = rom_data_four;
                4'b0101: RGB = rom_data_five;
                4'b0110: RGB = rom_data_six;
                4'b0111: RGB = rom_data_seven;
                4'b1000: RGB = rom_data_eight;
                4'b1001: RGB = rom_data_nine;
                default: RGB = rom_data_zero;
            endcase

        //middle digit of score
        else if (valid && inside_digit1)
            case(tens_value)
                4'b0000: RGB = rom_data_zero;
                4'b0001: RGB = rom_data_one;
                4'b0010: RGB = rom_data_two;
                4'b0011: RGB = rom_data_three;
                4'b0100: RGB = rom_data_four;
                4'b0101: RGB = rom_data_five;
                4'b0110: RGB = rom_data_six;
                4'b0111: RGB = rom_data_seven;
                4'b1000: RGB = rom_data_eight;
                4'b1001: RGB = rom_data_nine;
                default: RGB = rom_data_zero;
            endcase

        //least signidicant digit of score
        else if (valid && inside_digit0)
            case(ones_value)
                4'b0000: RGB = rom_data_zero;
                4'b0001: RGB = rom_data_one;
                4'b0010: RGB = rom_data_two;
                4'b0011: RGB = rom_data_three;
                4'b0100: RGB = rom_data_four;
                4'b0101: RGB = rom_data_five;
                4'b0110: RGB = rom_data_six;
                4'b0111: RGB = rom_data_seven;
                4'b1000: RGB = rom_data_eight;
                4'b1001: RGB = rom_data_nine;
                default: RGB = rom_data_zero;
            endcase
    end

endmodule