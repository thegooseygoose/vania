"""Add a LIFE-REFILL power-up icon to tiles.png at the next free column (84), matching the
existing circular-badge icon style (black outline, flat saturated fill, simple bold pictogram)
used by the other Powerups-layer tiles -- a warm red/pink badge with a white cross."""
from PIL import Image, ImageDraw

SZ = 16
BADGE = (230, 40, 70, 255)     # warm red/pink, matches lifestation's old palette
OUTLINE = (0, 0, 0, 255)
CROSS = (255, 230, 235, 255)   # near-white, pops against the red

img = Image.new("RGBA", (SZ, SZ), (0, 0, 0, 0))
d = ImageDraw.Draw(img)

# circular badge (pixel-art circle via a coarse mask, matching the blocky style of the others)
cx, cy, r = 7.5, 7.5, 7
for y in range(SZ):
    for x in range(SZ):
        dx, dy = x - cx, y - cy
        dist = (dx * dx + dy * dy) ** 0.5
        if dist <= r:
            d.point((x, y), fill=BADGE)
        elif dist <= r + 1.1:
            d.point((x, y), fill=OUTLINE)

# a bold white cross, centered
d.rectangle([6, 3, 9, 12], fill=CROSS)
d.rectangle([3, 6, 12, 9], fill=CROSS)

sheet = Image.open("tiles.png").convert("RGBA")
new_w = sheet.width + SZ
new_sheet = Image.new("RGBA", (new_w, sheet.height), (0, 0, 0, 0))
new_sheet.paste(sheet, (0, 0))
new_sheet.paste(img, (sheet.width, 0), img)
new_sheet.save("tiles.png")
print("tiles.png now", new_sheet.size, "life-refill icon at col", sheet.width // 16)

img.resize((128, 128), Image.NEAREST).save("tools/_icon_lifetile_preview.png")
