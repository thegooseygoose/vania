extends SceneTree
## Undoes a build_zigzag call by erasing just the rung (block) cells it SET, leaving
## any headroom cells it opened alone (making things more open is never a regression).
## Usage: -s tools/_undo_zigzag.gd -- laneA0 laneA1 laneB0 laneB1 y_top y_bot
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
	var scn = load("res://Level29.tscn").instantiate()
	var terr: TileMapLayer = scn.get_node("Terrain")
	var rows: Array = []
	var y := Y_BOT
	while y >= Y_TOP:
		rows.append(y)
		y -= 3
	for i in range(rows.size()):
		var r: int = rows[i]
		var x0: int = A0 if i % 2 == 0 else B0
		var x1: int = A1 if i % 2 == 0 else B1
		for x in range(x0, x1 + 1):
			terr.erase_cell(Vector2i(x, r))
	print("undone %d rungs, y%d..%d" % [rows.size(), Y_TOP, Y_BOT])
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
