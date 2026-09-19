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

	# Straight vertical column, SAME x every rung -- but spaced 4 rows apart this
	# time (not 3): that leaves 3 fully-open rows (48px) of real headroom above
	# each rung, comfortably more than the player's 28px collision height, while a
	# 4-tile (64px) net rise is still under the measured real max-apex (~68.6px).
	# (3-row spacing measured only 32px clearance -- collided almost immediately.)
	var LX0 := 166; var LX1 := 169
	var rows: Array = []
	var y := Y_BOT
	while y >= Y_TOP + 2:
		rows.append(y)
		y -= 4

	for r in rows:
		for x in range(LX0, LX1 + 1):
			terr.set_cell(Vector2i(x, r), 0, atlas)

	print("cleared interior, built %d-rung vertical ladder (spacing 4) at x=%d-%d, rows=%s" % [rows.size(), LX0, LX1, str(rows)])
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
