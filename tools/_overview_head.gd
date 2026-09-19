extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://tools/_Level29_head.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var et = scn.get_node("EnemyTiles")
	var mk = scn.get_node("Markers")
	const W := 480; const H := 450
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.05, 0.05, 0.07))
	for c in terr.get_used_cells():
		if c.x < 0 or c.x >= W or c.y < 0 or c.y >= H: continue
		img.set_pixel(c.x, c.y, Color(0.55, 0.55, 0.6))
	for c in et.get_used_cells():
		if c.x < 0 or c.x >= W or c.y < 0 or c.y >= H: continue
		var ax: int = et.get_cell_atlas_coords(c).x
		if ax >= 26 and ax <= 28: img.set_pixel(c.x, c.y, Color(0.3, 0.6, 1.0))
	for c in mk.get_used_cells():
		if c.x < 0 or c.x >= W or c.y < 0 or c.y >= H: continue
		var ax: int = mk.get_cell_atlas_coords(c).x
		img.set_pixel(c.x, c.y, Color(1, 0.85, 0.2) if ax == 19 else Color(0.2, 1.0, 0.4))
	img.save_png("res://tools/_overview_head.png")
	print("saved head overview")
	quit()
