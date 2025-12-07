module game_display (
   input logic [4:0] APPLE1_X0,
   input logic [4:0] APPLE1_Y0,
    input logic clk,
    input logic [9:0] row,
    input logic [9:0] col,
    input logic valid,
    input logic [9:0] current_score, //initialize score (0 - 576)
    input logic [3:0] state,
    input logic [299:0] all_coords,
    output logic [5:0] RGB,
    input logic apple_signal
);    

/*********************************ROM******************************************/

    // Instantiate ROM
    logic [5:0] rom_data; //apple
    logic [8:0] rom_addr; //apple
    logic [5:0] rom_data_score;
    logic [10:0] rom_addr_score;

/*********************************SCORE NUMBERS *******************************/
    //coordinates of the three digit score
    //most significant digit of score
    localparam digit_2X = 550;
    localparam digit_2Y = 80;
    localparam digit_1X = 570;
    localparam digit_1Y = 80;
    localparam digit_0X = 590;
    localparam digit_0Y = 80;
    //least significant digit of score

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
/*********************************GAMEOVER*************************************/

    logic [9:0] gameoverX = (640  - gameover_width  * GO_SCALE) / 2;
    logic [9:0] gameoverY = (480 - gameover_height * GO_SCALE) / 2;
    
    localparam gameover_width = 83;
    localparam gameover_height = 47;

    logic inside_gameover;

    localparam integer GO_SCALE = 4; // 2× bigger


    assign inside_gameover = 
        (col >= gameoverX) &&
        (col <  gameoverX + gameover_width * GO_SCALE) &&
        (row >= gameoverY) &&
        (row <  gameoverY + gameover_height * GO_SCALE);

    logic [6:0] x_in_gameover; // 0–82
    logic [5:0] y_in_gameover; // 0–46

    always_comb begin
        x_in_gameover = (col - gameoverX) / GO_SCALE;
        y_in_gameover = (row - gameoverY) / GO_SCALE;
    end

    logic [5:0] rom_data_gameover;
    logic [11:0] gameover_addr;
    gameover my_gameover (
        .clk(clk),
        .addr(gameover_addr),
        .data(rom_data_gameover)
    );

    always_comb begin
        if (inside_gameover)
            gameover_addr = y_in_gameover * gameover_width + x_in_gameover;
        else
            gameover_addr = 12'd0;
    end

/*********************************APPLE****************************************/
    //initiate the variables for food position
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

    // Check bounds
    assign inside_apple1 = (col >= APPLE1_X0*20 &&
        col <  APPLE1_X0*20 + SIZE &&
        row >= APPLE1_Y0*20 &&
        row <  APPLE1_Y0*20 + SIZE);

    // Compute local coordinates
    always_comb begin
        x_in_sprite1 = col - APPLE1_X0*20;
        y_in_sprite1 = row - APPLE1_Y0*20;
    end    

    // Address ROM
    always_comb begin
        if (inside_apple1) 
            rom_addr = y_in_sprite1 * SIZE + x_in_sprite1;  // 0..399
        else
            rom_addr = 0;
    end

/*********************************SNAKE****************************************/
    localparam int MAX_SEGMENTS = 30;
    logic inside_snake [0:(MAX_SEGMENTS - 1)];
    logic [9:0] length;
    assign length = current_score + 10'd1;
    logic [4:0] seg_x, seg_y;
    int offset = 0;

    always_comb begin
        for (int k = 0; k < MAX_SEGMENTS; k++) begin
            inside_snake[k] = 1'b0;
        end
        
        offset        = 0;      // ← fixes latch
        seg_x         = 5'd0;
        seg_y         = 5'd0;

        for (int i = 0; i < MAX_SEGMENTS; i++) begin
            if (i < length) begin
                offset = i * 10;
                seg_x = all_coords[(offset + 9):(offset + 5)];
                seg_y = all_coords[(offset + 4):offset];

                if (col >= seg_x*20 && col < (seg_x*20 + SIZE) &&
                    row >= seg_y*20 && row < (seg_y*20 + SIZE)) begin
                        inside_snake[i] = 1'b1;
                end   
            end
        end
    end
        
