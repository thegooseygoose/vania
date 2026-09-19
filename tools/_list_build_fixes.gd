extends SceneTree
const W := 480; const H := 450
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
	# doors within the pre-double-jump explorable zone (bbox x16-131,y196-284, generous margin)
	print("doors in the early (no-double-jump) explorable zone, x=[10..140] y=[190..290]:")
	for L in doorL:
		if L.x >= 10 and L.x <= 140 and L.y >= 190 and L.y <= 290:
			print("  door@", L)
	quit()
