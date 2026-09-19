extends SceneTree
## x167/y240-283 is a genuinely clean, totally open 43-tile shaft (confirmed via _debug_stand.gd
## -- zero obstructions the whole way) with a real floor at y284. Backward's combo (max 8 tiles)
## stops exactly at y275 (283-8), matching the model's math precisely -- same pattern as the big
## footholds2 win. Chaining 5 single-column re-grounding platforms every 8 tiles to bridge the
## whole shaft from the real floor (284) up to the fwd-conquered region (~y240).
var terr
func _plat(x: int, y: int) -> void:
	terr.set_cell(Vector2i(x, y), 0, Vector2i(13, 0))
func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level29.tscn").instantiate()
	terr = scn.get_node("Terrain")
	_plat(167, 276)
	_plat(167, 268)
	_plat(167, 260)
	_plat(167, 252)
	_plat(167, 244)
	_reown(scn, scn)
	var packed := PackedScene.new(); packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("built footholds9 (x167 shaft, 5 platforms), saved err=%d" % err)
	quit()
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
