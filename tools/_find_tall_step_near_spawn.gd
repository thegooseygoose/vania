extends SceneTree
const W := 480; const H := 450
var solid := PackedByteArray()
func idx(x:int,y:int)->int: return y*W+x
func top_solid(x: int, y0: int, y1: int) -> int:
	for y in range(y0, y1):
		if solid[idx(x,y)] == 1: return y
	return -1
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	solid.resize(W*H)
	for c in terr.get_used_cells():
		var ax: int = terr.get_cell_atlas_coords(c).x
		if c.x>=0 and c.x<W and c.y>=0 and c.y<H and (ax<45 or ax>=67): solid[idx(c.x,c.y)]=1
	# scan columns x=20..100 (well around spawn 40,206) for a step of >=4 tiles between adjacent
	# columns' topmost solid row, within y=150..220 (a generous band around spawn's row 206)
	print("scanning x=20..100, y=150..220 for a >=4-tile single-column step:")
	for x in range(21, 100):
		var t0 := top_solid(x-1, 150, 220)
		var t1 := top_solid(x, 150, 220)
		if t0 > 0 and t1 > 0 and absi(t0 - t1) >= 4:
			print("  step at x=%d: col%d_top=%d col%d_top=%d diff=%d" % [x, x-1, t0, x, t1, t1-t0])
	quit()
