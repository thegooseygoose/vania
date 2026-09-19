extends SceneTree
const W := 480; const H := 450
func idx(x:int,y:int)->int: return y*W+x
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var atlas := PackedInt32Array(); atlas.resize(W*H); atlas.fill(-1)
	for c in terr.get_used_cells():
		if c.x>=0 and c.x<W and c.y>=0 and c.y<H:
			atlas[idx(c.x,c.y)] = terr.get_cell_atlas_coords(c).x
	var adj_75_72 := 0
	var sample_locs := []
	for y in range(0, H-1):
		for x in range(0, W-1):
			var a := atlas[idx(x,y)]
			var r := atlas[idx(x+1,y)]
			var d := atlas[idx(x,y+1)]
			if (a==75 and (r==72 or d==72)) or (a==72 and (r==75 or d==75)):
				adj_75_72 += 1
				if sample_locs.size() < 10: sample_locs.append(Vector2i(x,y))
	print("blue(75)/orange(72) adjacent pairs: ", adj_75_72)
	print("sample locations: ", sample_locs)
	quit()
