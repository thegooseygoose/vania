extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level5.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var r: Rect2i = terr.get_used_rect()
	print("Terrain used_rect: ", r, "  -> lvl_right would be ~", (r.position.x + r.size.x) * 16, "px (tile ", r.position.x + r.size.x, ")")
	# also check WITHOUT deco tiles (atlas>=60), matching main.gd's _terrain_extent_no_deco
	var minx := 99999; var maxx := -99999
	for c in terr.get_used_cells():
		var ax: int = terr.get_cell_atlas_coords(c).x
		if ax < 60:
			minx = min(minx, c.x); maxx = max(maxx, c.x)
	print("no-deco extent: x=[%d..%d] -> lvl_right ~%d px" % [minx, maxx, (maxx+1)*16])
	quit()
