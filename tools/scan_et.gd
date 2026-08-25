extends SceneTree
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(20): await physics_frame
	var et=m.level.get_node_or_null("EnemyTiles")
	var ct=m.level.get_node_or_null("CoinTiles")
	print("EnemyTiles visible=%s modulate=%s  cells:" % [str(et.visible), str(et.modulate)])
	for cell in et.get_used_cells():
		print("   ", cell, " atlas=", et.get_cell_atlas_coords(cell))
	print("CoinTiles visible=%s cells=%d" % [str(ct.visible), ct.get_used_cells().size()])
	print("DONE"); quit()
