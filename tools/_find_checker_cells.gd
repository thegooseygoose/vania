extends SceneTree
## Finds cells where the new regional wall color forms a tight CHECKERBOARD pattern with its
## neighbors (alternating between 2 very different colors cell-by-cell) — this is the tell-tale sign
## of leftover DOOR graphic pixels that got swept into "solid wall" by the original frequency
## classifier (real doors repeat ~150 times, easily passing the "reused >=50" solid threshold, and
## their checkered interior pattern is fine-grained at roughly tile-sized squares). Genuine rock
## regions are spatially coherent (big blocks of the same/similar color), not fine-checkered.
const W := 480; const H := 450
const PALETTE_COLORS := {
	69: Color8(0xD8,0x28,0x00), 70: Color8(0xBC,0xBC,0xBC), 71: Color8(0x00,0x90,0x38),
	72: Color8(0xC8,0x4C,0x0C), 73: Color8(0x74,0x74,0x74), 74: Color8(0x80,0x00,0xF0),
	75: Color8(0x00,0x70,0xEC), 76: Color8(0x00,0x80,0x88), 77: Color8(0xE4,0x00,0x58),
	78: Color8(0xBC,0x00,0xBC), 79: Color8(0x00,0x94,0x00), 80: Color8(0x00,0x00,0xA8),
}
func idx(x:int,y:int)->int: return y*W+x
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var atlas := PackedInt32Array(); atlas.resize(W*H); atlas.fill(-1)
	for c in terr.get_used_cells():
		if c.x>=0 and c.x<W and c.y>=0 and c.y<H:
			atlas[idx(c.x,c.y)] = terr.get_cell_atlas_coords(c).x
	var checker_cells := []
	for y in range(1, H-1):
		for x in range(1, W-1):
			var a: int = atlas[idx(x,y)]
			if not PALETTE_COLORS.has(a): continue
			# checkerboard test: this cell's color differs strongly from its 4-neighbors, AND at
			# least 2 of the diagonal neighbors match THIS cell's own color (classic checker)
			var diff_orth := 0
			for d in [Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1)]:
				var na: int = atlas[idx(x+d.x,y+d.y)]
				if PALETTE_COLORS.has(na) and na != a: diff_orth += 1
			var same_diag := 0
			for d in [Vector2i(1,1),Vector2i(1,-1),Vector2i(-1,1),Vector2i(-1,-1)]:
				var na: int = atlas[idx(x+d.x,y+d.y)]
				if na == a: same_diag += 1
			if diff_orth >= 3 and same_diag >= 2:
				checker_cells.append(Vector2i(x,y))
	print("checker-pattern cells found: ", checker_cells.size())
	# save for the fix script
	var f := FileAccess.open("res://tools/_checker_cells.txt", FileAccess.WRITE)
	for c in checker_cells:
		f.store_line("%d,%d" % [c.x, c.y])
	f.close()
	quit()
