extends SceneTree
const W := 480; const H := 450
var solid := PackedByteArray()
func idx(x:int,y:int)->int: return y*W+x
func floor_row(x: int, y0: int) -> int:
	for y in range(y0, y0 + 14):
		if y < H and solid[idx(x, y)] == 1: return y
	return -1
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var et = scn.get_node("EnemyTiles")
	solid.resize(W*H)
	for c in terr.get_used_cells():
		var ax: int = terr.get_cell_atlas_coords(c).x
		if c.x>=0 and c.x<W and c.y>=0 and c.y<H and (ax<45 or ax>=67): solid[idx(c.x,c.y)]=1
	var cellmap := {}
	for c in et.get_used_cells():
		var ax: int = et.get_cell_atlas_coords(c).x
		if ax>=26 and ax<=28: cellmap[c] = ax
	var doorL := []
	for c in cellmap.keys():
		if cellmap[c] == 26: doorL.append(c)

	var found := []
	for L in doorL:
		var door_floor: int = floor_row(L.x + 1, L.y)
		if door_floor < 0: continue
		for side in [-2, 4]:
			var cx: int = L.x + side
			var cur_floor: int = floor_row(cx, L.y)
			if cur_floor < 0: continue
			# find the floor 2 tiles further out (past where the fix built up to) to see the
			# ACTUAL step a player standing there faces
			var outer_floor: int = floor_row(cx + (2 if side < 0 else -2), L.y)
			if outer_floor < 0: continue
			var step: int = outer_floor - door_floor
			if step >= 5:
				found.append([cx, door_floor, outer_floor, step])
	print("sheer walls (>=5 tile single step) found near doors: ", found.size())
	for f in found:
		print("  x=%d door_floor_y=%d outer_floor_y=%d step_height=%d" % [f[0], f[1], f[2], f[3]])
	quit()
