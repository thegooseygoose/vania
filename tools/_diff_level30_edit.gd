extends SceneTree
## Compares the committed HEAD version of Level30.tscn (copied to Level30_HEAD_tmp.tscn) against
## the user's just-saved working copy, per-layer, cell by cell -- so we can describe exactly what
## they changed before committing it.

func _initialize(): call_deferred("_run")
func _run() -> void:
	var old = load("res://Level30_HEAD_tmp.tscn").instantiate()
	var new_ = load("res://Level30.tscn").instantiate()

	for lname in ["Terrain", "Markers", "Powerups", "EnemyTiles", "CoinTiles"]:
		var lo = old.get_node_or_null(lname)
		var ln = new_.get_node_or_null(lname)
		if lo == null or ln == null:
			continue
		var oc := {}
		for c in lo.get_used_cells():
			oc[c] = lo.get_cell_atlas_coords(c).x
		var nc := {}
		for c in ln.get_used_cells():
			nc[c] = ln.get_cell_atlas_coords(c).x
		var added := []
		var removed := []
		var changed := []
		for c in nc:
			if not oc.has(c):
				added.append([c, nc[c]])
			elif oc[c] != nc[c]:
				changed.append([c, oc[c], nc[c]])
		for c in oc:
			if not nc.has(c):
				removed.append([c, oc[c]])
		if added.size() > 0 or removed.size() > 0 or changed.size() > 0:
			print("--- %s ---" % lname)
			if added.size() > 0: print("  added: %s" % str(added))
			if removed.size() > 0: print("  removed: %s" % str(removed))
			if changed.size() > 0: print("  changed atlas: %s" % str(changed))

	# also list top-level node differences (added/removed scene nodes, not tiles)
	var old_names := {}
	for c in old.get_children():
		old_names[c.name] = c
	var new_names := {}
	for c in new_.get_children():
		new_names[c.name] = c
	for n in new_names:
		if not old_names.has(n):
			print("NODE ADDED: %s (%s) at %s" % [n, new_names[n].get_class(), str(new_names[n].get("position"))])
	for n in old_names:
		if not new_names.has(n):
			print("NODE REMOVED: %s (%s)" % [n, old_names[n].get_class()])
	quit()
