extends SceneTree
func _initialize(): call_deferred("_run")
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var target := Vector2i(31, 203)
	print("before: source_id=", terr.get_cell_source_id(target), " atlas=", terr.get_cell_atlas_coords(target))
	terr.erase_cell(target)
	print("erased (31,203)")
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
