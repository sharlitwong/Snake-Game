module top (
    //VGA clock
    input logic clock_in,   //12MHz
    output logic clock_out,

    //VGA
    output logic HSYNC,
    output logic VSYNC,
    output logic [5:0] RGB,

    //NES 
    output logic nes_latch,
    output logic nes_clock,
    input logic nes_data_pin, // actual FPGA pin from controller
);

/******************************CLOCKS******************************************/
    //pll clock for VGA display: 25.2MHz
    mypll my_pll (
        .clock_in(clock_in),
        .clock_out(clock_out)
    );

    //GAME CLOCK
    //initiate game clock
    logic [21:0] counter;
    logic game_clk;

    //game clock for game: 8Hz
    game_clk my_game_clk (
        .vga_clk(clock_out),
        .count(counter),
        .game_clk(game_clk)
    );

/*******************************VGA & DISPLAYING*******************************/
    logic [9:0] row, col;
    logic valid;

    //VGA SYNC Configuration
    vga my_vga (
        .clk(clock_out),
        .HSYNC(HSYNC),
        .VSYNC(VSYNC),
        .col(col),
        .row(row),
        .valid(valid)
    );

    //instantiate my game_display
    game_display my_display (
        //inputs: vga_clk, row, col, valid, snake position, food position, score, state (useful for game over)
        .clk(clock_out),
        .row(row),
        .col(col),
        .valid(valid),
        // .GREEN_X0(GREEN_X0),
        // .GREEN_Y0(GREEN_Y0),
        .APPLE1_X0(APPLE1_X0),
        .APPLE1_Y0(APPLE1_Y0),
        .current_score(current_score),
        .all_coords(all_coords),
        .state(state),
        
        //output: RGB
        .RGB(RGB),      
    );


/**************************************NES*************************************/
        logic [7:0] buttons;
        logic button_up;
        logic button_down;
        logic button_left;
        logic button_right;
        logic button_select;
        logic button_start;
        logic button_B;
        logic button_A; 

    nes_read my_nes(
        .latch(nes_latch),
        .clock(nes_clock),
        .buttons(buttons),
        .button_up(button_up),
        .button_down(button_down),
        .button_left(button_left),
        .button_right(button_right),
        .button_select(button_select),
        .button_start(button_start),
        .button_B(button_B),
        .button_A(button_A),    
        .data(nes_data_pin),
        .clk(clock_in)
    );

/************************************RANDOM************************************/
    logic [9:0] new_APPLE1_X0, new_APPLE1_Y0; //coordinates within 24x24 grid of superpixels
    
    //module to generate random apple positions
    random my_random (
        .signal(apple_signal),
        .newfood_H(new_APPLE1_X0),
        .newfood_V(new_APPLE1_Y0)
    );

/*******************************SNAKE RAM**************************************/

    // logic button_record;
    // logic [9:0] coordinates;
    // logic [2:0] addr;
    // logic enable_w;

    // assign enable_w = 
    // (state == UP) ||
    // (state == DOWN) ||
    // (state == RIGHT) ||
    // (state == LEFT);
    
    //modify coordinates based on coordinates of the block before it
    //What we have: head coordinates: GREEN_X0, GREEN_Y0

    //original coordinate

    //how to know coordinates of a block:
    //SIZE = 20
    //head: coordinates of head: GREEN_X0 = 10'd200, GREEN_Y0 = 10'200
    //segment1: GREEN_X1 = GREEN_X0 - SIZE * 1, GREEN_Y1 = GREEN_Y0
    //segment2: GREEN_X2 = GREEN_X0 - SIZE * 2, GREEN_Y2 = GREEN_Y0
    //segment3: GREEN_X3 = GREEN_X0 - SIZE * 3, GREEN_Y3 = GREEN_Y0
    //segment4: GREEN_X4 = GREEN_X0 - SIZE * 4, GREEN_Y3 = GREEN_Y0
    //segment5: GREEN_X5 = GREEN_X0 - SIZE * 5, GREEN_Y3 = GREEN_Y0

    //WHILE MOVING (shift reg: shift_reg <= {shift_reg[6:0], data};)
    logic [99:0] all_coords; //like our ram (10 bits per coord, 5 coords)
    
    //WHILE MOVING (shift reg: all_coords <= {all_coords[39:0], [GREEN_X0, GREEN_Y0]};)
    // GREEN_X0 <= new_GREEN_X0
    // GREEN_X1 <= GREEN_X0
    // GREEN_X2 <= GREEN_X1
    // GREEN_X3 <= GREEN_X2
    //same for y

    // logic [49:0] all_coords;
    // always_ff @(game_clk) begin
    //     all_coords <= {all_coords[39:0], [GREEN_X0, GREEN_Y0]};
    // end

    // snake #(
    //     .WORD_SIZE (10),
    //     .N_WORDS (5),
    //     .ADDR_WIDTH (3)
    // )ramdp(
    //     .w_data (coordinates), //encoded data (coordinates)
    //     .r_data (coordinates), //encoded data (coordinates)
    //     .r_addr (addr), //which segment of the snake we're at 0-4
    //     .w_addr (addr), //which segment of the snake we're at 0-4
    //     .w_enable (enable_w), //only true when up, down, left, right //pending: eat apple
    //     .clk (game_clk) //vga_clk
    // );

