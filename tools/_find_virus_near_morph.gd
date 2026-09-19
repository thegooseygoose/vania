extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var et = scn.get_node("EnemyTiles")
	var pw = scn.get_node("Powerups")
	var morph := Vector2i(-9,-9)
	for c in pw.get_used_cells():
		if pw.get_cell_atlas_coords(c).x == 48: morph = c
	print("morph pickup at: ", morph)
	var viruses := []
	for c in et.get_used_cells():
		if et.get_cell_atlas_coords(c).x == 31:
			viruses.append([c, c.distance_to(morph)])
	viruses.sort_custom(func(a,b): return a[1] < b[1])
	print("nearest viruses to morph pickup:")
	for i in range(min(6, viruses.size())):
		print("  ", viruses[i][0], " dist=", viruses[i][1])
	quit()
