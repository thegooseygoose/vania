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

	# Shaft interior: x162-173 (walls at 160-161 and 174-175 stay untouched),
	# y165 (top, under the corridor cap at y164) down to y194 (bottom, above the
	# y195 landing). Fully clear the interior first (kills every leftover spike/
	# ledge fragment from the old jump-based layout), then carve a literal
	# 1-tile-over/1-tile-up zigzag staircase -- walkable via the engine's plain
	# "step up while walking" rule, no jump arc involved at all.
	var X0 := 162; var X1 := 173
	var Y_TOP := 165; var Y_BOT := 194
	for x in range(X0, X1 + 1):
		for y in range(Y_TOP, Y_BOT + 1):
			terr.erase_cell(Vector2i(x, y))

	var X_MIN := 163; var X_MAX := 172
	var x := X_MAX
	var y := Y_BOT
	var dir := -1
	var steps: Array = []
	while y >= Y_TOP:
		steps.append(Vector2i(x, y))
		x += dir
		if x < X_MIN:
			x = X_MIN; dir = 1
		elif x > X_MAX:
			x = X_MAX; dir = -1
		y -= 1

	for s in steps:
		terr.set_cell(s, 0, atlas)
	# headroom: clear 3 rows above every step
	for s in steps:
		for dy in range(1, 4):
			terr.erase_cell(Vector2i(s.x, s.y - dy))

	print("cleared interior x=%d-%d y=%d-%d, carved %d-step zigzag staircase" % [X0, X1, Y_TOP, Y_BOT, steps.size()])
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
