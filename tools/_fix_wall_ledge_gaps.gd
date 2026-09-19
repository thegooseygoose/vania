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
	# Every ~15-row cycle of this natural shaft has one tough diagonal jump: a
	# "wall ledge" (x160-164) to the "mid ledge" 5 rows above it (x166-169ish) --
	# a combined 5-tile vertical + ~5-tile horizontal diagonal, right at the edge
	# of what's jumpable (measured max apex ~4.29 tiles). Splitting each with one
	# intermediate foothold partway between fixes all instances at once.
	var wall_rows := [151, 136, 121, 76, 46]   # each has a mid-ledge exactly 5 rows above
	for w in wall_rows:
		var r: int = w - 2   # partway up from the wall ledge toward the mid ledge
		for x in range(163, 167):   # x163-166, blended between wall(160-164) and mid(166-169)
			terr.set_cell(Vector2i(x, r), 0, atlas)
		print("added intermediate foothold at row %d (between wall-ledge %d and mid-ledge %d)" % [r, w, w - 5])
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
