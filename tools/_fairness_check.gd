extends SceneTree
const W := 480; const H := 450
func idx(x:int,y:int)->int: return y*W+x
var solid := PackedByteArray()
func sol(x:int,y:int)->bool:
	return x<0 or x>=W or y<0 or y>=H or solid[idx(x,y)]==1
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var et = scn.get_node("EnemyTiles")
	solid.resize(W*H)
	for c in terr.get_used_cells():
		var ax: int = terr.get_cell_atlas_coords(c).x
		if c.x>=0 and c.x<W and c.y>=0 and c.y<H and (ax<45 or ax>=67): solid[idx(c.x,c.y)]=1

	var doors := []
	var enemies := []
	for c in et.get_used_cells():
		var ax: int = et.get_cell_atlas_coords(c).x
		if ax>=26 and ax<=28: doors.append(c)
		elif ax in [24,25,29,31,35]: enemies.append([c, ax])

	print("total enemies: ", enemies.size())
	var near_door := 0
	var narrow_corridor := 0
	var after_drop := 0
	for pair in enemies:
		var c: Vector2i = pair[0]
		# near a door (within 6 tiles horizontally, same-ish row) = ambush risk right at a transition
		for d in doors:
			if absf(c.x - d.x) <= 6 and absf(c.y - d.y) <= 2:
				near_door += 1
				break
		# narrow corridor: total open vertical clearance at this x,y is <= 3 tiles (cramped, hard to jump over/dodge)
		var open_above := 0
		for dy in range(1, 6):
			if sol(c.x, c.y - dy): break
			open_above += 1
		if open_above <= 2:
			narrow_corridor += 1
		# after a blind drop: the cell 4-8 tiles directly above is OPEN for a long stretch (a fall)
		# landing right on/near the enemy with no warning
		var fall_clear = 0
		for dy in range(2, 10):
			if sol(c.x, c.y - dy): break
			fall_clear += 1
		if fall_clear >= 6:
			after_drop += 1

	print("near a door (ambush-at-transition risk): ", near_door)
	print("narrow corridor (<=2 tile clearance, hard to dodge): ", narrow_corridor)
	print("right after a long blind drop (>=6 tile fall onto it): ", after_drop)
	quit()
