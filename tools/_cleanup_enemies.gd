extends SceneTree
const W := 480; const H := 450
func idx(x:int,y:int)->int: return y*W+x
func _initialize(): call_deferred("_run")
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var et = scn.get_node("EnemyTiles")
	var solid = PackedByteArray(); solid.resize(W*H)
	for c in terr.get_used_cells():
		var ax: int = terr.get_cell_atlas_coords(c).x
		if c.x>=0 and c.x<W and c.y>=0 and c.y<H and (ax<45 or ax>=67): solid[idx(c.x,c.y)]=1
	var enemy_cells := []
	for c in et.get_used_cells():
		var ax: int = et.get_cell_atlas_coords(c).x
		if ax in [24,25,29,31,35]:
			enemy_cells.append(c)
	var removed := 0
	# 1) remove any enemy embedded in solid terrain
	for c in enemy_cells:
		if solid[idx(c.x,c.y)] == 1:
			et.erase_cell(c)
			removed += 1
	# 2) declutter: for any two remaining enemies within 5 tiles, drop the second
	var remaining := []
	for c in enemy_cells:
		if solid[idx(c.x,c.y)] == 0:
			remaining.append(c)
	var dropped := {}
	for i in range(remaining.size()):
		if dropped.has(i): continue
		for j in range(i+1, remaining.size()):
			if dropped.has(j): continue
			if remaining[i].distance_to(remaining[j]) < 5:
				et.erase_cell(remaining[j])
				dropped[j] = true
				removed += 1
	print("removed %d problem enemies (embedded-in-wall + declutter)" % removed)
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
