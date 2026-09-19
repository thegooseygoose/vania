extends SceneTree
## x164 has a repeating pattern: standable floors every 6 rows (245,251,257,263,269) each with a
## single 1-tile solid blocker directly 4 rows above the floor below it (246,252,258,264),
## capping the JH=4 climb exactly at the blocker every time. Clear all 4 blockers to open a
## continuous path from the bwd-reached y269 floor up into the fwd-conquered region at y245.
var terr
func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level29.tscn").instantiate()
	terr = scn.get_node("Terrain")
	terr.erase_cell(Vector2i(164, 246))
	terr.erase_cell(Vector2i(164, 252))
	terr.erase_cell(Vector2i(164, 258))
	terr.erase_cell(Vector2i(164, 264))
	_reown(scn, scn)
	var packed := PackedScene.new(); packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("built footholds8 (clear x164 y246/252/258/264), saved err=%d" % err)
	quit()
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
