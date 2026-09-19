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
	var cellmap := {}
	for c in et.get_used_cells():
		var ax: int = et.get_cell_atlas_coords(c).x
		if ax>=26 and ax<=28: cellmap[c] = ax
	var doorL := []
	for c in cellmap.keys():
		if cellmap[c] == 26: doorL.append(c)
	var fixed := 0
	for L in doorL:
		for dx in range(-2, 6):
			var x: int = L.x + dx
			var y: int = L.y
			if x<0 or x>=W or y<1 or y>=H: continue
			var open_here: bool = solid[idx(x,y)]==0
			var open_above: bool = solid[idx(x,y-1)]==0
			if open_here and not open_above:
				terr.erase_cell(Vector2i(x, y-1))
				fixed += 1
	print("cleared %d headroom tiles across all tight-spot doors" % fixed)
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
