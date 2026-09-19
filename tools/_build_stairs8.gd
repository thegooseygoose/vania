extends SceneTree
## Piece 1 of the big x100-175/y199-336 fwd-only zone (much larger than the reported
## "x167 h22" drop-edge entry suggested -- that's a separate small local gap near y390-412,
## this is a different, much bigger disconnect further north). Confirmed genuinely open room
## at x96-160/y210-239 (30 tall) via _dump_area.gd -- bounded left by a wall at x95, ceiling
## at y208-209, floor-ish structure starting y240. Using the x97-110 lane (confirmed open the
## whole height even where a wall splits the room lower down at x112-127). Wide-lane zigzag,
## same technique as _build_stairs2/3/6/7.gd.
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
	_clear_rect(97, 110, 209, 239)
	_zigzag(98, 109, 238, 210, 100, 1)
	_reown(scn, scn)
	var packed := PackedScene.new(); packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("built stairs8 (x97-110 room, y210-239), saved err=%d" % err)
	quit()
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
