extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn=load("res://Level28.tscn").instantiate()
	var sp=scn.get_node_or_null("Spawns/PlayerStart")
	print("Level28 PlayerStart exists: %s"%str(sp!=null))
	if sp: print("  at %s"%str(sp.position))
	var terr=scn.get_node_or_null("Terrain")
	if terr:
		var cells=terr.get_used_cells()
		print("Level28 terrain cells=%d"%cells.size())
		# find a standable floor cell (open above, solid below)
		var found=false
		for c in cells:
			var below=Vector2i(c.x,c.y)
			# c is solid; check cell above is open and used as floor
			var above=Vector2i(c.x,c.y-1)
			if terr.get_cell_source_id(above)<0 and terr.get_cell_source_id(Vector2i(c.x,c.y-2))<0:
				print("  suggest PlayerStart feet at tile (%d,%d) = px (%d,%d)"%[c.x,c.y,c.x*16+8,c.y*16])
				found=true; break
	var sn=scn.get_node_or_null("Spawns")
	print("Spawns node exists: %s"%str(sn!=null))
	quit()