/**********************************STRIPES*************************************/
    localparam STRIPE_COL = 25;
    localparam STRIPE_X0 = STRIPE_COL * SIZE;
    
    logic inside_stripe;
    
    assign inside_stripe =
        (col >= STRIPE_X0) &&
        (col <  STRIPE_X0 + SIZE);

    localparam STRIPE_COL_LEFT = 0;
    localparam STRIPE_COL_LEFT_X = STRIPE_COL_LEFT*SIZE; //useless bc it's zero

    logic inside_stripe_left;
    assign inside_stripe_left =
        (col >= STRIPE_COL_LEFT_X) &&
        (col <  STRIPE_COL_LEFT_X + SIZE);

    localparam STRIPE_TOP = 0; //y coord (row)
    localparam STRIPE_TOP_Y = STRIPE_TOP*SIZE; //useless bc it's zero
    localparam STRIPE_limit = 25*20;
    logic inside_stripe_top;
    assign inside_stripe_top =
        (row >= STRIPE_TOP_Y) &&
        (row <  STRIPE_TOP_Y + SIZE) &&
        (col > 0) &&
        (col < STRIPE_limit);

    localparam STRIPE_BOTTOM = 23; //y coord (row)
    localparam STRIPE_BOTTOM_Y = STRIPE_BOTTOM*SIZE; //useless bc it's zero
    logic inside_stripe_bottom;
    assign inside_stripe_bottom =
        (row >= STRIPE_BOTTOM_Y) &&
        (row <  STRIPE_BOTTOM_Y + SIZE) &&
        (col > 0) &&
        (col < STRIPE_limit);


/********************************SCORE_DISPLAY (label)*************************/
    localparam SCORE_X0 = 26;   
    localparam SCORE_Y0 = 2;   
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
        (col >= SCORE_X0*20 + 10) &&
        (col <  SCORE_X0*20 + 10 + SCORE_SIZE_X) &&
        (row >= SCORE_Y0*20) &&
        (row <  SCORE_Y0*20 + SCORE_SIZE_Y);

    // Compute local coordinates
    always_comb begin
        x_in_score = col - SCORE_X0*20 - 10;
        y_in_score = row - SCORE_Y0*20;
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
        // Default background color
        RGB = 6'd0;

        // HIGHEST PRIORITY: game over
        // if (valid) begin
            if (valid && state == 4'b0110)
                RGB = rom_data_gameover;  // red

            // Next priority: score display
            else if (valid && inside_score)
                RGB = rom_data_score;

            // Stripe right
            else if (valid && inside_stripe)
                RGB = 6'b11_1111;  // white
            else if (valid && inside_stripe_left)
                RGB = 6'b11_1111;  // white             RGB = 6'b11_1111;  // white 
            else if (valid && inside_stripe_top)
                RGB = 6'b11_1111;  // white 
            else if (valid && inside_stripe_bottom)
                RGB = 6'b11_1111;  // white 

            // else if (valid && inside_apple1) 
            //     RGB = rom_data;
                       
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
            else if (valid && inside_apple1 && !apple_signal)
                RGB = rom_data;   // apple

            else begin
                if(valid) begin
                        for (int i = 0; i < MAX_SEGMENTS; i++) begin
                            if (i < length && inside_snake[i]) begin
                                if (i % 5 == 0)      RGB = 6'b00_1100;
                                else if (i % 5 == 1) RGB = 6'b11_0000;
                                else if (i % 5 == 2) RGB = 6'b00_0011;
                                else if (i % 5 == 3) RGB = 6'b11_1100;
                                else if (i % 5 == 4) RGB = 6'b00_1111;
                            end 
                        end
                end
            end
    end

endmodule