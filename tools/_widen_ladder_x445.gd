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

	var Y_TOP := 303; var Y_BOT := 371
	var rows: Array = []
	var y := Y_BOT
	while y >= Y_TOP + 2:
		rows.append(y)
		y -= 3

	# same edge-gap fix as the x183 ladder: interior clear was 437-451, but rungs
	# were only LEFT=438-442 / RIGHT=443-447, leaving 437 and 448-451 open.
	for i in range(rows.size()):
		var r: int = rows[i]
		if i % 2 == 0:
			terr.set_cell(Vector2i(437, r), 0, atlas)
		else:
			for x in range(448, 452):
				terr.set_cell(Vector2i(x, r), 0, atlas)
	print("widened %d rungs to close the edge gaps" % rows.size())
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
