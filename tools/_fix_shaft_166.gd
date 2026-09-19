extends SceneTree
func _initialize(): call_deferred("_run")
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	# Shaft at x160-175 (left wall 160-161, right wall 174-175), climbing from the
	# floor at y195 up to the narrow corridor cap at y164. Existing natural footholds
	# are spaced up to 5-6 tiles apart (too tall for a single un-upgraded jump) --
	# add one intermediate foothold in each of the two worst gaps (181->176 gap=5,
	# 172->166 gap=6), 4 tiles wide, matching the existing wall-palette tile (atlas 76),
	# on the LEFT side of the shaft (x162-165) clear of the existing zigzag decorations.
	var atlas := Vector2i(76, 0)
	var new_ledges := [
		{"y": 179, "x0": 162, "x1": 165},   # splits the 181->176 gap into 2+3
		{"y": 169, "x0": 162, "x1": 165},   # splits the 172->166 gap into 3+3
	]
	for L in new_ledges:
		for x in range(L["x0"], L["x1"] + 1):
			terr.set_cell(Vector2i(x, L["y"]), 0, atlas)
		# clear headroom above each new ledge (3 rows) so the player can stand there
		for x in range(L["x0"], L["x1"] + 1):
			terr.erase_cell(Vector2i(x, L["y"] - 1))
			terr.erase_cell(Vector2i(x, L["y"] - 2))
			terr.erase_cell(Vector2i(x, L["y"] - 3))
		print("added foothold at y=%d x=%d-%d" % [L["y"], L["x0"], L["x1"]])
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
