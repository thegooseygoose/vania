extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var et = scn.get_node("EnemyTiles")
	print("EnemyTiles near (20-45, 195-212):")
	for c in et.get_used_cells():
		if c.x>=15 and c.x<=50 and c.y>=195 and c.y<=212:
			print("  ", c, " atlas=", et.get_cell_atlas_coords(c).x)
	quit()
