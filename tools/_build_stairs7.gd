extends SceneTree
## Fixes the x=5-10 far-west corridor one-way drop (origin_y~360-366 -> dest_y~374-377, h~14):
## x4-15/y335-385ish is a long open vertical corridor bounded by walls at x0-3/x16-19, segmented
## by full-width floor strips at y375/y381. Fixing just the flagged segment (y359-374, above the
## y375 floor). Wide-lane zigzag, same proven technique as _build_stairs2/3/6.gd.
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
	_clear_rect(5, 14, 359, 374)
	_zigzag(6, 13, 374, 360, 8, 1)
	_reown(scn, scn)
	var packed := PackedScene.new(); packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("built stairs7 (far-west corridor), saved err=%d" % err)
	quit()
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
