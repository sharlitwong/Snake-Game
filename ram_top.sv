module ram_top 
// #( 
// 	parameter N_CHANNELS = 2,
// 	parameter ADDR_WIDTH = 4,
//     parameter CLK_HZ = 48000000,
//     parameter SAMPLE_HZ = 100
//     ) 
    (
        input logic button_record,
        input logic [1:0] button_channel,
        output logic [1:0] led
    );

    logic game_clk;
    // logic [23:0] slow_counter;
    // logic w_en; 
    // logic [1:0] w_data;
    // logic [1:0] r_data;
    logic [2:0] addr;

    always_ff @(posedge game_clk) begin
        // slow_counter <= slow_counter + 1;
        // if (slow_counter == 24'b111111111111111111111111) begin 
        //     slow_counter <= 0;
            addr <= addr + 1;
        // end 
    end 

    snake #(
        .WORD_SIZE (10),
        .N_WORDS (5),
        .ADDR_WIDTH (3)
    )ramdp(
        .w_data (~button_channel), //encoded data (coordinates)
        .r_data (led), //encoded data (coordinates)
        .r_addr (addr), //which segment of the snake we're at 0-4
        .w_addr (addr), //which segment of the snake we're at 0-4
        .w_enable (~button_record), //only true when up, down, left, right //pending: eat apple
        .clk (game_clk) //vga_clk
    );

    //Turning clk to 48MHz --> use game clk instead
//     SB_HFOSC #(
//     .CLKHF_DIV("0b00")   
//   ) osc (
//     .CLKHFPU(1'b1),      
//     .CLKHFEN(1'b1),      
//     .CLKHF(clk),
//     .TRIM0(1'b0), 
//     .TRIM1(1'b0),
//     .TRIM2(1'b0)                                                                                                ,
//     .TRIM3(1'b0),
//     .TRIM4(1'b0),
//     .TRIM5(1'b0),
//     .TRIM6(1'b0),                  
//     .TRIM7(1'b0),
//     .TRIM8(1'b0),   
//     .TRIM9(1'b0)      
//   );
 

endmodule