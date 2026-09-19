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
	for x in range(162, 166):
		terr.erase_cell(Vector2i(x, 164))
	# move up one more row (163, 4-row gap from the departure ledge at 167, giving
	# 3 full clear rows of headroom AND more airtime for the ~5-tile horizontal
	# drift needed since both neighbouring ledges cluster around x166-171).
	for x in range(162, 166):
		terr.set_cell(Vector2i(x, 163), 0, atlas)
	print("moved intermediate foothold to row163, x162-165")
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
