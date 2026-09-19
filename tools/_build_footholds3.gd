extends SceneTree
## Bridges the x158-182/y281-289 pinch found via _dump_reach.gd: fwd reaches y281, a solid tile
## at (168,282) plus the open-but-unreached y283-288 stretch, bwd already reaches y289. A
## re-grounding platform in the open stretch gives a fresh 8-tile combo to cover the remaining gap.
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
	_platform(166, 170, 287)
	_reown(scn, scn)
	var packed := PackedScene.new(); packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("built footholds3 (x166-170 platform, y286/287), saved err=%d" % err)
	quit()
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
