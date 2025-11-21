module count(
    input logic clk,
    output logic[25:0] counter
);
    always_ff @(posedge clk) begin
        if(counter == 26'h3FFFFFF) counter <= 26'b0;
        else counter <= counter + 1;
    end
endmodule