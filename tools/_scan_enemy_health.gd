extends SceneTree
const W := 480
const H := 450
func idx(x:int,y:int)->int: return y*W+x
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var et = scn.get_node("EnemyTiles")
	var mk = scn.get_node("Markers")
	var pw = scn.get_node("Powerups")
	var solid = PackedByteArray(); solid.resize(W*H)
	for c in terr.get_used_cells():
		var ax: int = terr.get_cell_atlas_coords(c).x
		if c.x>=0 and c.x<W and c.y>=0 and c.y<H and (ax<45 or ax>=67): solid[idx(c.x,c.y)]=1
	var enemies := []
	var kinds := {}
	for c in et.get_used_cells():
		var ax: int = et.get_cell_atlas_coords(c).x
		if ax in [24,25,29,30,31,35,36]:   # zoomer,serp,bug,metroid,virus,turret,urchin
			enemies.append(c)
			kinds[ax] = kinds.get(ax,0)+1
	print("enemy counts by atlas: ", kinds, " total=", enemies.size())
	# embedded-in-wall check
	var embedded := 0
	for c in enemies:
		if solid[idx(c.x,c.y)]==1: embedded += 1
	print("embedded in solid wall: ", embedded)
	# door-adjacent check (within 4 tiles of a door cell)
	var doors := []
	for c in et.get_used_cells():
		var ax: int = et.get_cell_atlas_coords(c).x
		if ax in [26,27,28]: doors.append(c)
	var near_door := 0
	for e in enemies:
		for d in doors:
			if abs(e.x-d.x)<=4 and abs(e.y-d.y)<=4:
				near_door += 1
				break
	print("within 4 tiles of a door: ", near_door, " (out of ", enemies.size(), ")")
	# clustered check (within 3 tiles of another enemy)
	var clustered := 0
	for i in range(enemies.size()):
		for j in range(i+1, enemies.size()):
			if abs(enemies[i].x-enemies[j].x)<=3 and abs(enemies[i].y-enemies[j].y)<=3:
				clustered += 1
	print("tight enemy pairs (<=3 tiles apart): ", clustered)
	quit()