/*******************************STATE MACHINE**********************************/
//inputs for state machine
    //nes_dir (initialized in NES)

//outputs for state machine
    //move_dir (input for display)
    // logic [2:0] move_dir;

    //snake position
    logic [9:0] GREEN_X0;
    logic [9:0] GREEN_Y0;

    //food position
    logic [9:0] APPLE1_X0;
    logic [9:0] APPLE1_Y0;

    //score
    logic [9:0] current_score;

    //signal apple
    logic apple_signal; 

    assign apple_signal = 
    (GREEN_X0 == APPLE1_X0) &&   
    (GREEN_Y0 == APPLE1_Y0);

//internal variable
    //new apple positions (initialized in RANDOM)
    //out of bound check
    logic outside_frame;
    logic [9:0] next_GREEN_X0, next_GREEN_Y0;
    logic [9:0] next_APPLE1_X0, next_APPLE1_Y0; //ACTUAL on 640x480 coordinates of apple
    logic [9:0] next_score;
    logic [99:0] next_all_coords;


    assign outside_frame =
    (GREEN_X0 >= 24*20) ||   // X >= 480
    (GREEN_Y0 >= 24*20) ||
    (GREEN_X0 <= 0) ||
    (GREEN_Y0 <= 0);     // Y >= 480

    //State encodings
    typedef enum logic [3:0] {
        UP              = 4'b0000,
        DOWN            = 4'b0001,
        LEFT            = 4'b0010,
        RIGHT           = 4'b0011,
        WAITING         = 4'b0111,
        GAME_OVER       = 4'b0110,
        EAT_APPLE_UP    = 4'b1000,
        EAT_APPLE_DOWN  = 4'b1001,
        EAT_APPLE_LEFT  = 4'b1010,
        EAT_APPLE_RIGHT = 4'b1011
    } state_t;

    //Initialize curr state and next state
    state_t state, next_state;

    //update flipflops
    always_ff @(posedge game_clk) begin
            state <= next_state;
            GREEN_X0      <= next_GREEN_X0;
            GREEN_Y0      <= next_GREEN_Y0;
            APPLE1_X0     <= next_APPLE1_X0;
            APPLE1_Y0     <= next_APPLE1_Y0;
            current_score <= next_score;
            // all_coords <= {all_coords[39:0], next_GREEN_X0, next_GREEN_Y0};
            all_coords <= next_all_coords;
        // end
    end
    
    //next_state logic
    always_comb begin
        next_state = state; //for default

        //logic to set next state to be something
        if (button_start)
            next_state = WAITING;

        // Eat
        else if (apple_signal) begin
            case (state) 
                UP:     next_state = EAT_APPLE_UP;
                DOWN:   next_state = EAT_APPLE_DOWN;
                LEFT:   next_state = EAT_APPLE_LEFT;
                RIGHT:  next_state = EAT_APPLE_RIGHT;
            endcase
        end

        //Die
        else if (outside_frame)
            next_state = GAME_OVER;
        
        //Moving 
        else if (button_up) begin
            if (state != DOWN) next_state = UP;
        end else if (button_down) begin
            if (state != UP) next_state = DOWN;
        end else if (button_left) begin
            if (state != RIGHT) next_state = LEFT;
        end else if (button_right) begin
            if (state != LEFT) next_state = RIGHT;
        end else if (state == EAT_APPLE_UP)
            next_state = UP;
        else if (state == EAT_APPLE_DOWN)
            next_state = DOWN;        
        else if (state == EAT_APPLE_LEFT)
            next_state = LEFT;
        else if (state == EAT_APPLE_RIGHT)
            next_state = RIGHT;
        else
            next_state = state;
        
    end

    //curr_state logic
    always_comb begin 
        case(state)
            EAT_APPLE_UP: begin
                //score updates
                next_score = current_score + 1;

                //apple position update
                next_APPLE1_X0 = new_APPLE1_X0 * 20;
                next_APPLE1_Y0 = new_APPLE1_Y0 * 20;

                next_GREEN_X0  = GREEN_X0;
                next_GREEN_Y0  = GREEN_Y0;

                next_all_coords = all_coords;
            end

            EAT_APPLE_DOWN: begin
                //score updates
                next_score = current_score + 1;

                //apple position update
                next_APPLE1_X0 = new_APPLE1_X0 * 20;
                next_APPLE1_Y0 = new_APPLE1_Y0 * 20;

                next_GREEN_X0  = GREEN_X0;
                next_GREEN_Y0  = GREEN_Y0;

                next_all_coords = all_coords;
            end

            EAT_APPLE_LEFT: begin
                //score updates
                next_score = current_score + 1;

                //apple position update
                next_APPLE1_X0 = new_APPLE1_X0 * 20;
                next_APPLE1_Y0 = new_APPLE1_Y0 * 20;

                next_GREEN_X0  = GREEN_X0;
                next_GREEN_Y0  = GREEN_Y0;

                next_all_coords = all_coords;
            end

            EAT_APPLE_RIGHT: begin
                //score updates
                next_score = current_score + 1;

                //apple position update
                next_APPLE1_X0 = new_APPLE1_X0 * 20;
                next_APPLE1_Y0 = new_APPLE1_Y0 * 20;

                next_GREEN_X0  = GREEN_X0;
                next_GREEN_Y0  = GREEN_Y0;

                next_all_coords = all_coords;
            end
            
            GAME_OVER: begin
                next_GREEN_X0  = GREEN_X0;
                next_GREEN_Y0  = GREEN_Y0;
                next_APPLE1_X0 = APPLE1_X0;
                next_APPLE1_Y0 = APPLE1_Y0;
                next_score     = current_score;
                
                next_all_coords = all_coords;
            end

            WAITING: begin
                //set snake position to original
                next_GREEN_X0 = 10'd200;
                next_GREEN_Y0 = 10'd200;
                
                next_all_coords = 
                    {10'd120, 10'd200, 
                    10'd140, 10'd200, 
                    10'd160, 10'd200, 
                    10'd180, 10'd200,
                    10'd200, 10'd200}; //least signif (head)


                //SET APPLE ORIGIN
                next_APPLE1_X0 = 10'd300;
                next_APPLE1_Y0 = 10'd200;

                //score to 0
                next_score = 10'd0;
            end

            UP: begin
                next_GREEN_Y0 = GREEN_Y0 - 20;
                next_GREEN_X0  = GREEN_X0;
                next_APPLE1_X0 = APPLE1_X0;
                next_APPLE1_Y0 = APPLE1_Y0;
                next_score     = current_score;
                next_all_coords = {all_coords[79:0], next_GREEN_X0, next_GREEN_Y0};
            end
            DOWN: begin
                next_GREEN_Y0 = GREEN_Y0 + 20;
                next_GREEN_X0  = GREEN_X0;
                next_APPLE1_X0 = APPLE1_X0;
                next_APPLE1_Y0 = APPLE1_Y0;
                next_score     = current_score;
                next_all_coords = {all_coords[79:0], next_GREEN_X0, next_GREEN_Y0};
            end
            LEFT: begin
                next_GREEN_X0 = GREEN_X0 - 20; 
                next_GREEN_Y0  = GREEN_Y0;
                next_APPLE1_X0 = APPLE1_X0;
                next_APPLE1_Y0 = APPLE1_Y0;
                next_score     = current_score;
                next_all_coords = {all_coords[79:0], next_GREEN_X0, next_GREEN_Y0};
            end
            RIGHT: begin
                next_GREEN_X0 = GREEN_X0 + 20;
                next_GREEN_Y0  = GREEN_Y0;
                next_APPLE1_X0 = APPLE1_X0;
                next_APPLE1_Y0 = APPLE1_Y0;
                next_score     = current_score;
                next_all_coords = {all_coords[79:0], next_GREEN_X0, next_GREEN_Y0};
            end                         
 
            default: //defaults
                begin
                    next_all_coords = all_coords;
                    next_GREEN_X0  = GREEN_X0;
                    next_GREEN_Y0  = GREEN_Y0;
                    next_APPLE1_X0 = APPLE1_X0;
                    next_APPLE1_Y0 = APPLE1_Y0;
                    next_score     = current_score;
                end
        endcase
    end

endmodule