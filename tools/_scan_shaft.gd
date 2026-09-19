extends SceneTree
## Reusable: prints per-row open x-run ranges within a window, for planning a ladder.
## Usage: -s tools/_scan_shaft.gd -- x0 x1 y0 y1
const W := 520; const H := 450
func idx(x:int,y:int)->int: return y*W+x
func _initialize(): call_deferred("_run")
func _run():
	var args := OS.get_cmdline_user_args()
	var x0:int = int(args[0]); var x1:int = int(args[1])
	var y0:int = int(args[2]); var y1:int = int(args[3])
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var solid = PackedByteArray(); solid.resize(W*H)
	for c in terr.get_used_cells():
		var ax: int = terr.get_cell_atlas_coords(c).x
		if c.x>=0 and c.x<W and c.y>=0 and c.y<H and (ax<45 or ax>=67): solid[idx(c.x,c.y)]=1
	for y in range(y0, y1+1):
		var runs := []
		var run_start := -1
		for x in range(x0, x1+1):
			var open: bool = solid[idx(x,y)]==0
			if open and run_start == -1: run_start = x
			if not open and run_start != -1:
				runs.append("%d-%d" % [run_start, x-1])
				run_start = -1
		if run_start != -1: runs.append("%d-%d" % [run_start, x1])
		print("y=%3d open: %s" % [y, ", ".join(runs)])
	quit()
