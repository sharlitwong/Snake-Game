//

superpixels[rows][cols]

screenpixels[640][480]

for(r = 0 ; r < rows; ++r){
    for(c = 0; c < cols; ++c){
        int offsetX = c * 20;
        int offsetY = r * 20;
        switch(superpixels[r][c]){
            
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