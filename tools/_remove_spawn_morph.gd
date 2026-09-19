extends SceneTree
func _initialize(): call_deferred("_run")
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var pw = scn.get_node("Powerups")
	# duplicate morph-ball pickup (atlas 48) sitting exactly on the player spawn
	# cell (40,206) -> auto-collected instantly. The user's own hand-placed one at
	# (24,206) stays untouched.
	var target := Vector2i(40, 206)
	if pw.get_cell_source_id(target) != -1 and pw.get_cell_atlas_coords(target).x == 48:
		pw.erase_cell(target)
		print("erased duplicate morph tile at (40,206)")
	else:
		print("NOTHING erased -- tile at (40,206) was not atlas 48, check manually: ",
			pw.get_cell_source_id(target), " atlas=", pw.get_cell_atlas_coords(target))
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
