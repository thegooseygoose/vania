extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var pw = scn.get_node("Powerups")
	pw.erase_cell(Vector2i(40, 206))
	pw.set_cell(Vector2i(17, 206), 0, Vector2i(48, 0))   # morph tile, moved off the spawn cell
	var packed := PackedScene.new()
	for c in scn.get_children(): c.owner = scn
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("moved morph pickup off spawn tile, saved err=%d" % err)
	quit()
