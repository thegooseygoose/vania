extends SceneTree
func _initialize(): call_deferred("_run")
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var pw = scn.get_node("Powerups")
	pw.erase_cell(Vector2i(17, 206))
	pw.set_cell(Vector2i(35, 206), 0, Vector2i(48, 0))   # morph tile, now just 5 tiles left of spawn
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("moved morph pickup to (35,206), 5 tiles left of spawn, saved err=%d" % err)
	quit()
