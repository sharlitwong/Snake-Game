module vga(
    input logic clk,
    output logic HSYNC,
    output logic VSYNC,
    output logic [9:0] col,
    output logic [9:0] row,
    output logic valid
);

    int col_int = 0, row_int = 0;

    //Timing constants
    localparam int H_VISIBLE = 640;
    localparam int H_SYNC = 96;
    localparam int H_BACK = 48;
    localparam int H_FRONT = 16;
    localparam int H_TOTAL = H_SYNC + H_FRONT + H_BACK + H_VISIBLE;

    localparam int V_VISIBLE = 480;
    localparam int V_SYNC = 2;
    localparam int V_BACK = 33;
    localparam int V_FRONT = 10;
    localparam int V_TOTAL = V_SYNC + V_FRONT + V_BACK + V_VISIBLE;

    always_ff @(posedge clk) begin
        if (col_int == (H_TOTAL - 1)) begin
            col_int <= 0;
            row_int <= (row_int == (V_TOTAL - 1)) ? 0 : row_int + 1;
        end else begin
            col_int <= col_int + 1;
        end
    end

    assign valid = (col_int < H_VISIBLE) && (row_int < V_VISIBLE);

    assign HSYNC = (col_int >= (H_VISIBLE + H_FRONT) &&
        col_int < (H_VISIBLE + H_FRONT + H_SYNC)) ? 1'b0 : 1'b1;

    assign VSYNC = (row_int >= (V_VISIBLE + V_FRONT) &&
        row_int < (V_VISIBLE + V_FRONT + V_SYNC)) ? 1'b0 : 1'b1;

    assign col = col_int;
    assign row = row_int;

endmodule