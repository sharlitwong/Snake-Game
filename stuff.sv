module stuff (
    input logic [4:0] food_H,
    input logic [4:0] food_V,

    output logic [4:0] snake_H,
    output logic [4:0] snake_V,
);
    //HORIZONTAL: WHICH ROW (Y); VERTICAL: WHICH COL (X)

    int superpixels[24][24]; //2 bits, apple/snake/blank/wall
    int screenpixels[640][480]; //sth for colors
    logic [4:0] super_H, super_V; //to index all the superpixels
    logic [4:0] pixel_H, pixel_V; //to index each pixel in a superpixel.

    always_ff @(posedge fast_clk) begin
        for (super_H = 0; super_H < 24; super_H++) begin
            for (super_V = 0; super_V < 24; super_V++) begin
                int offsetV = super_V * 20;
                int offsetH = super_H * 20; 

                switch(superpixels[super_H][super_V]) {
                    //if r == food_H and c == food_V then superpixel is apple 01
                    //check if apple position
                    if (super_H == food_H && super_V == food_V) begin
                        superpixels[super_H][super_V] == 2'b10;
                    
                    //check if snake position
                    end else if (super_H == snake_H && super_V == snake_V) begin
                        superpixels[super_H][super_V] == 2'b01;
                    
                    //check if wall position


                    //others are blank
                    end else begin
                        superpixels[super_H][super_V] == 2'b00;
                    end
                }

                //in snake
                if (superpixels[super_H][super_V] == 2'b01) begin
                    for (pixel_H = 0; pixel_H < 20; pixel_H++) begin
                        for (pixel_V = 0; pixel_V < 20; pixel_V++) begin
                        screenpixels[pixel_H + offsetH][pixel_V + offsetV] = 6'b001100;
                        end
                    end

                end else if (superpixels[super_H][super_V] == 2'b10) begin
                    //...
                end
            end
        end
    end

assign vga_r_addr = 

endmodule




superpixels[rows][cols]

screenpixels[640][480]

for(r = 0 ; r < rows; ++r){
    for(c = 0; c < cols; ++c){
        int offsetX = c * 20;
        int offsetY = r * 20;
        switch(superpixels[r][c]){
            //if r == food_H and c == food_V then superpixel is apple 01
            //if r == snke_H and c  == snake_V then
            //else blank
        }
        if(superpixels[r][c] == 1){
            for(r2 = 0; r2 < 20; ++r2){
                ...{
                    screenpixels[r2 + offsetY][c2 + offsetX] = apple[r2][c2];
                }
            }
        }
    }
}

//if out of bound ...end: game logic

