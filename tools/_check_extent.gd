extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var r = terr.get_used_rect()
	print("terrain used rect: ", r)
	quit()
