extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var pw = scn.get_node("Powerups")
	var x0 := 448; var x1 := 484
	var y0 := 340; var y1 := 400
	var scale := 16
	var w := (x1 - x0 + 1) * scale
	var h := (y1 - y0 + 1) * scale
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.05, 0.06, 0.12))
	# faint grid every tile, brighter every 5
	for gx in range(x0, x1 + 1):
		var lx: int = (gx - x0) * scale
		var c: Color = Color(0.25, 0.25, 0.3) if gx % 5 != 0 else Color(0.5, 0.5, 0.1)
		for py in range(h):
			img.set_pixel(clampi(lx, 0, w - 1), py, c)
	for gy in range(y0, y1 + 1):
		var ly: int = (gy - y0) * scale
		var c: Color = Color(0.25, 0.25, 0.3) if gy % 5 != 0 else Color(0.5, 0.5, 0.1)
		for px in range(w):
			img.set_pixel(px, clampi(ly, 0, h - 1), c)
	for c in terr.get_used_cells():
		if c.x < x0 or c.x > x1 or c.y < y0 or c.y > y1: continue
		var ax: int = terr.get_cell_atlas_coords(c).x
		if not (ax < 45 or ax >= 67): continue
		var px: int = (int(c.x) - x0) * scale; var py: int = (int(c.y) - y0) * scale
		for dx in range(1, scale - 1):
			for dy in range(1, scale - 1):
				img.set_pixel(px + dx, py + dy, Color(0.2, 0.65, 0.65))
	for c in pw.get_used_cells():
		if c.x < x0 or c.x > x1 or c.y < y0 or c.y > y1: continue
		var px: int = (int(c.x) - x0) * scale; var py: int = (int(c.y) - y0) * scale
		for dx in range(1, scale - 1):
			for dy in range(1, scale - 1):
				img.set_pixel(px + dx, py + dy, Color(1.0, 0.9, 0.1))
	img.save_png("res://tools/_zoom_bomb2.png")
	print("saved zoom2, region x=%d-%d y=%d-%d scale=%d" % [x0, x1, y0, y1, scale])
	quit()
