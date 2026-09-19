extends SceneTree
## Samples the ORIGINAL meto.png at every solid Terrain cell in Level29, finds the dominant color
## per cell, and reports the most common colors overall (candidate wall-texture palette).
const W := 480; const H := 450
func _initialize(): call_deferred("_run")
func _run():
	var src := Image.load_from_file("res://../pro wrestling/new sprites/meto.png")
	print("source size: ", src.get_size())
	src.convert(Image.FORMAT_RGBA8)
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var color_count := {}   # packed color int -> count of CELLS whose dominant color is this
	var n := 0
	for c in terr.get_used_cells():
		if terr.get_cell_atlas_coords(c).x != 13: continue
		if c.x < 0 or c.x >= W or c.y < 0 or c.y >= H: continue
		# sample the block's dominant color (mode) via a small histogram of this 16x16 region
		var block_hist := {}
		var bx: int = c.x * 16; var by: int = c.y * 16
		for yy in range(0, 16, 2):        # stride 2 for speed
			for xx in range(0, 16, 2):
				var px := src.get_pixel(bx + xx, by + yy)
				var ri: int = int(px.r*255); var gi: int = int(px.g*255); var bi: int = int(px.b*255)
				if ri + gi + bi < 60: continue   # skip near-black detail/outline pixels
				var key: int = (ri<<16) | (gi<<8) | bi
				block_hist[key] = block_hist.get(key, 0) + 1
		var best_k := -1; var best_v := -1
		for k in block_hist.keys():
			if block_hist[k] > best_v: best_v = block_hist[k]; best_k = k
		if best_k >= 0:
			color_count[best_k] = color_count.get(best_k, 0) + 1
		n += 1
		if n % 10000 == 0: print("...", n, " cells sampled")
	print("total solid cells sampled: ", n)
	var keys = color_count.keys()
	keys.sort_custom(func(a,b): return color_count[a] > color_count[b])
	print("top 20 dominant colors (hex, count):")
	for i in range(min(20, keys.size())):
		var k = keys[i]
		print("  #%06X  count=%d" % [k, color_count[k]])
	quit()
