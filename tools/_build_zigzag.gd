extends SceneTree
## Reusable adaptive zigzag ladder builder. Places two alternating lanes of solid rungs,
## every 3 rows, from Y_BOT up to Y_TOP. SAFE by construction: only ever touches cells
## within the rung row itself (set) or the 3 headroom rows directly above each specific
## rung (erase, and ONLY if currently solid) -- never a clear_rect over the full bounding
## box, so any real terrain between/around the lanes is left untouched.
## Usage: -s tools/_build_zigzag.gd -- laneA0 laneA1 laneB0 laneB1 y_top y_bot atlas
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
func _initialize(): call_deferred("_run")
func _run():
	var args := OS.get_cmdline_user_args()
	var A0:int=int(args[0]); var A1:int=int(args[1])
	var B0:int=int(args[2]); var B1:int=int(args[3])
	var Y_TOP:int=int(args[4]); var Y_BOT:int=int(args[5])
	var atlas_x:int = int(args[6]) if args.size() > 6 else 76

	var scn = load("res://Level29.tscn").instantiate()
	var terr: TileMapLayer = scn.get_node("Terrain")
	var atlas := Vector2i(atlas_x, 0)

	var rows: Array = []
	var y := Y_BOT
	while y >= Y_TOP:
		rows.append(y)
		y -= 3

	var erased := 0
	for i in range(rows.size()):
		var r: int = rows[i]
		var x0: int = A0 if i % 2 == 0 else B0
		var x1: int = A1 if i % 2 == 0 else B1
		for x in range(x0, x1 + 1):
			terr.set_cell(Vector2i(x, r), 0, atlas)
			for hy in [r - 1, r - 2, r - 3]:
				if terr.get_cell_source_id(Vector2i(x, hy)) >= 0:
					terr.erase_cell(Vector2i(x, hy))
					erased += 1
	print("built %d rungs, y%d..%d, erased %d blocking headroom cells" % [rows.size(), Y_TOP, Y_BOT, erased])

	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
