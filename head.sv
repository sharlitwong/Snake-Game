module head (
    input logic [1:0] input_dir,
    input logic reset,
    input logic game_clk,
    output logic [1:0] move_dir
);

always_ff @(posedge game_clk) begin
    //do something
end

    
always_comb begin
    //do something
end

endmodule