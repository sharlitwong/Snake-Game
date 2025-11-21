// generates a random position for the apple using the current position and the
// counter number.

module random (
    input logic [21:0] count,
    input logic oldfood_H,
    input logic oldfood_V,
    input logic vga_clk,
    output logic newfood_H,
    output logic newfood_V
);

always_ff @(posedge vga_clk) begin
    newfood_H <= (7 * oldfood_H + count) % 20;
    newfood_V <= (3 * oldfood_V + count) % 20;
end

endmodule