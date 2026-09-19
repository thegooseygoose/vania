extends SceneTree
## Minimal version of footholds3: just widen the throat at (168,282) by clearing that one solid
## tile (plus 1 neighbor each side for safety), no platform, no headroom erase -- footholds3's
## platform+headroom-clear broke GOAL_REACHABLE, so try the smallest possible change first.
var terr
func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level29.tscn").instantiate()
	terr = scn.get_node("Terrain")
	for x in range(167, 170):
		terr.erase_cell(Vector2i(x, 282))
	_reown(scn, scn)
	var packed := PackedScene.new(); packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("built footholds4 (clear x167-169,y282), saved err=%d" % err)
	quit()
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
