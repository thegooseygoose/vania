"""Add a SAVE-STATION marker icon to tiles.png at the next free column (85), matching the
existing circular-badge icon style (black outline, flat saturated fill, simple bold pictogram).
Green, matching savestation.gd's own palette. This tile is a PLACEMENT MARKER ONLY -- main.gd
erases it the instant it spawns the real SaveStation node there, so the two visuals never
double up / overlap."""
from PIL import Image, ImageDraw

SZ = 16
BADGE = (25, 130, 60, 255)     # green, matches savestation.gd's glow palette
OUTLINE = (0, 0, 0, 255)
MARK = (110, 255, 150, 255)    # bright green, pops against the darker badge

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

# a bold floppy-disk-ish "save" glyph: outer square + a notch + a small inner square
d.rectangle([4, 4, 11, 11], outline=MARK, width=1)
d.rectangle([6, 4, 9, 6], fill=MARK)
d.rectangle([6, 8, 9, 10], fill=MARK)

sheet = Image.open("tiles.png").convert("RGBA")
new_w = sheet.width + SZ
new_sheet = Image.new("RGBA", (new_w, sheet.height), (0, 0, 0, 0))
new_sheet.paste(sheet, (0, 0))
new_sheet.paste(img, (sheet.width, 0), img)
new_sheet.save("tiles.png")
print("tiles.png now", new_sheet.size, "save-station marker icon at col", sheet.width // 16)

img.resize((128, 128), Image.NEAREST).save("tools/_icon_savetile_preview.png")
