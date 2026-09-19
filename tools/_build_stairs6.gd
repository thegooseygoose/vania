extends SceneTree
## Fixes the x=480 one-way drop (origin_y=336 -> dest_y=385, h=49) approaching the BROOD arena:
## x=480-495/y=330-386 is one continuous open cavern (confirmed via _dump_area.gd), floor starts
## at y=386. Wide-lane zigzag staircase, same proven technique as _build_stairs2/3.gd.
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
	_clear_rect(480, 495, 328, 385)
	_zigzag(481, 494, 384, 329, 483, 1)
	_reown(scn, scn)
	var packed := PackedScene.new(); packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("built stairs6 (x480 BROOD-approach shaft), saved err=%d" % err)
	quit()
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
