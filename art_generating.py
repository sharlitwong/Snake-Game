from PIL import Image

# ---------------------------------------------------
# USER SETTINGS
# ---------------------------------------------------
IMAGE_FILE = "pixelart.png"      # your image file
SCREEN_WIDTH  = 640
SCREEN_HEIGHT = 480
SUPER_W = 20
SUPER_H = 20

# ---------------------------------------------------
# LOAD IMAGE
# ---------------------------------------------------
img = Image.open(IMAGE_FILE).convert("RGB")

if img.size != (SCREEN_WIDTH, SCREEN_HEIGHT):
    raise ValueError(f"Image must be {SCREEN_WIDTH}x{SCREEN_HEIGHT}")

# ---------------------------------------------------
# PROCESS AND PRINT ADDRESS + COLOR
# ---------------------------------------------------
# Addressing scheme:
#   address = y * SCREEN_WIDTH + x
#
# Color format:
#   RGB (8-bit each) or hex 0xRRGGBB for FPGA ROM
# ---------------------------------------------------

for super_y in range(0, SCREEN_HEIGHT, SUPER_H):
    for super_x in range(0, SCREEN_WIDTH, SUPER_W):

        # Process every pixel inside the current superpixel
        for y in range(super_y, super_y + SUPER_H):
            for x in range(super_x, super_x + SUPER_W):

                # Read pixel color
                r, g, b = img.getpixel((x, y))

                # Compute ROM address
                address = y * SCREEN_WIDTH + x

                # Print line:  address, hex color
                print(f"{address:06d}: 0x{r:02X}{g:02X}{b:02X}")
