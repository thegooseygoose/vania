extends SceneTree
const PALETTE := [
	Color8(0xD8, 0x28, 0x00), Color8(0xBC, 0xBC, 0xBC), Color8(0x00, 0x90, 0x38),
	Color8(0xC8, 0x4C, 0x0C), Color8(0x74, 0x74, 0x74), Color8(0x80, 0x00, 0xF0),
	Color8(0x00, 0x70, 0xEC), Color8(0x00, 0x80, 0x88), Color8(0xE4, 0x00, 0x58),
	Color8(0xBC, 0x00, 0xBC), Color8(0x00, 0x94, 0x00), Color8(0x00, 0x00, 0xA8),
]
const START_COL := 69
const W := 480; const H := 450
func _initialize(): call_deferred("_run")
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
func _run():
	var src := Image.load_from_file("res://../pro wrestling/new sprites/meto.png")
	src.convert(Image.FORMAT_RGBA8)
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var cells = terr.get_used_cells()
	var repainted := 0
	var counts := {}
	for c in cells:
		if terr.get_cell_atlas_coords(c).x != 13: continue
		if c.x < 0 or c.x >= W or c.y < 0 or c.y >= H: continue
		var block_hist := {}
		var bx: int = c.x * 16; var by: int = c.y * 16
		for yy in range(0, 16, 2):
			for xx in range(0, 16, 2):
				var px := src.get_pixel(bx + xx, by + yy)
				var ri: int = int(px.r*255); var gi: int = int(px.g*255); var bi: int = int(px.b*255)
				if ri + gi + bi < 60: continue
				var key: int = (ri<<16) | (gi<<8) | bi
				block_hist[key] = block_hist.get(key, 0) + 1
		var best_k := -1; var best_v := -1
		for k in block_hist.keys():
			if block_hist[k] > best_v: best_v = block_hist[k]; best_k = k
		var dom: Color
		if best_k >= 0:
			dom = Color8((best_k>>16)&255, (best_k>>8)&255, best_k&255)
		else:
			dom = Color8(0x74,0x74,0x74)   # fallback: plain grey (no non-black pixels found)
		# nearest palette match
		var best_i := 0; var best_d := 1e9
		for i in range(PALETTE.size()):
			var p: Color = PALETTE[i]
			var d: float = (p.r-dom.r)*(p.r-dom.r) + (p.g-dom.g)*(p.g-dom.g) + (p.b-dom.b)*(p.b-dom.b)
			if d < best_d: best_d = d; best_i = i
		var atlas: int = START_COL + best_i
		terr.set_cell(c, 0, Vector2i(atlas, 0))
		repainted += 1
		counts[atlas] = counts.get(atlas, 0) + 1
	print("repainted %d cells" % repainted)
	for k in counts.keys(): print("  atlas=%d count=%d" % [k, counts[k]])
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
