"""Generate placeholder art for the new TALON flying dive-bomb boss:
- sprites/enemies/talon0.png / talon1.png: 34x26, 2-frame wing-flap cycle (wings up / wings down)
- appends a 16x16 icon to sprites/enemy_tiles.png at column 38 (col37=brood is the current last)
Dark indigo/purple body (distinct from BROOD's red and METROID's teal), glowing red eyes, a sharp
beak, clawed talons, membrane bat-like wings.
"""
from PIL import Image, ImageDraw

W, H = 34, 26
BODY = (58, 40, 92, 255)        # dark indigo
BODY_DK = (38, 24, 64, 255)     # shading
WING = (90, 60, 140, 220)       # translucent membrane wing
WING_EDGE = (140, 100, 200, 255)
EYE = (255, 40, 40, 255)
BEAK = (220, 180, 60, 255)
CLAW = (200, 200, 210, 255)

def draw_frame(wings_up: bool) -> Image.Image:
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    cx, cy = W // 2, H // 2 + 2

    # wings: two triangular membranes, angled up or down
    if wings_up:
        d.polygon([(cx - 2, cy - 2), (cx - 16, cy - 14), (cx - 12, cy - 4), (cx - 4, cy)], fill=WING, outline=WING_EDGE)
        d.polygon([(cx + 2, cy - 2), (cx + 16, cy - 14), (cx + 12, cy - 4), (cx + 4, cy)], fill=WING, outline=WING_EDGE)
    else:
        d.polygon([(cx - 2, cy - 2), (cx - 15, cy + 6), (cx - 11, cy + 9), (cx - 4, cy + 2)], fill=WING, outline=WING_EDGE)
        d.polygon([(cx + 2, cy - 2), (cx + 15, cy + 6), (cx + 11, cy + 9), (cx + 4, cy + 2)], fill=WING, outline=WING_EDGE)

    # body: rounded torso
    d.ellipse([cx - 7, cy - 8, cx + 7, cy + 7], fill=BODY, outline=BODY_DK)
    # head
    d.ellipse([cx - 5, cy - 13, cx + 5, cy - 4], fill=BODY, outline=BODY_DK)
    # beak
    d.polygon([(cx - 1, cy - 7), (cx - 6, cy - 6), (cx - 1, cy - 4)], fill=BEAK)
    # eyes (glowing red)
    d.ellipse([cx - 3, cy - 11, cx - 1, cy - 9], fill=EYE)
    d.ellipse([cx + 1, cy - 11, cx + 3, cy - 9], fill=EYE)
    # tail / rear spikes
    d.polygon([(cx, cy + 6), (cx - 3, cy + 11), (cx + 1, cy + 8)], fill=BODY_DK)
    d.polygon([(cx + 2, cy + 7), (cx + 5, cy + 12), (cx + 3, cy + 8)], fill=BODY_DK)
    # trailing talon feet, tucked
    d.line([(cx - 3, cy + 6), (cx - 5, cy + 9)], fill=CLAW, width=1)
    d.line([(cx + 3, cy + 6), (cx + 5, cy + 9)], fill=CLAW, width=1)

    return img

f0 = draw_frame(True)
f1 = draw_frame(False)
f0.save("sprites/enemies/talon0.png")
f1.save("sprites/enemies/talon1.png")
print("saved talon0.png / talon1.png", f0.size)

# EnemyTiles icon: small 16x16 version of frame0, centered
icon = Image.new("RGBA", (16, 16), (0, 0, 0, 0))
small = f0.resize((16, 12), Image.LANCZOS)
icon.paste(small, (0, 2), small)
sheet = Image.open("sprites/enemy_tiles.png").convert("RGBA")
new_w = sheet.width + 16
new_sheet = Image.new("RGBA", (new_w, sheet.height), (0, 0, 0, 0))
new_sheet.paste(sheet, (0, 0))
new_sheet.paste(icon, (sheet.width, 0), icon)
new_sheet.save("sprites/enemy_tiles.png")
print("enemy_tiles.png now", new_sheet.size, "new col index", sheet.width // 16)
