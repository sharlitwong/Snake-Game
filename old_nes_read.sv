// // module nes_read (
// //     input  logic clk,         // real FPGA clock
// //     input  logic data,        // NES DATA
// //     output logic latch,       // NES LATCH
// //     output logic clock,       // NES CLOCK (ungated, clean)
// //     output logic [2:0] nes_data
// // );

// //     //============================================================
// //     // Clock divider
// //     //============================================================
// //     logic [18:0] counter;

// //     always_ff @(posedge clk) begin
// //         counter <= counter + 1;
// //     end

// //     // clean NES clock
// //     logic nesclk_reg;
// //     always_ff @(posedge clk)
// //         nesclk_reg <= counter[8];

// //     assign clock = nesclk_reg;

// //     // clean latch pulse: goes high for entire cycle of counter[9:0] == 0
// //     assign latch = (counter[9:0] == 10'd0);

// //     //============================================================
// //     // Shift register for 8 NES bits
// //     //============================================================
// //     logic [7:0] shiftreg;
// //     logic [3:0] bitcount;

// //     always_ff @(posedge clk) begin
// //         // rising edge detect of nesclk
// //         logic nesclk_prev;
// //         nesclk_prev <= nesclk_reg;

// //         if (latch) begin
// //             bitcount <= 0;
// //         end
// //         else if (~nesclk_prev && nesclk_reg) begin  // rising edge NESCLK
// //             if (bitcount < 8) begin
// //                 shiftreg <= {shiftreg[6:0], data};
// //                 bitcount <= bitcount + 1;
// //             end
// //         end
// //     end

// //     logic [7:0] data_out = ~shiftreg;  // NES uses active-low

// //     //============================================================
// //     // Decode
// //     //============================================================
// //     always_comb begin
// //         nes_data = 3'b111; // waiting

// //         if      (data_out[3]) nes_data = 3'b000; // up
// //         else if (data_out[2]) nes_data = 3'b001; // down
// //         else if (data_out[1]) nes_data = 3'b010; // left
// //         else if (data_out[0]) nes_data = 3'b011; // right
// //     end

// // endmodule


// module nes_read (
//     input logic data,
//     output logic [2:0] nes_data,
//     output logic clock, 
//     input logic clk,
//     output logic latch    
// );

//     logic NESclk;
//     // logic [11:0] NEScount;
//     logic [9:0] NEScount;
//     // logic clk;
//     logic [7:0] temp_data_out;
//     logic [7:0] data_out;

//     // logic [7:0] temp_data_out = 8'h00;
//     // logic [7:0] data_out = 8'h00;
//     // logic [3:0] bit_idx;
//     // logic latch_q;

//     // SB_HFOSC #(
//     //     .CLKHF_DIV("0b00")  
//     // ) osc (
//     //     .CLKHFPU(1'b1),      
//     //     .CLKHFEN(1'b1),      
//     //     .CLKHF(clk)      
//     // );
    
//     logic [18:0] counter = 18'd0;

//     always_ff @(posedge clk) begin
//         counter <= counter + 1;
//     end

//     assign NESclk = counter[8];
//     assign NEScount = counter[9:0];
//     assign latch = (NEScount == 0);
//     // assign latch = (NEScount == 8'h00);
//     // assign clock = (NESclk < 8'h08) ? NESclk : 1'b0; //?
//     // assign clock    = NESclk;  
//     assign clock = (NEScount > 0 && NEScount < 9) ? NESclk : 1'b0;


//     always_ff @(posedge clock) begin
//         if (latch) begin
//             // temp_data_out <= 8'h00;
//             temp_data_out <= 8'b0;
//         end else if (NEScount > 0 && NEScount < 9) begin
//             // temp_data_out [0] <= data;
//             // temp_data_out [1] <= temp_data_out [0];
//             // temp_data_out [2] <= temp_data_out [1];
//             // temp_data_out [3] <= temp_data_out [2];
//             // temp_data_out [4] <= temp_data_out [3];
//             // temp_data_out [5] <= temp_data_out [4];
//             // temp_data_out [6] <= temp_data_out [5];
//             // temp_data_out [7] <= temp_data_out [6];
//             temp_data_out <= {temp_data_out[6:0], data};
//         end

//         // if (NEScount == 8'd8)
//         if (NEScount == 9)
//             data_out <= ~temp_data_out;
//     end

//     always_comb begin
//         case(data_out)
//         8'b00001000: nes_data = 3'b000; // up
//         8'b00000100: nes_data = 3'b001; // down
//         8'b00000010: nes_data = 3'b010; // left
//         8'b00000001: nes_data = 3'b011; // right
//         8'b00010000: nes_data = 3'b111; // waiting
//         default:     nes_data = 3'b100; // kinda like idle
//         endcase
//     end
// endmodule
