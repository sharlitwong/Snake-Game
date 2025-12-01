module ramdp #(
parameter WORD_SIZE = 8,
parameter N_WORDS = 576, //24 x 24
parameter ADDR_WIDTH = 10) (

input logic clk,
input logic [ADDR_WIDTH - 1:0] r_addr,
output logic [WORD_SIZE - 1:0] r_data,
input logic [ADDR_WIDTH - 1:0] w_addr,
input logic [WORD_SIZE - 1:0] w_data,
input logic w_enable,
input logic [ADDR_WIDTH-1:0] vga_r_addr,
output logic [WORD_SIZE-1:0] vga_r_data );

logic [WORD_SIZE-1:0] mem [0:N_WORDS-1];
// single clocked block: write + 2 reads
always_ff @(posedge clk) begin
// write from game side
if (w_enable) begin
mem[w_addr] <= w_data;
end

// synchronous reads
r_data <= mem[r_addr];
r_data <= mem[vga_r_addr];

end
endmodule