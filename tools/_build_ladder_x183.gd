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

	var X0 := 179; var X1 := 193
	var Y_TOP := 345; var Y_BOT := 441
	for x in range(X0, X1 + 1):
		for y in range(Y_TOP, Y_BOT + 1):
			terr.erase_cell(Vector2i(x, y))

	# same proven design as the earlier successful shaft ladder: small ~3-tile
	# alternating shift (well within air-control range), 3 rows apart (well within
	# jump apex + gives 5 clear rows of headroom on same-side repeats).
	var LEFT0 := 180; var LEFT1 := 184
	var RIGHT0 := 185; var RIGHT1 := 189
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

	print("cleared x%d-%d y%d-%d, built %d-rung ladder" % [X0, X1, Y_TOP, Y_BOT, rows.size()])
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
