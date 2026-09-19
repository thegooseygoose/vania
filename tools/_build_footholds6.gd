extends SceneTree
## Narrower retry of footholds3: single-column platform at x168 only (confirmed via _dump_reach.gd
## to be '.'=unclaimed by either fwd or bwd across y283-288, unlike neighboring x166-167/x169 which
## have real F content forward already uses -- footholds3's 5-wide platform touched those and broke
## GOAL_REACHABLE). Solid at y286 (standable y285), headroom erase 284/283 only (282 already solid).
const WALL := 13
var terr
func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level29.tscn").instantiate()
	terr = scn.get_node("Terrain")
	terr.set_cell(Vector2i(168, 286), 0, Vector2i(WALL, 0))
	terr.erase_cell(Vector2i(168, 285))
	terr.erase_cell(Vector2i(168, 284))
	terr.erase_cell(Vector2i(168, 283))
	_reown(scn, scn)
	var packed := PackedScene.new(); packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("built footholds6 (x168 single-column platform, y285/286), saved err=%d" % err)
	quit()
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
