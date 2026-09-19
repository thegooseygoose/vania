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

	# Rungs alternate LEFT (163-165) / RIGHT (170-172), each 3 rows apart vertically
	# (well within the ~4.29-tile measured jump apex) -- but because they alternate
	# sides, the SAME column only repeats every 6 rows, giving 5 clear rows (80px)
	# of real headroom above each rung, comfortably more than the player's 28px
	# collision height. (A same-column 3-row spacing was tested and measured to
	# leave only 32px clearance -- collided with the next rung almost immediately.)
	var LA0 := 163; var LA1 := 165
	var LB0 := 170; var LB1 := 172
	var rows: Array = []
	var y := Y_BOT
	while y >= Y_TOP + 2:
		rows.append(y)
		y -= 3

	for i in range(rows.size()):
		var r: int = rows[i]
		var x0: int = LA0 if i % 2 == 0 else LB0
		var x1: int = LA1 if i % 2 == 0 else LB1
		for x in range(x0, x1 + 1):
			terr.set_cell(Vector2i(x, r), 0, atlas)

	print("cleared interior, built %d-rung alternating ladder, rows=%s" % [rows.size(), str(rows)])
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
