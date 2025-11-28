from PIL import Image

# Size of our image to generate in ROM memory
IMAGE_FILE = "9.png"      # your 20×20 apple
SCREEN_WIDTH  = 20
SCREEN_HEIGHT = 20
SUPER_W = 20
SUPER_H = 20

# Load the image
img = Image.open(IMAGE_FILE).convert("RGB")

if img.size != (SCREEN_WIDTH, SCREEN_HEIGHT):
    raise ValueError(f"Image must be {SCREEN_WIDTH}x{SCREEN_HEIGHT}")

# RGB222 pack
def pack_6bit(r, g, b):
    r2 = r >> 6     # top 2 bits
    g2 = g >> 6
    b2 = b >> 6
    return (r2 << 4) | (g2 << 2) | b2

# Generate SystemVerilog case entries
for super_y in range(0, SCREEN_HEIGHT, SUPER_H):
    for super_x in range(0, SCREEN_WIDTH, SUPER_W):
        for y in range(super_y, super_y + SUPER_H):
            for x in range(super_x, super_x + SUPER_W):

                r, g, b = img.getpixel((x, y))
                address = y * SCREEN_WIDTH + x
                pix6 = pack_6bit(r, g, b)

                # Print SystemVerilog case entry:
                print(f"9'b{address:09b}: data_comb = 6'b{pix6:06b};")
