extends SceneTree
const W := 520; const H := 450
var solid := PackedByteArray()
func idx(x:int,y:int)->int: return y*W+x
func floor_row(x: int, y0: int) -> int:
	for y in range(y0, y0 + 12):
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

	var mismatches := []
	for L in doorL:
		var door_floor: int = floor_row(L.x + 1, L.y)
		var left_floor: int = floor_row(L.x - 2, L.y)
		var right_floor: int = floor_row(L.x + 4, L.y)
		var m1: int = door_floor - left_floor if door_floor>0 and left_floor>0 else 0
		var m2: int = door_floor - right_floor if door_floor>0 and right_floor>0 else 0
		if absi(m1) >= 2 or absi(m2) >= 2:
			mismatches.append([L, m1, m2])
	print("doors with >=2 tile floor mismatch to either side: ", mismatches.size())
	for m in mismatches:
		print("  door@", m[0], " left_diff=", m[1], " right_diff=", m[2])
	quit()
