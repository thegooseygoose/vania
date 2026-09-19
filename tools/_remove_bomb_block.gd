extends SceneTree
func _initialize(): call_deferred("_run")
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	# floating debris block blocking the jump up to the bomb powerup at (470,361):
	# found at x=470-471,y=362 and x=469-472,y=363 (a small pillar in the middle of
	# the open shaft below the bomb ledge). Clear a small buffer box around it.
	for x in range(468, 474):
		for y in range(361, 365):
			terr.erase_cell(Vector2i(x, y))
	print("cleared the extra block near the bomb powerup at (470,361)")
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
