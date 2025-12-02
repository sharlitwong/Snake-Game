//Finite state machine logic for head movement
//Inputs: [1:0] in_dir is user's input direction
//       C: no_signal_change bool, ie. 1 when no input received, and 0 otherwise
//       reset, game_clk
//Outputs: [1:0]move_dir: the direction the snake should move towards

module head (
    input logic [1:0] in_dir,
    input logic C,
    // input logic reset,
    input logic game_clk,
    output logic [1:0] move_dir
);

typedef enum logic [1:0] {
    UP    = 2'b00,
    DOWN  = 2'b01,
    LEFT  = 2'b10,
    RIGHT = 2'b11
} dir_t;

dir_t state, next_state;

always_ff @(posedge game_clk) begin
    if (reset)
        state <= RIGHT;
    else
        state <= next_state;
end
   
always_comb begin
    next_state = state;
    if (!C) begin
        case (in_dir)
            UP   : if (state != DOWN) next_state = UP;
            DOWN : if (state != UP) next_state = DOWN;
            LEFT : if (state != RIGHT) next_state = LEFT;
            RIGHT: if (state != LEFT) next_state = RIGHT;
        endcase
    end
end

assign move_dir = next_state;

endmodule