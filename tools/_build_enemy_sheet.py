"""Compile every enemy sprite in the game into one labeled reference sheet (enemies only --
no tiles, player, or items). Reference/viewing only, not an editable round-trip sheet.
Output: sprites/ENEMY_REFERENCE_SHEET.png
"""
from PIL import Image, ImageDraw, ImageFont

E = "sprites/enemies/"
NP = "sprites/new player/"

def load(path):
    return Image.open(path).convert("RGBA")

def crop(path, box):
    return load(path).crop(box)

# (row label, [frame images])
rows = []

def add(label, frames):
    rows.append((label, frames))

# --- Classic ground enemies ---
add("GOOMBA", [load(E+"goomba_walk1.png"), load(E+"goomba_walk2.png"), load(E+"goomba_flat.png")])
add("KOOPA", [load(E+"koopa_walk1.png"), load(E+"koopa_walk2.png"), load(E+"koopa_shell.png"),
              load(E+"shell_left.png"), load(E+"shell_right1.png"), load(E+"shell_right2.png"), load(E+"shell_wake.png")])
add("PURPLE GOOMBA", [load(E+"purple_goomba_walk1.png"), load(E+"purple_goomba_walk2.png"), load(E+"purple_goomba_flat.png")])
add("PURPLE KOOPA", [load(E+"purple_koopa_walk1.png"), load(E+"purple_koopa_walk2.png"), load(E+"purple_koopa_shell.png"),
                      load(E+"purple_shell_left.png"), load(E+"purple_shell_right1.png"), load(E+"purple_shell_right2.png"), load(E+"purple_shell_wake.png")])
add("PIRANHA PLANT", [load(E+"purple_piranha1.png"), load(E+"purple_piranha2.png")])

# --- Hazards / mini-bosses (classic) ---
add("HAMMER BRO", [load(E+"hbro_l1.png"), load(E+"hbro_l2.png"), load(E+"hbro_l3.png"), load(E+"hbro_l4.png"),
                    load(E+"hbro_r1.png"), load(E+"hbro_r2.png"), load(E+"hbro_r3.png"), load(E+"hbro_r4.png")])
add("HAMMER", [load(E+"hammer1.png"), load(E+"hammer2.png"), load(E+"hammer3.png"), load(E+"hammer4.png")])
add("FIREBAR", [load(E+"firebar_block.png"), load(E+"firebar_ball.png")])
add("PODOBOO", [load(E+"podoboo.png")])
add("GORD", [crop(NP+"gord.png", (11, 64, 34, 88)), crop(NP+"gord.png", (44, 64, 67, 88))])
add("BOWSER", [crop(NP+"bow.png", (14, 32, 46, 64)), crop(NP+"bow.png", (54, 32, 86, 64)), crop(NP+"bow.png", (94, 32, 126, 64)),
               crop(NP+"bow.png", (139, 34, 171, 66)), crop(NP+"bow.png", (179, 34, 211, 66)), crop(NP+"bow.png", (219, 34, 251, 66))])

# --- Metroid-style enemies ---
add("ZOOMER", [load(E+"zoomer0.png"), load(E+"zoomer1.png")])
add("SERP", [load(E+"serp.png"), load(E+"serp2.png")])
add("VIRUS", [load(E+"virus0.png"), load(E+"virus1.png")])
add("BUG", [load(E+"bug0.png"), load(E+"bug1.png")])
add("TURRET", [load(E+"turret0.png"), load(E+"turret1.png")])
add("URCHIN", [load(E+"urchin0.png"), load(E+"urchin1.png")])

# --- Bosses ---
add("METROID BOSS", [load(E+"metroid0.png"), load(E+"metroid1.png")])
add("BROOD BOSS", [load(E+"brood0.png"), load(E+"brood1.png")])
add("TALON BOSS", [load(E+"talon0.png"), load(E+"talon1.png")])

# ---- layout ----
SCALE = 3
LABEL_W = 190
PAD = 10
GAP = 14
max_frame_w = max(f.width for _, frames in rows for f in frames) * SCALE
CELL = max_frame_w + GAP   # pitch per frame slot, sized to the largest sprite in the whole sheet
ROW_GAP = 6
BG = (18, 18, 24, 255)
LABEL_COL = (255, 210, 90, 255)
GRID_COL = (50, 50, 62, 255)
TITLE_COL = (255, 255, 255, 255)

try:
    font = ImageFont.truetype("C:/Windows/Fonts/consola.ttf", 15)
    title_font = ImageFont.truetype("C:/Windows/Fonts/consolab.ttf", 22)
except Exception:
    font = ImageFont.load_default()
    title_font = font

row_heights = []
for label, frames in rows:
    max_h = max(f.height for f in frames) * SCALE
    row_heights.append(max(max_h, 40) + ROW_GAP)

max_frames = max(len(frames) for _, frames in rows)
sheet_w = LABEL_W + max_frames * CELL + PAD * 2
title_h = 46
sheet_h = title_h + sum(row_heights) + PAD * 2

img = Image.new("RGBA", (sheet_w, sheet_h), BG)
d = ImageDraw.Draw(img)
d.text((PAD, 10), "VANIA — ENEMY REFERENCE SHEET", font=title_font, fill=TITLE_COL)

y = title_h + PAD
for (label, frames), rh in zip(rows, row_heights):
    d.text((PAD, y + rh / 2 - 8), label, font=font, fill=LABEL_COL)
    x = LABEL_W
    for f in frames:
        fw, fh = f.width * SCALE, f.height * SCALE
        fr = f.resize((fw, fh), Image.NEAREST)
        cy = y + (rh - ROW_GAP - fh) // 2
        img.paste(fr, (x + (CELL - fw) // 2, int(cy)), fr)
        x += CELL
    d.line([(PAD, y + rh - ROW_GAP // 2), (sheet_w - PAD, y + rh - ROW_GAP // 2)], fill=GRID_COL, width=1)
    y += rh

import os
os.makedirs("reference", exist_ok=True)
img.save("reference/ENEMY_REFERENCE_SHEET.png")
print("saved reference/ENEMY_REFERENCE_SHEET.png", img.size, "rows:", len(rows))
