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
	for x in range(162, 166):
		terr.erase_cell(Vector2i(x, 163))
	# smaller horizontal shift this time (164-167, only ~1 column overlap with the
	# departure ledge at 167-171's left edge) -- the 6-tile shift tried before was
	# simply too far for this engine's slow air-control speed within one jump's
	# airtime, regardless of which row it was placed on.
	for x in range(164, 168):
		terr.set_cell(Vector2i(x, 164), 0, atlas)
	print("placed intermediate at row164, x164-167 (smaller shift from departure)")
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
