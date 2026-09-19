extends SceneTree
func _initialize(): call_deferred("_run")
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var atlas := Vector2i(71, 0)
	# The door at (282,299) is floating over a 9-tile-deep pit (real floor at row308) --
	# it has no footing at all. Both neighbouring platforms (x274-278 / x289-297) are
	# solid at row300 right where the door needs to rest. Fill just that one row across
	# the gap so the door has proper ground under it, without touching row298-299
	# (the door's own graphic/walk space, which must stay open).
	for x in range(279, 289):
		terr.set_cell(Vector2i(x, 300), 0, atlas)
	print("filled floor row300, x279-288, under door (282,299)")
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
