extends SceneTree
const W := 480; const H := 450
func idx(x:int,y:int)->int: return y*W+x
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var et = scn.get_node("EnemyTiles")
	var mk = scn.get_node("Markers")
	var solid = PackedByteArray(); solid.resize(W*H)
	for c in terr.get_used_cells():
		var ax: int = terr.get_cell_atlas_coords(c).x
		if c.x>=0 and c.x<W and c.y>=0 and c.y<H and (ax<45 or ax>=67): solid[idx(c.x,c.y)]=1
	var start := Vector2i(-9,-9); var goal := Vector2i(-9,-9)
	for c in mk.get_used_cells():
		var a = mk.get_cell_atlas_coords(c).x
		if a==18: start=c
		if a==19: goal=c
	# get door cells for proximity checks
	var doors := []
	for c in et.get_used_cells():
		var ax: int = et.get_cell_atlas_coords(c).x
		if ax>=26 and ax<=28: doors.append(c)
	print("start=", start, " goal=", goal, " doors=", doors.size())

	var issues := []
	var enemy_cells := []
	for c in et.get_used_cells():
		var ax: int = et.get_cell_atlas_coords(c).x
		if ax in [24,25,29,31,35]:
			enemy_cells.append([c, ax])

	for pair in enemy_cells:
		var c: Vector2i = pair[0]; var ax: int = pair[1]
		# 1) too close to start (unfair immediate ambush)
		if c.distance_to(start) < 6:
			issues.append("TOO CLOSE TO START: %s atlas=%d dist=%.1f" % [str(c), ax, c.distance_to(start)])
		# 2) sitting exactly on/adjacent to a door cell (blocks the doorway unfairly)
		for d in doors:
			if c.distance_to(d) < 3:
				issues.append("BLOCKS DOORWAY: %s atlas=%d near door %s" % [str(c), ax, str(d)])
				break
		# 3) embedded in solid terrain (shouldn't happen, but verify)
		if solid[idx(c.x,c.y)] == 1:
			issues.append("EMBEDDED IN WALL: %s atlas=%d" % [str(c), ax])
	print("ISSUES FOUND: ", issues.size())
	for i in issues: print("  ", i)

	# 4) local clustering: any two ground enemies within 4 tiles of each other (too dense)
	var close_pairs := 0
	for i in range(enemy_cells.size()):
		for j in range(i+1, enemy_cells.size()):
			if enemy_cells[i][0].distance_to(enemy_cells[j][0]) < 5:
				close_pairs += 1
				print("  CLUSTERED: ", enemy_cells[i][0], " & ", enemy_cells[j][0])
	print("cluster pairs: ", close_pairs)
	quit()
