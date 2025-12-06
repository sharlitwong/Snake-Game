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
        .GREEN_X0(GREEN_X0),
        .GREEN_Y0(GREEN_Y0),
        .APPLE1_X0(APPLE1_X0),
        .APPLE1_Y0(APPLE1_Y0),
        .current_score(current_score),
        .state(state),

        //test
        // .nes_data(nes_dir),
        
        //output: RGB
        .RGB(RGB),      
    );


/**************************************NES*************************************/
    // logic [2:0] nes_dir;
   
    //data read from nes
    // nes_read my_nes (
    //     .data (nes_data_pin),
    //     .nes_data(nes_dir),
    //     .clock(nes_clock),
    //     .clk(clock_in),
    //     .latch(nes_latch)    
    // );

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


    assign outside_frame =
    (GREEN_X0 >= 24*20) ||   // X >= 480
    (GREEN_Y0 >= 24*20) ||
    (GREEN_X0 <= 0) ||
    (GREEN_Y0 <= 0);     // Y >= 480

    //State encodings
    typedef enum logic [2:0] {
        UP          = 3'b000,
        DOWN        = 3'b001,
        LEFT        = 3'b010,
        RIGHT       = 3'b011,
        WAITING     = 3'b111,
        GAME_OVER   = 3'b110,
        EAT_APPLE   = 3'b101
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
        // end
    end

    // logic [2:0] save_prev;
    
    //next_state logic
    always_comb begin
        next_state = state; //for default
        // save_prev = ;
        //logic to set next state to be something
        // if (nes_dir == 3'b111)
        if (button_start)
            next_state = WAITING;

        // Eat
        else if (apple_signal) begin
            next_state = EAT_APPLE;
            // save_prev = state;
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
        // end else if (state == EAT_APPLE) begin
            // next_state = save_prev;
        end else begin
            next_state = state;
            // save_prev = 
        end
        
            // case (nes_dir)
            //     UP   :      if (state != DOWN) next_state = UP;
            //     DOWN :      if (state != UP) next_state = DOWN;
            //     LEFT :      if (state != RIGHT) next_state = LEFT;
            //     RIGHT:      if (state != LEFT) next_state = RIGHT;
            //     default:    next_state = state; //null input
            // endcase
    end

    //curr_state logic
    always_comb begin 
        // if (apple_signal) begin
        //         //score updates
        //         next_score = current_score + 1;

        //         //apple position update
        //         next_APPLE1_X0 = new_APPLE1_X0 * 20;
        //         next_APPLE1_Y0 = new_APPLE1_Y0 * 20;
        //         next_GREEN_X0  = GREEN_X0;
        //         next_GREEN_Y0  = GREEN_Y0;
        // end
        case(state)
            EAT_APPLE: begin
                //score updates
                next_score = current_score + 1;

                //apple position update
                next_APPLE1_X0 = new_APPLE1_X0 * 20;
                next_APPLE1_Y0 = new_APPLE1_Y0 * 20;

                next_GREEN_X0  = GREEN_X0;
                next_GREEN_Y0  = GREEN_Y0;
            end
            
            GAME_OVER: begin
                next_GREEN_X0  = GREEN_X0;
                next_GREEN_Y0  = GREEN_Y0;
                next_APPLE1_X0 = APPLE1_X0;
                next_APPLE1_Y0 = APPLE1_Y0;
                next_score     = current_score;
            end

            WAITING: begin
                //set snake position to original
                next_GREEN_X0 = 10'd200;
                next_GREEN_Y0 = 10'd200;

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
            end
            DOWN: begin
                next_GREEN_Y0 = GREEN_Y0 + 20;
                next_GREEN_X0  = GREEN_X0;
                next_APPLE1_X0 = APPLE1_X0;
                next_APPLE1_Y0 = APPLE1_Y0;
                next_score     = current_score;
            end
            LEFT: begin
                next_GREEN_X0 = GREEN_X0 - 20; 
                next_GREEN_Y0  = GREEN_Y0;
                next_APPLE1_X0 = APPLE1_X0;
                next_APPLE1_Y0 = APPLE1_Y0;
                next_score     = current_score;
            end
            RIGHT: begin
                next_GREEN_X0 = GREEN_X0 + 20;
                next_GREEN_Y0  = GREEN_Y0;
                next_APPLE1_X0 = APPLE1_X0;
                next_APPLE1_Y0 = APPLE1_Y0;
                next_score     = current_score;
            end
            
            default: //defaults
                begin
                    next_GREEN_X0  = GREEN_X0;
                    next_GREEN_Y0  = GREEN_Y0;
                    next_APPLE1_X0 = APPLE1_X0;
                    next_APPLE1_Y0 = APPLE1_Y0;
                    next_score     = current_score;
                end
        endcase
    end

endmodule