extends SceneTree
func _initialize(): call_deferred("_run")
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	# the tapering overhang block found at x=132..138, y=196..206 — erase it entirely
	for x in range(131, 139):
		for y in range(195, 208):
			terr.erase_cell(Vector2i(x, y))
	print("cleared the overhang block near door (137,207)")
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
