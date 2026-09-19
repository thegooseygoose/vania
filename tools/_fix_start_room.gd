extends SceneTree
## The last west-cluster widening pass (_build_stairs5.gd, clear_rect down to x=16) accidentally
## wiped the player-start room's own floor (and the BLOKZ pillar placed there earlier) since it
## overlapped x=16-79/y=195-207. Rebuilds a proper floor under the start + re-places the BLOKZ tiles.
const WALL := 13
const NORMAL := 67
const BREAKABLE := 68
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	# solid floor under the whole start room span (matches the original 3-row-thick floor pattern)
	for x in range(16, 60):
		for y in range(207, 210):
			terr.set_cell(Vector2i(x, y), 0, Vector2i(WALL, 0))
	# re-place the BLOKZ pillar next to spawn (40,206) exactly as before
	for y in range(200, 205):
		terr.set_cell(Vector2i(28, y), 0, Vector2i(NORMAL, 0))
	terr.set_cell(Vector2i(29, 205), 0, Vector2i(BREAKABLE, 0))
	terr.set_cell(Vector2i(30, 205), 0, Vector2i(BREAKABLE, 0))
	_reown(scn, scn)
	var packed := PackedScene.new(); packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("rebuilt start-room floor + BLOKZ pillar, saved err=%d" % err)
	quit()
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
