#!/usr/bin/env python3
"""Editable grid sheet <-> tiles.png round-trip.

The game uses tiles.png = a 55-tile single-row strip (880x16), which is painful to edit.
This exports an easy-to-edit 16-wide GRID (terrain_sheet.png) with id labels, and syncs
your edits back into tiles.png. tiles.png (the file the game/tilesets reference) keeps its
1-row layout, so nothing in the game breaks.

Usage (run from the project root, D:/best game/vania):
    python tools/terrain_sheet.py export   # tiles.png  -> terrain_sheet.png  (make the editable sheet)
    python tools/terrain_sheet.py sync      # terrain_sheet.png -> tiles.png    (apply your edits)

After 'sync', reimport in Godot (or run the game's --import) so the new pixels load.
LAYOUT IS FIXED (export and sync must agree) — edit only inside each tile's 16x16 cell;
leave the gray gaps / id labels alone.
"""
import sys
from PIL import Image, ImageDraw, ImageFont

TILES = "tiles.png"
SHEET = "terrain_sheet.png"
TILE = 16          # native tile size
COLS = 16          # grid width (tiles per row)
PAD = 6            # gap between cells
LBL = 10           # label strip height above each tile
BG = (44, 46, 52, 255)      # opaque gap colour (grid is visible; NOT inside tile cells)
LBLCOL = (150, 210, 160, 255)

def cell_origin(n):
    """top-left pixel of tile n's 16x16 cell on the sheet."""
    col, row = n % COLS, n // COLS
    x = PAD + col * (TILE + PAD)
    y = PAD + row * (LBL + TILE + PAD) + LBL
    return x, y

def export():
    strip = Image.open(TILES).convert("RGBA")
    n_tiles = strip.width // TILE
    rows = (n_tiles + COLS - 1) // COLS
    W = PAD + COLS * (TILE + PAD)
    H = PAD + rows * (LBL + TILE + PAD)
    sheet = Image.new("RGBA", (W, H), BG)
    draw = ImageDraw.Draw(sheet)
    try:
        font = ImageFont.load_default()
    except Exception:
        font = None
    for n in range(n_tiles):
        x, y = cell_origin(n)
        # clear the cell to transparent so a tile's transparent pixels round-trip correctly
        sheet.paste((0, 0, 0, 0), (x, y, x + TILE, y + TILE))
        tile = strip.crop((n * TILE, 0, n * TILE + TILE, TILE))
        sheet.alpha_composite(tile, (x, y))
        draw.text((x, y - LBL), str(n), fill=LBLCOL, font=font)
    sheet.save(SHEET)
    print(f"exported {SHEET}  ({W}x{H}, {n_tiles} tiles, {COLS} wide x {rows} rows)")

def sync():
    sheet = Image.open(SHEET).convert("RGBA")
    strip = Image.open(TILES).convert("RGBA")
    n_tiles = strip.width // TILE
    for n in range(n_tiles):
        x, y = cell_origin(n)
        cell = sheet.crop((x, y, x + TILE, y + TILE))
        strip.paste(cell, (n * TILE, 0))     # overwrite (cell carries full RGBA incl. alpha)
    strip.save(TILES)
    print(f"synced {SHEET} -> {TILES}  ({n_tiles} tiles). Reimport in Godot to load the new pixels.")

if __name__ == "__main__":
    mode = sys.argv[1] if len(sys.argv) > 1 else "export"
    if mode == "export":
        export()
    elif mode == "sync":
        sync()
    else:
        print("usage: python tools/terrain_sheet.py [export|sync]")
        sys.exit(1)
