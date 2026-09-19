extends SceneTree
## Fixes the west room (x50-130,y392-402) one-way drop: forward reaches y392 (entry from the
## side, room bounded by solid floor y403 and solid ceiling y391) but the 10-tile fall from
## y392->y402 exceeds the JH=4+doublejump (~8 tile) model. Two small redundant footholds at
## y=397 split it into two ~5-tile climbs. Headroom cleared 3 rows above each.
const WALL := 13
var terr
func _platform(x0: int, x1: int, y: int) -> void:
	for x in range(x0, x1 + 1):
		terr.set_cell(Vector2i(x, y), 0, Vector2i(WALL, 0))
		terr.erase_cell(Vector2i(x, y - 1))
		terr.erase_cell(Vector2i(x, y - 2))
		terr.erase_cell(Vector2i(x, y - 3))
func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level29.tscn").instantiate()
	terr = scn.get_node("Terrain")
	_platform(60, 63, 397)
	_platform(100, 103, 397)
	_reown(scn, scn)
	var packed := PackedScene.new(); packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("built footholds1 (west room y392-402), saved err=%d" % err)
	quit()
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
