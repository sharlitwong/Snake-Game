module nes_read (
    input logic data,
    output logic [2:0] nes_data,
    output logic reset,
    output logic clock, 
    output logic latch    
);

    logic NESclk;
    logic [11:0] NEScount;
    logic clk;
    logic [7:0] temp_data_out;
    logic [7:0] data_out;

    // Store previous direction
    // logic [1:0] last_dir;

    // Internal reset default
    assign reset = 1'b0;
    // assign last_dir = 2'b11;

    // SB_HFOSC #(
    //     .CLKHF_DIV("0b00")  
    // ) osc (
    //     .CLKHFPU(1'b1),      
    //     .CLKHFEN(1'b1),      
    //     .CLKHF(clk)      
    // );

    SB_HFOSC #(
    .CLKHF_DIV("0b00")   
    ) osc (
        .CLKHFPU(1'b1),      
        .CLKHFEN(1'b1),      
        .CLKHF(clk),
        .TRIM0(1'b0), 
        .TRIM1(1'b0),
        .TRIM2(1'b0),
        .TRIM3(1'b0),
        .TRIM4(1'b0),
        .TRIM5(1'b0),
        .TRIM6(1'b0),
        .TRIM7(1'b0),
        .TRIM8(1'b0),   
        .TRIM9(1'b0)      
    );
    
    logic [20:0] counter = 21'd0;

    always_ff @(posedge clk) begin
        counter <= counter + 1;
    end

    assign NESclk = counter[8];
    assign NEScount = counter[16:9];
    assign latch = NEScount == 8'hFF;
    assign clock = (NESclk < 8'h08) ? NESclk : 1'b0;


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

//variable 1 if signal, 0 if no signal

    always_comb begin
        case(data_out)
        8'b00001000: nes_data = 3'b000; // up
        8'b00000100: nes_data = 3'b001; // down
        8'b00000010: nes_data = 3'b010; // left
        8'b00000001: nes_data = 3'b011; // right
        8'b00010000: nes_data = 3'b111; // reset
        default: nes_data = 3'b100; //idle
        endcase
    end


// Decode NES output → direction
    // always_ff @(posedge clock) begin
    //     // default: keep last direction unless overridden
    //     nes_data <= last_dir;

    //     case(data_out)
    //         8'b00001000: begin  // up
    //             nes_data <= 2'b00;
    //             last_dir <= 2'b00;
    //         end

    //         8'b00000100: begin // down
    //             nes_data <= 2'b01;
    //             last_dir <= 2'b01;
    //         end

    //         8'b00000010: begin // left
    //             nes_data <= 2'b10;
    //             last_dir <= 2'b10;
    //         end

    //         8'b00000001: begin // right
    //             nes_data <= 2'b11;
    //             last_dir <= 2'b11;
    //         end

    //         8'b00010000: begin // reset detected
    //             // pulse reset high
    //             // user-defined behavior, often resetting last_dir
    //             // example: set default direction
    //             last_dir <= last_dir;
    //         end

    //         default: begin
    //             // No button pressed → maintain previous direction
    //             nes_data <= last_dir;
    //         end
    //     endcase
    // end

endmodule