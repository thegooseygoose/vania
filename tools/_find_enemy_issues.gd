extends SceneTree
const W := 480
const H := 450
func idx(x:int,y:int)->int: return y*W+x
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var et = scn.get_node("EnemyTiles")
	var solid = PackedByteArray(); solid.resize(W*H)
	for c in terr.get_used_cells():
		var ax: int = terr.get_cell_atlas_coords(c).x
		if c.x>=0 and c.x<W and c.y>=0 and c.y<H and (ax<45 or ax>=67): solid[idx(c.x,c.y)]=1
	var enemies := []
	for c in et.get_used_cells():
		var ax: int = et.get_cell_atlas_coords(c).x
		if ax in [24,25,29,30,31,35,36]:
			enemies.append([c, ax])
	print("--- embedded ---")
	for e in enemies:
		var c: Vector2i = e[0]
		if solid[idx(c.x,c.y)]==1:
			print("  cell=", c, " atlas=", e[1])
	var doors := []
	for c in et.get_used_cells():
		var ax: int = et.get_cell_atlas_coords(c).x
		if ax in [26,27,28]: doors.append(c)
	print("--- near door (<=4 tiles) ---")
	for e in enemies:
		var c: Vector2i = e[0]
		for d in doors:
			if abs(c.x-d.x)<=4 and abs(c.y-d.y)<=4:
				print("  cell=", c, " atlas=", e[1], " near door=", d, " dist=(", c.x-d.x, ",", c.y-d.y, ")")
				break
	quit()
