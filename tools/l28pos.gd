extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn=load("res://Level28.tscn").instantiate()
	var sp=scn.get_node_or_null("Spawns/PlayerStart")
	if sp: print("PlayerStart at px %s = tile (%d,%d)"%[str(sp.position),int(sp.position.x/16),int(sp.position.y/16)])
	else: print("NO PlayerStart")
	quit()
