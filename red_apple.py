from PIL import Image


# Size of our image to generate in ROM memory
IMAGE_FILE = "redapple.png"      # your 20×20 apple
SCREEN_WIDTH  = 20               # changed
SCREEN_HEIGHT = 20               # changed
SUPER_W = 20                     # unchanged (whole image is 1 superpixel)
SUPER_H = 20                     # unchanged

# Load the image (also upload it to the Snake-Game foler!)
img = Image.open(IMAGE_FILE).convert("RGB")

if img.size != (SCREEN_WIDTH, SCREEN_HEIGHT):
    raise ValueError(f"Image must be {SCREEN_WIDTH}x{SCREEN_HEIGHT}")


# Process the image and generate the colors
# Convert RGB888 → RGB222 (6-bit)
def pack_6bit(r, g, b):
    r2 = r >> 6         # top 2 bits
    g2 = g >> 6
    b2 = b >> 6
    return (r2 << 4) | (g2 << 2) | b2   # RRGGBB

for super_y in range(0, SCREEN_HEIGHT, SUPER_H): 
    for super_x in range(0, SCREEN_WIDTH, SUPER_W):
        # Process every pixel inside the current superpixel
        for y in range(super_y, super_y + SUPER_H):
            for x in range(super_x, super_x + SUPER_W):

                # Read pixel color
                r, g, b = img.getpixel((x, y))

                # Compute ROM address
                address = y * SCREEN_WIDTH + x

                # Convert to 6-bit color
                pix6 = pack_6bit(r, g, b)

                # Print ROM line: address, 6-bit hex
                print(f"{address}: 0x{pix6:02X}")

