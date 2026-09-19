extends SceneTree
func _initialize(): call_deferred("_run")
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var et = scn.get_node("EnemyTiles")
	# malformed double-door at y=201: L(78) M(79) L(80) M(81) R(82) — the orphaned L(78)/M(79)
	# have no matching R (a second door's L bled onto the first door's R). Remove the orphan half,
	# keep the one complete, correctly-ordered door (80=L, 81=M, 82=R).
	et.erase_cell(Vector2i(78, 201))
	et.erase_cell(Vector2i(79, 201))
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("removed orphaned door-half remnant, saved err=%d" % err)
	quit()
