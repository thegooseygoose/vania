extends SceneTree
## Builds TWO zigzag staircases in Level29 to close the two tallest one-way-drop backtracking gaps
## found by tools/_find_dropedges.gd (2026-09-11 session): x~179 shaft (349->424, height 75) and
## x~444 shaft (301->372, height 71, replacing an old broken single-diagonal wall attempt).
## Zigzag (not a single 45-deg line) because the available corridor width is much less than the
## total height; steps bounce between X_MIN/X_MAX, still always exactly 1-over/1-up so the engine's
## normal "step up 1 tile while walking" rule carries the player, per the staircase recipe in
## memory/vania-level29-realdoors.md (solid steps only, NO floor-ledges/jump-arcs).
## Run: Godot --headless --path . -s tools/_build_stairs2.gd

const WALL := 13

var terr

func _clear_rect(x0: int, x1: int, y0: int, y1: int) -> void:
	for x in range(x0, x1 + 1):
		for y in range(y0, y1 + 1):
			terr.erase_cell(Vector2i(x, y))

func _zigzag(x_min: int, x_max: int, y_bottom_step: int, y_top_step: int, x_start: int, dir0: int) -> void:
	var x := x_start
	var dir := dir0
	var y := y_bottom_step
	while y >= y_top_step:
		terr.set_cell(Vector2i(x, y), 0, Vector2i(WALL, 0))
		# headroom: clear 3 rows above this step so the corridor stays walkable
		terr.erase_cell(Vector2i(x, y - 1))
		terr.erase_cell(Vector2i(x, y - 2))
		terr.erase_cell(Vector2i(x, y - 3))
		x += dir
		y -= 1
		if x >= x_max: dir = -1
		elif x <= x_min: dir = 1

func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level29.tscn").instantiate()
	terr = scn.get_node("Terrain")

	# GAP A: x~179 shaft, existing floor at y>=424 (untouched), fwd-reached open area starts y<=349.
	_clear_rect(173, 190, 349, 423)
	_zigzag(175, 188, 422, 350, 178, 1)

	# GAP B: x~444 shaft, existing pillar room starts y>=368 (untouched), fwd-reached open area y<=301.
	# also clears the old broken single-diagonal wall attempt (x415-443, y317-345) that never worked.
	_clear_rect(414, 450, 302, 367)
	_zigzag(416, 448, 366, 302, 420, 1)

	_reown(scn, scn)
	var packed := PackedScene.new(); packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("built 2 zigzag staircases, saved err=%d" % err)
	quit()

func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
