extends SceneTree
func _initialize(): call_deferred("_run")
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
func _run():
	var f := FileAccess.open("res://tools/_checker_cells.txt", FileAccess.READ)
	var cells := []
	while not f.eof_reached():
		var line := f.get_line()
		if line == "": continue
		var parts := line.split(",")
		cells.append(Vector2i(int(parts[0]), int(parts[1])))
	f.close()
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	for c in cells:
		terr.set_cell(c, 0, Vector2i(73, 0))   # plain grey — reads as ordinary rock, not a fake door
	print("neutralized %d checker-pattern (fake-door-looking) cells to plain grey" % cells.size())
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
