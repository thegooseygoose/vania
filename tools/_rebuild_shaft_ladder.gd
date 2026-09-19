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

	var X0 := 162; var X1 := 173
	var Y_TOP := 165; var Y_BOT := 194
	for x in range(X0, X1 + 1):
		for y in range(Y_TOP, Y_BOT + 1):
			terr.erase_cell(Vector2i(x, y))

	# Straight vertical jump-ladder, no sideways aiming needed: footholds at the
	# SAME x (166-169, centred in the shaft) every 3 rows -- well within a single
	# un-upgraded jump's ~4-tile apex.
	var LX0 := 166; var LX1 := 169
	var rows: Array = []
	var y := Y_BOT
	while y >= Y_TOP + 2:
		rows.append(y)
		y -= 3

	# clear headroom FIRST, then paint rungs LAST so a rung tile always wins even
	# where its headroom-clear range overlaps the next rung up (rungs are 3 apart,
	# same as the headroom depth -- painting order matters or rungs erase each other)
	for r in rows:
		for x in range(LX0, LX1 + 1):
			for dy in range(1, 4):
				terr.erase_cell(Vector2i(x, r - dy))
	for r in rows:
		for x in range(LX0, LX1 + 1):
			terr.set_cell(Vector2i(x, r), 0, atlas)

	print("cleared interior, built %d-rung vertical ladder at x=%d-%d, rows=%s" % [rows.size(), LX0, LX1, str(rows)])
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
