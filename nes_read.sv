module nes_read (
    input logic data,
    output logic [1:0] nes_data,
    output logic reset,
    output logic clock, 
    output logic latch    
);

    logic NESclk;
    logic [11:0] NEScount;
    logic clk;
    logic [7:0] temp_data_out;
    logic [7:0] data_out;

    SB_HFOSC #(
        .CLKHF_DIV("0b00")  
    ) osc (
        .CLKHFPU(1'b1),      
        .CLKHFEN(1'b1),      
        .CLKHF(clk)      
    );

    logic [20:0] counter = 21'd0;

    always_ff @(posedge clk) begin
        counter <= counter + 1;
    end

    assign NESclk = counter[8];
    assign NEScount = counter[16:9];
    //assign latch = NEScount == 8'hFF;
    assign clock = (NESclk < 8'h08) ? NESclk : 1'b0;

    always_ff @(posedge clock) begin
        latch <= 8'h1;
    end

    always_ff @(negedge clock) begin
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


    always_comb begin
        case(data_out)
        8'b00001000: nes_data = 2'b00; // up
        8'b00000100: nes_data = 2'b01; // down
        8'b00000010: nes_data = 2'b10; // left
        8'b00000001: nes_data = 2'b11; // right
        8'b00010000: reset = 1'b1; // reset
        endcase
    end



endmodule