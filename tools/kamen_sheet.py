#!/usr/bin/env python3
"""Editable grid sheet <-> the 24 kamen_*.png pose files (one file to edit them all).

    python tools/kamen_sheet.py export   # kamen_*.png  -> kamen_sheet.png (make the editable sheet)
    python tools/kamen_sheet.py sync      # kamen_sheet.png -> kamen_*.png  (apply your edits)

After 'sync', reimport in Godot. Edit only inside each 16x32 cell; leave the gray gaps/labels alone.
Sprites are bottom-aligned in their cell; duck is shorter (its bottom rows are what get saved).
"""
import sys, os
from PIL import Image, ImageDraw, ImageFont

DIR = "sprites/player"
SHEET = "sprites/v sprites/kamen_sheet.png"
ROWS = ["big", "fire"]
COLS = ["stand_l", "stand_r", "walk1", "walk2", "walk3", "walk4", "walk5", "walk6",
        "jump_l", "jump_r", "skid", "duck"]
CW, CH = 16, 32          # cell art size
PAD, LBL = 6, 10
BG = (44, 46, 52, 255)
LBLCOL = (150, 210, 160, 255)

def cell_origin(ci, ri):
    x = PAD + ci * (CW + PAD)
    y = PAD + ri * (LBL + CH + PAD) + LBL
    return x, y

def fpath(r, c):
    return f"{DIR}/kamen_{r}_{c}.png"

def export():
    W = PAD + len(COLS) * (CW + PAD)
    H = PAD + len(ROWS) * (LBL + CH + PAD)
    sheet = Image.new("RGBA", (W, H), BG)
    draw = ImageDraw.Draw(sheet)
    try: font = ImageFont.load_default()
    except Exception: font = None
    for ri, r in enumerate(ROWS):
        for ci, c in enumerate(COLS):
            x, y = cell_origin(ci, ri)
            sheet.paste((0, 0, 0, 0), (x, y, x + CW, y + CH))   # clear cell (keep transparency)
            p = fpath(r, c)
            if os.path.exists(p):
                spr = Image.open(p).convert("RGBA")
                sheet.alpha_composite(spr, (x, y + (CH - spr.height)))   # bottom-align
            draw.text((x, y - LBL), f"{r[0]}.{c}", fill=LBLCOL, font=font)
    sheet.save(SHEET)
    print(f"exported {SHEET} ({W}x{H})")

def sync():
    sheet = Image.open(SHEET).convert("RGBA")
    n = 0
    for ri, r in enumerate(ROWS):
        for ci, c in enumerate(COLS):
            p = fpath(r, c)
            if not os.path.exists(p):
                continue
            h = Image.open(p).height                 # keep each file's original height (duck=22)
            x, y = cell_origin(ci, ri)
            cell = sheet.crop((x, y + (CH - h), x + CW, y + CH))   # bottom `h` rows of the cell
            cell.save(p); n += 1
    print(f"synced {SHEET} -> {n} kamen_*.png files. Reimport in Godot.")

if __name__ == "__main__":
    mode = sys.argv[1] if len(sys.argv) > 1 else "export"
    {"export": export, "sync": sync}.get(mode, lambda: print("usage: export|sync"))()
