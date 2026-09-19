extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var pw = scn.get_node("Powerups")
	var mk = scn.get_node("Markers")
	var x0 := 445; var x1 := 490
	var y0 := 340; var y1 := 400
	var scale := 12
	var w := (x1 - x0 + 1) * scale
	var h := (y1 - y0 + 1) * scale
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.05, 0.06, 0.12))
	for c in terr.get_used_cells():
		if c.x < x0 or c.x > x1 or c.y < y0 or c.y > y1: continue
		var ax: int = terr.get_cell_atlas_coords(c).x
		if not (ax < 45 or ax >= 67): continue
		var px: int = (int(c.x) - x0) * scale; var py: int = (int(c.y) - y0) * scale
		for dx in range(scale - 1):
			for dy in range(scale - 1):
				img.set_pixel(px + dx, py + dy, Color(0.2, 0.65, 0.65))
	for c in pw.get_used_cells():
		if c.x < x0 or c.x > x1 or c.y < y0 or c.y > y1: continue
		var px: int = (int(c.x) - x0) * scale; var py: int = (int(c.y) - y0) * scale
		for dx in range(scale - 1):
			for dy in range(scale - 1):
				img.set_pixel(px + dx, py + dy, Color(1.0, 0.9, 0.1))
	for c in mk.get_used_cells():
		if c.x < x0 or c.x > x1 or c.y < y0 or c.y > y1: continue
		var px: int = (int(c.x) - x0) * scale; var py: int = (int(c.y) - y0) * scale
		for dx in range(scale - 1):
			for dy in range(scale - 1):
				img.set_pixel(px + dx, py + dy, Color(1.0, 0.2, 0.9))
	img.save_png("res://tools/_zoom_bomb.png")
	print("saved zoom, region x=%d-%d y=%d-%d scale=%d" % [x0, x1, y0, y1, scale])
	quit()
