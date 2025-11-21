//test count module for moving apple
module count(
    input logic clk,
    output logic[22:0] counter
);
    always_ff @(posedge clk) begin
        if(counter == 23'h3FFFFF) counter <= 23'b0;
        else counter <= counter + 1;
    end
endmodule