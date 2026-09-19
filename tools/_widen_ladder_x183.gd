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

	var Y_TOP := 345; var Y_BOT := 441
	var rows: Array = []
	var y := Y_BOT
	while y >= Y_TOP + 2:
		rows.append(y)
		y -= 3

	# original rungs were LEFT=180-184 / RIGHT=185-189, but the cleared interior was
	# 179-193 -- widen each rung to fill the full cleared width so there's no
	# leftover open strip at 179 or 190-193 that still falls straight through.
	for i in range(rows.size()):
		var r: int = rows[i]
		if i % 2 == 0:
			terr.set_cell(Vector2i(179, r), 0, atlas)       # extend LEFT one tile left
		else:
			for x in range(190, 194):
				terr.set_cell(Vector2i(x, r), 0, atlas)     # extend RIGHT to fill 190-193
	print("widened %d rungs to close the edge gaps" % rows.size())
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
