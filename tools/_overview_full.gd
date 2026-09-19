extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var mk = scn.get_node("Markers")
	var et = scn.get_node("EnemyTiles")
	var pw = scn.get_node("Powerups")
	const W := 480; const H := 450
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.05, 0.05, 0.07))
	for c in terr.get_used_cells():
		if c.x < 0 or c.x >= W or c.y < 0 or c.y >= H: continue
		img.set_pixel(c.x, c.y, Color(0.55, 0.55, 0.6))
	for c in et.get_used_cells():
		if c.x < 0 or c.x >= W or c.y < 0 or c.y >= H: continue
		var ax: int = et.get_cell_atlas_coords(c).x
		if ax >= 26 and ax <= 28: img.set_pixel(c.x, c.y, Color(0.3, 0.6, 1.0))   # doors = blue
	for c in mk.get_used_cells():
		if c.x < 0 or c.x >= W or c.y < 0 or c.y >= H: continue
		var ax: int = mk.get_cell_atlas_coords(c).x
		img.set_pixel(c.x, c.y, Color(1, 0.85, 0.2) if ax == 19 else Color(0.2, 1.0, 0.4))  # goal gold, start green
	img.save_png("res://tools/_overview_full.png")
	print("saved full overview")
	quit()
