extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var x0 := 432; var x1 := 456
	var y0 := 298; var y1 := 374
	var scale := 14
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
	img.save_png("res://tools/_zoom_shaft166.png")
	print("saved")
	quit()
