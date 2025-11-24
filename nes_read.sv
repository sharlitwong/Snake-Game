module nes_read (
    input logic data,
    output logic [7:0] data_out
);
    //Devanshi's NES code
    logic NESclk;
    logic [11:0] NEScount;
    logic clk;
    logic [7:0] temp_data_out;
    logic clock;
    logic latch;

    logic [20:0] counter = 21'd0;

    always_ff @(posedge clk) begin
        counter <= counter + 1;
    end

    assign NESclk = counter[8];
    assign NEScount = counter[16:9];
    assign latch = NEScount == 8'hFF;
    assign clock = (NESclk < 8'h08) ? NESclk : 1'b0;

    always_ff @(posedge clock) begin
        temp_data_out [0] <= data;
        temp_data_out [1] <= temp_data_out [0];
        temp_data_out [2] <= temp_data_out [1];
        temp_data_out [3] <= temp_data_out [2];
        temp_data_out [4] <= temp_data_out [3];
        temp_data_out [5] <= temp_data_out [4];
        temp_data_out [6] <= temp_data_out [5];
        temp_data_out [7] <= temp_data_out [6];

        if (NEScount == 8)
            data_out <= ~temp_data_out;
    end
endmodule