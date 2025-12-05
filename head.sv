//Finite state machine logic for head movement
//Inputs: [1:0] in_dir is user's input direction
//       C: no_signal_change bool, ie. 1 when no input received, and 0 otherwise
//       reset, game_clk
//Outputs: [1:0]move_dir: the direction the snake should move towards

module head (
    input logic [2:0] in_dir,
    input logic game_clk,
    output logic [2:0] move_dir
);

    typedef enum logic [2:0] {
        UP    = 3'b000,
        DOWN  = 3'b001,
        LEFT  = 3'b010,
        RIGHT = 3'b011,
        IDLE  = 3'b100,
        RESET = 3'b111,
    } dir_t;

    dir_t state, next_state;

    always_ff @(posedge game_clk) begin
        if (in_dir == RESET)
            state <= RESET;
        else
            state <= next_state;
    end
    
    always_comb begin
        next_state = state;
        if (in_dir != RESET) begin
            case (in_dir)
                UP   : if (state != DOWN) next_state = UP;
                DOWN : if (state != UP) next_state = DOWN;
                LEFT : if (state != RIGHT) next_state = LEFT;
                RIGHT: if (state != LEFT) next_state = RIGHT;
                RESET: next_state = RESET;
                default: next_state = state;
            endcase
        end
    end

    assign move_dir = next_state;

endmodule