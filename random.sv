// generates a random position for the apple using the current position and the
// counter number.

module random (
    input logic signal,
    output logic [9:0] newfood_H,
    output logic [9:0] newfood_V
);

    logic [9:0] lfsr_H = 10'b1;   // cannot start at 0
    logic [9:0] lfsr_V = 10'b101; // a different seed

    always_ff @(posedge signal) begin
        // taps for maximal-length 10-bit LFSR: x^10 + x^7 + 1 
        lfsr_H <= {lfsr_H[8:0], lfsr_H[9] ^ lfsr_H[6]};
        lfsr_V <= {lfsr_V[8:0], lfsr_V[9] ^ lfsr_V[6]};
    end

    // Convert to grid coordinate 0–23
    assign newfood_H = lfsr_H % 24;
    assign newfood_V = lfsr_V % 24;

endmodule