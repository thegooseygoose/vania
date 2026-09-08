extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn=load("res://Level29.tscn").instantiate()
	var et=scn.get_node("EnemyTiles")
	var L=[]; var M=[]; var R=[]
	for c in et.get_used_cells():
		var ax=et.get_cell_atlas_coords(c).x
		if ax==26: L.append(c)
		elif ax==27: M.append(c)
		elif ax==28: R.append(c)
	print("doors: L=%d M=%d R=%d"%[L.size(),M.size(),R.size()])
	if L.size()>0: print("first door at %s"%str(L[0]))
	# find a door near the start for a screenshot
	var ps=scn.get_node("Spawns/PlayerStart"); var sp=ps.position
	var best=null; var bd=1e20
	for c in L:
		var d=Vector2(c.x*16,c.y*16).distance_to(sp)
		if d<bd: bd=d; best=c
	if best!=null: print("nearest door to start: %s (%.0f px)"%[str(best),bd])
	quit()
