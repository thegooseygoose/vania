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

	# WIDE alternating platforms spanning half the shaft each (162-167 / 168-173,
	# adjacent not overlapping) -- only a SMALL sideways drift is needed to cross
	# from one to the other (not a precise centre-to-centre jump), which tolerates
	# this engine's slow air-control speed much better. 3 rows apart vertically
	# (well within the measured ~4.29-tile jump apex); same-side repeats every 6
	# rows (5 clear rows = 80px headroom, well over the player's 28px height).
	var LEFT0 := 162; var LEFT1 := 167
	var RIGHT0 := 168; var RIGHT1 := 173
	var rows: Array = []
	var y := Y_BOT
	while y >= Y_TOP + 2:
		rows.append(y)
		y -= 3

	for i in range(rows.size()):
		var r: int = rows[i]
		var x0: int = LEFT0 if i % 2 == 0 else RIGHT0
		var x1: int = LEFT1 if i % 2 == 0 else RIGHT1
		for x in range(x0, x1 + 1):
			terr.set_cell(Vector2i(x, r), 0, atlas)

	print("cleared interior, built %d-rung wide-alternating ladder, rows=%s" % [rows.size(), str(rows)])
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
