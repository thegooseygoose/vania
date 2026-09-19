"""Add a LONG BEAM power-up icon to tiles.png at the next free column (83), matching the existing
circular-badge icon style (black outline, flat saturated fill, simple bold pictogram) -- an electric-
blue badge with a bright bolt spanning the full width, reading as "beam crosses the whole screen".
"""
from PIL import Image, ImageDraw

SZ = 16
BADGE = (0, 130, 220, 255)      # electric blue, distinct from the orange SHOT badge
OUTLINE = (0, 0, 0, 255)
BOLT = (255, 240, 90, 255)      # bright yellow bolt, pops against the blue

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

# a bright bolt spanning the FULL width of the badge (edge to edge), zigzagging slightly like the
# in-game shot's energy bolt -- reads as "the beam goes all the way across"
bolt_pts = [(1, 8), (6, 6), (6, 9), (11, 5), (11, 9), (15, 7)]
d.line(bolt_pts, fill=BOLT, width=1)
for p in [(1, 8), (15, 7)]:
    d.point(p, fill=BOLT)
# small arrowhead at the tip to emphasize direction/reach
d.line([(13, 6), (15, 7)], fill=BOLT, width=1)
d.line([(13, 8), (15, 7)], fill=BOLT, width=1)

sheet = Image.open("tiles.png").convert("RGBA")
new_w = sheet.width + SZ
new_sheet = Image.new("RGBA", (new_w, sheet.height), (0, 0, 0, 0))
new_sheet.paste(sheet, (0, 0))
new_sheet.paste(img, (sheet.width, 0), img)
new_sheet.save("tiles.png")
print("tiles.png now", new_sheet.size, "long beam icon at col", sheet.width // 16)

img.resize((128, 128), Image.NEAREST).save("tools/_icon_longbeam_preview.png")
