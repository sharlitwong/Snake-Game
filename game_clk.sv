// Scale down the 25.2MHz clock to ~6Hz clock

module game_clk (
    input logic vga_clk,
    input logic reset,
    output logic [21:0] count,
    output logic game_clk
);

always_ff @(posedge clk) begin
    if (reset) begin
        count <= 0;
    end else begin
        count <= count + 1;
    end
end 

assign game_clk = count[21];

endmodule