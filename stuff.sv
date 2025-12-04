module stuff (
    input logic fast_clk,

    input logic [4:0] food_H,
    input logic [4:0] food_V,

    output logic [4:0] snake_H,
    output logic [4:0] snake_V,

    // you will need these for VGA memory connection
    output logic [18:0] vga_r_addr,
    output logic [7:0]  vga_r_data,
    output logic        vga_r_we
);


    // 2-bit map of objects for each 20×20 superpixel
    logic [1:0] superpixels [0:23][0:23];

    // pixel buffer output (cannot exceed BRAM size → keep interface only)
    // keep the name "screenpixels" but implement as a write port
    logic [5:0] screenpixels;

    logic [4:0] super_H, super_V;
    logic [4:0] pixel_H, pixel_V;

    // offsets must be integers (SV allows int)
    int offsetH;
    int offsetV;

    // ------------------------------------------------------------
    // UPDATE SUPERPIXEL TYPE (APPLE / SNAKE / BLANK)
    // ------------------------------------------------------------
    always_ff @(posedge fast_clk) begin
        for (super_H = 0; super_H < 24; super_H++) begin
            for (super_V = 0; super_V < 24; super_V++) begin
                
                // check if apple
                if (super_H == food_H && super_V == food_V) begin
                    superpixels[super_H][super_V] <= 2'b10;

                // check if snake
                end else if (super_H == snake_H && super_V == snake_V) begin
                    superpixels[super_H][super_V] <= 2'b01;

                //wall maybe

                // blank otherwise
                end else begin
                    superpixels[super_H][super_V] <= 2'b00;
                end

            end
        end
    end


    // ------------------------------------------------------------
    // RENDER TO SCREENPIXELS MEMORY
    // ------------------------------------------------------------
    always_ff @(posedge fast_clk) begin
        for (super_H = 0; super_H < 24; super_H++) begin
            for (super_V = 0; super_V < 24; super_V++) begin
                
                offsetH = super_H * 20;
                offsetV = super_V * 20;

                // snake pixel fill
                if (superpixels[super_H][super_V] == 2'b01) begin
                    for (pixel_H = 0; pixel_H < 20; pixel_H++) begin
                        for (pixel_V = 0; pixel_V < 20; pixel_V++) begin
                            
                            // compute address
                            vga_r_addr <= (offsetV + pixel_V) * 640
                                        + (offsetH + pixel_H);

                            screenpixels = 6'b001100;  // green
                            vga_r_data   <= screenpixels;
                            vga_r_we     <= 1'b1;

                        end
                    end

                // apple pixel fill
                end else if (superpixels[super_H][super_V] == 2'b10) begin
                    for (pixel_H = 0; pixel_H < 20; pixel_H++) begin
                        for (pixel_V = 0; pixel_V < 20; pixel_V++) begin
                            vga_r_addr <= (offsetV + pixel_V) * 640
                                        + (offsetH + pixel_H);

                            screenpixels = 6'b110000;  // red
                            vga_r_data   <= screenpixels;
                            vga_r_we     <= 1'b1;
                        end
                    end

                // blank fill
                end else begin
                    for (pixel_H = 0; pixel_H < 20; pixel_H++) begin
                        for (pixel_V = 0; pixel_V < 20; pixel_V++) begin
                            vga_r_addr <= (offsetV + pixel_V) * 640
                                        + (offsetH + pixel_H);

                            screenpixels = 6'b000000;  // black
                            vga_r_data   <= screenpixels;
                            vga_r_we     <= 1'b1;
                        end
                    end
                end

            end
        end
    end

endmodule


//instatiate redapple.sv in this file
//add rampd.sv to this


// superpixels[rows][cols]

// screenpixels[640][480]

// for(r = 0 ; r < rows; ++r){
//     for(c = 0; c < cols; ++c){
//         int offsetX = c * 20;
//         int offsetY = r * 20;
//         switch(superpixels[r][c]){
//             //if r == food_H and c == food_V then superpixel is apple 01
//             //if r == snke_H and c  == snake_V then
//             //else blank
//         }
//         if(superpixels[r][c] == 1){
//             for(r2 = 0; r2 < 20; ++r2){
//                 ...{
//                     screenpixels[r2 + offsetY][c2 + offsetX] = apple[r2][c2];
//                 }
//             }
//         }
//     }
// }

//if out of bound ...end: game logic

