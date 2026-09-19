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

	# Small zigzag: each rung 3 rows up AND ~3 tiles over from the last (never
	# straight overhead -- a straight-up stack is unclimbable, the rung above
	# blocks the one below like a ceiling). Small horizontal offset keeps each
	# hop well inside this engine's slow air-control speed (~1.1px/frame).
	var LEFT0 := 164; var LEFT1 := 166     # left position
	var RIGHT0 := 167; var RIGHT1 := 169   # right position (touching, not overlapping -- 3-tile centre shift)
	var rows: Array = []
	var y := Y_BOT
	while y >= Y_TOP + 1:
		rows.append(y)
		y -= 2

	for i in range(rows.size()):
		var r: int = rows[i]
		var x0: int = LEFT0 if i % 2 == 0 else RIGHT0
		var x1: int = LEFT1 if i % 2 == 0 else RIGHT1
		for x in range(x0, x1 + 1):
			terr.set_cell(Vector2i(x, r), 0, atlas)

	print("cleared interior, built %d-rung small-zigzag ladder, rows=%s" % [rows.size(), str(rows)])
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
