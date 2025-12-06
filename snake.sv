// module snake (

// );

// typedef struct {
//     logic dir; //HORIZONTAL: 1-LEFT and 0-RIGHT; VERTICAL: 0-
//     logic [4:0] start_coord;
//     logic [4:0] end_coord;
//     logic [4:0] constant_coord;
// } instance_t;

// instance_t [] array [0:50];
// endmodule
 
module snake #(
    parameter WORD_SIZE = 10, //change to larger to encode more data (X, Y)
    parameter N_WORDS = 5, //number of segments (initial guess: 50)
    parameter ADDR_WIDTH = 3) //modify based on number of words

    (input logic clk,
    input logic [ADDR_WIDTH - 1:0] r_addr,
    output logic [WORD_SIZE - 1:0] r_data,
    input logic [ADDR_WIDTH - 1:0] w_addr,
    input logic [WORD_SIZE - 1:0] w_data,
    input logic w_enable);

    logic [WORD_SIZE-1:0] mem [0:N_WORDS-1]; //ram memory board

    //encode the data: x, y

    always @(posedge clk) begin
        if (w_enable) begin
            mem[w_addr] <= w_data;
        end
        r_data <= mem[r_addr];
    end
endmodule


