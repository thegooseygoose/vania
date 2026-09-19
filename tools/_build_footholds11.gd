extends SceneTree
## x93/y207-260 is another totally clean, unobstructed shaft (confirmed via _debug_stand.gd),
## real grounded floor at y260/261. Chaining single-tile re-grounding platforms every 8 tiles
## from there up toward the fwd-conquered region at y196, same pattern as the big x167 win.
var terr
func _plat(x: int, y: int) -> void:
	terr.set_cell(Vector2i(x, y), 0, Vector2i(13, 0))
func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level29.tscn").instantiate()
	terr = scn.get_node("Terrain")
	_plat(93, 253)
	_plat(93, 245)
	_plat(93, 237)
	_plat(93, 229)
	_plat(93, 221)
	_plat(93, 213)
	_plat(93, 205)
	_reown(scn, scn)
	var packed := PackedScene.new(); packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("built footholds11 (x93 shaft, 7 platforms), saved err=%d" % err)
	quit()
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
