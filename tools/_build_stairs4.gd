extends SceneTree
## Extends the Gap-A staircase (x=168-190) much further UP, from its current top (y=350) all the
## way to y=100 — the several big west-side gap components (_find_gap2.gd) all sit in y-bands
## between 100-350 with their right edge right around x=162-173, bordering this same corridor, so
## extending the climb through the same spine should absorb several of them in one pass rather than
## building a separate staircase per room.
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
	_clear_rect(168, 191, 100, 349)
	_zigzag(170, 189, 349, 101, 172, -1)
	_reown(scn, scn)
	var packed := PackedScene.new(); packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("extended staircase up to y=101, saved err=%d" % err)
	quit()
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
