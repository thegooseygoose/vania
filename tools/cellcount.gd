extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var s=load("res://Level29.bak.tscn").instantiate()
	print("bak Terrain cells=", s.get_node("Terrain").get_used_cells().size())
	quit()
