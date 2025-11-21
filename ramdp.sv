module ramdp #( 
	parameter WORD_SIZE = 8,
	parameter N_WORDS = 16,
	parameter ADDR_WIDTH = 4) (

	input logic clk,
	input logic [ADDR_WIDTH - 1:0] r_addr,
	output logic [WORD_SIZE - 1:0] r_data,
	input logic [ADDR_WIDTH - 1:0] w_addr,
	input logic [WORD_SIZE - 1:0] w_data,
	input logic w_enable );

	logic [WORD_SIZE-1:0] mem [0:N_WORDS-1];

	always @(posedge clk) begin
	  if (w_enable) begin
		mem[w_addr] <= w_data;
	  end
	  r_data <= mem[r_addr];
	end
endmodule