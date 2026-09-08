extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn=load("res://Level29.tscn").instantiate()
	var mk=scn.get_node("Markers")
	print("Markers:")
	for c in mk.get_used_cells():
		var ax=mk.get_cell_atlas_coords(c).x
		var nm = "START(18)" if ax==18 else ("GOAL(19)" if ax==19 else str(ax))
		print("  (%d,%d) atlas=%d %s  worldpx=(%d,%d)"%[c.x,c.y,ax,nm,c.x*16,c.y*16])
	var ps=scn.get_node("Spawns/PlayerStart")
	print("PlayerStart marker at px=(%.0f,%.0f) = tile (%d,%d)"%[ps.position.x,ps.position.y,int(ps.position.x/16),int(ps.position.y/16)])
	quit()
