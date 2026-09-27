"""Add a SCREW ATTACK icon to tiles.png at the next free column (86), matching the existing
circular-badge style (black outline, flat saturated fill, simple bold pictogram) -- a gold
badge with a white spiral, classic Metroid screw-attack coloring."""
from PIL import Image, ImageDraw
import math

SZ = 16
BADGE = (235, 175, 20, 255)   # gold
OUTLINE = (0, 0, 0, 255)
SPIRAL = (255, 250, 225, 255)

img = Image.new("RGBA", (SZ, SZ), (0, 0, 0, 0))
d = ImageDraw.Draw(img)

cx, cy, r = 7.5, 7.5, 7
for y in range(SZ):
    for x in range(SZ):
        dx, dy = x - cx, y - cy
        dist = (dx * dx + dy * dy) ** 0.5
        if dist <= r:
            d.point((x, y), fill=BADGE)
        elif dist <= r + 1.1:
            d.point((x, y), fill=OUTLINE)

# a bold "S" swoosh (reads clearly at 16px, unlike a fine spiral which just blobs together)
d.arc([2, 1, 12, 9], start=200, end=380, fill=SPIRAL, width=2)
d.arc([4, 6, 14, 14], start=20, end=200, fill=SPIRAL, width=2)
# a few radial motion-tick marks around the badge edge for the "spin" read
for ang_deg in [25, 100, 205, 300]:
    ang = math.radians(ang_deg)
    x0 = cx + 4.6 * math.cos(ang); y0 = cy + 4.6 * math.sin(ang)
    x1 = cx + 6.6 * math.cos(ang); y1 = cy + 6.6 * math.sin(ang)
    d.line([(x0, y0), (x1, y1)], fill=SPIRAL, width=1)

sheet = Image.open("tiles.png").convert("RGBA")
new_w = sheet.width + SZ
new_sheet = Image.new("RGBA", (new_w, sheet.height), (0, 0, 0, 0))
new_sheet.paste(sheet, (0, 0))
new_sheet.paste(img, (sheet.width, 0), img)
new_sheet.save("tiles.png")
print("tiles.png now", new_sheet.size, "screw attack icon at col", sheet.width // 16)

img.resize((128, 128), Image.NEAREST).save("tools/_icon_screwattack_preview.png")
