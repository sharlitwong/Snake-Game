module divide(
    input  logic [9:0] score, //technically ranges from 0-1023, but we'll only use to 576
    output logic [3:0] ones,
    output logic [3:0] tens,
    output logic [3:0] hundreds
);

    // temporary signals
    logic [9:0] rem1;
    logic [9:0] rem2;

    //ONES DIGIT (score % 10), but we want to avoid mod
    //Multiply-by-reciprocal trick to avoid division
    assign ones = (score - ((score * 10'd205) >> 11) * 10);

    // ---- TENS DIGIT ----
    assign rem1 = score / 10;  // rough divide using >> + multiply
    assign tens = (rem1 - ((rem1 * 10'd205) >> 11) * 10);

    // ---- HUNDREDS DIGIT ----
    assign rem2 = score / 10;
    assign hundreds = rem2 / 10;

endmodule
