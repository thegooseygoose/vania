extends SceneTree
func _initialize(): call_deferred("_run")
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var atlas := Vector2i(76, 0)
	# 6-row gap between the top of the built ladder (row167, x167-171) and the
	# next natural ledge (row161, x166-169) -- add one intermediate at row164.
	for x in range(166, 170):
		terr.set_cell(Vector2i(x, 164), 0, atlas)
	print("added intermediate foothold at row 164, x166-169")
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
