extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn=load("res://Level28.tscn").instantiate()
	var spawns=scn.get_node_or_null("Spawns")
	if spawns==null:
		spawns=Node2D.new(); spawns.name="Spawns"; scn.add_child(spawns)
	var ps=spawns.get_node_or_null("PlayerStart")
	if ps==null:
		ps=Marker2D.new(); ps.name="PlayerStart"; spawns.add_child(ps)
		print("added PlayerStart node")
	else:
		print("PlayerStart already exists")
	# find a good standable floor cell (open 2 above, solid) near the left, not the very edge
	var terr=scn.get_node("Terrain")
	var best=Vector2i(-1,-1)
	for c in terr.get_used_cells():
		if c.x<2: continue
		if terr.get_cell_source_id(Vector2i(c.x,c.y-1))<0 and terr.get_cell_source_id(Vector2i(c.x,c.y-2))<0:
			best=c; break
	if best.x<0: best=Vector2i(2,13)
	ps.position=Vector2(best.x*16+8, best.y*16)   # feet on top of the floor cell
	# ensure required child nodes exist so _read_spawns is happy
	for nm in ["Enemies","Coins"]:
		if spawns.get_node_or_null(nm)==null:
			var n=Node2D.new(); n.name=nm; spawns.add_child(n)
	# reown everything to the scene root so pack keeps it
	var stack=[scn]
	while stack.size()>0:
		var nd=stack.pop_back()
		for ch in nd.get_children():
			ch.owner=scn; stack.append(ch)
	var packed=PackedScene.new(); packed.pack(scn)
	var err=ResourceSaver.save(packed,"res://Level28.tscn")
	print("PlayerStart at tile %s px %s, saved err=%d"%[str(best),str(ps.position),err])
	quit()
