from PIL import Image

#Size of our image to generate in ROM memory
IMAGE_FILE = "score.png"      #100×20 apple
SCREEN_WIDTH  = 100
SCREEN_HEIGHT = 20
SUPER_W = 20
SUPER_H = 20

#Load image
img = Image.open(IMAGE_FILE).convert("RGB")

if img.size != (SCREEN_WIDTH, SCREEN_HEIGHT):
    raise ValueError(f"Image must be {SCREEN_WIDTH}x{SCREEN_HEIGHT}")

ADDR_BITS = (SCREEN_WIDTH * SCREEN_HEIGHT - 1).bit_length()

# RGB222 pack
def pack_6bit(r, g, b):
    r2 = r >> 6     # top 2 bits
    g2 = g >> 6
    b2 = b >> 6
    return (r2 << 4) | (g2 << 2) | b2

# Generate SystemVerilog case entries
for y in range(SCREEN_HEIGHT):
    for x in range(SCREEN_WIDTH):
        r, g, b = img.getpixel((x, y))
        address = y * SCREEN_WIDTH + x
        pix6 = pack_6bit(r, g, b)

        #Print SystemVerilog case entry:
        print(f"{ADDR_BITS}'b{address:0{ADDR_BITS}b}: data_comb = 6'b{pix6:06b};")
        
