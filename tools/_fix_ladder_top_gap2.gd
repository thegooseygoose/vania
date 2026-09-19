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
	# undo the broken same-column placement (166-169,164) -- it stacked directly
	# under/over both neighbors (167-171 at row167, 166-169 at row161), leaving
	# only 2 clear rows either way (not enough headroom for the 28px player).
	for x in range(166, 170):
		terr.erase_cell(Vector2i(x, 164))
	# re-place OFFSET to the wall side (162-165), clear of both neighbouring
	# columns (167-171 and 166-169), so there's no ceiling-stack conflict at all.
	for x in range(162, 166):
		terr.set_cell(Vector2i(x, 164), 0, atlas)
	print("moved intermediate foothold to row164, x162-165 (offset from both neighbours)")
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
