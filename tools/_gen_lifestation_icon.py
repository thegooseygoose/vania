"""Append a LIFE STATION icon to sprites/enemy_tiles.png at the next free column (39): a small
health-refill pod matching lifestation.gd's own palette (dark red cabinet, glowing pink cross)."""
from PIL import Image, ImageDraw

SZ = 16
BODY = (41, 18, 23, 255)
EDGE = (255, 77, 107, 255)
GLOW = (255, 140, 158, 255)

img = Image.new("RGBA", (SZ, SZ), (0, 0, 0, 0))
d = ImageDraw.Draw(img)

# cabinet
d.rectangle([2, 1, 13, 14], fill=BODY, outline=EDGE)
# screen backdrop
d.rectangle([4, 3, 11, 8], fill=(20, 8, 10, 255))
# glowing cross
d.rectangle([7, 3, 8, 8], fill=GLOW)
d.rectangle([5, 5, 10, 6], fill=GLOW)
# base
d.rectangle([1, 13, 14, 14], fill=BODY)

sheet = Image.open("sprites/enemy_tiles.png").convert("RGBA")
new_w = sheet.width + SZ
new_sheet = Image.new("RGBA", (new_w, sheet.height), (0, 0, 0, 0))
new_sheet.paste(sheet, (0, 0))
new_sheet.paste(img, (sheet.width, 0), img)
new_sheet.save("sprites/enemy_tiles.png")
print("enemy_tiles.png now", new_sheet.size, "life-station icon at col", sheet.width // 16)

img.resize((128, 128), Image.NEAREST).save("tools/_icon_lifestation_preview.png")
