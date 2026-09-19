extends SceneTree
## x108/y199-246 is another clean, mostly-open shaft (only one existing floor at y207-208).
## Backward already reaches down to y246 from below; chaining platforms every ~8 tiles up to
## connect with the existing y207/208 floor, which then bridges the remaining 8 tiles to the
## fwd-conquered region at y199 in a single combo.
var terr
func _plat(x: int, y: int) -> void:
	terr.set_cell(Vector2i(x, y), 0, Vector2i(13, 0))
func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level29.tscn").instantiate()
	terr = scn.get_node("Terrain")
	_plat(108, 247)
	_plat(108, 239)
	_plat(108, 231)
	_plat(108, 223)
	_plat(108, 215)
	_reown(scn, scn)
	var packed := PackedScene.new(); packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("built footholds10 (x108 shaft, 4 platforms), saved err=%d" % err)
	quit()
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
