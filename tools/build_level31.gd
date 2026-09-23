extends SceneTree
## Builds Level31.tscn = "WALL JUMP" test level (EXTRAS menu). You start with NO wall jump:
##  1) a tall wall to test the default slow wall SLIDE (can't kick off it yet),
##  2) a wall-jump power-up (Powerups atlas 53) on the floor,
##  3) a Super-Meat-Boy shaft (two walls, 5 tiles apart) to kick up, and a goal at the top.
const G := 0
func _initialize(): call_deferred("_run")
func _run() -> void:
	var lvl := Node2D.new(); lvl.name = "LevelWallJump"
	var terrain := TileMapLayer.new(); terrain.name = "Terrain"; terrain.tile_set = load("res://tiles.tileset.tres"); lvl.add_child(terrain)
	var markers := TileMapLayer.new(); markers.name = "Markers"; markers.tile_set = load("res://tiles_markers.tileset.tres"); lvl.add_child(markers)
	var pw := TileMapLayer.new(); pw.name = "Powerups"; pw.tile_set = load("res://tiles_powerups.tileset.tres"); lvl.add_child(pw)
	var enemyt := TileMapLayer.new(); enemyt.name = "EnemyTiles"; enemyt.tile_set = load("res://enemy_tiles.tileset.tres"); enemyt.visible = false; lvl.add_child(enemyt)
	var coint := TileMapLayer.new(); coint.name = "CoinTiles"; coint.tile_set = load("res://coin_tiles.tileset.tres"); coint.visible = false; lvl.add_child(coint)
	var spawns := Node2D.new(); spawns.name = "Spawns"; lvl.add_child(spawns)
	var ps := Marker2D.new(); ps.name = "PlayerStart"; ps.position = Vector2(3 * 16 + 8, 13 * 16); spawns.add_child(ps)
	var en := Node2D.new(); en.name = "Enemies"; spawns.add_child(en)
	var co := Node2D.new(); co.name = "Coins"; spawns.add_child(co)
	# floor (rows 13-14), x 0..54
	for x in range(0, 55):
		terrain.set_cell(Vector2i(x, 13), 0, Vector2i(G, 0))
		terrain.set_cell(Vector2i(x, 14), 0, Vector2i(G, 0))
	# 1) SLIDE-TEST WALL: x 14-15, rows 2..12
	for y in range(2, 13):
		for x in [14, 15]:
			terrain.set_cell(Vector2i(x, y), 0, Vector2i(G, 0))
	# 2) wall-jump power-up sitting on the floor
	pw.set_cell(Vector2i(24, 12), 0, Vector2i(53, 0))
	# 3) SHAFT: left wall x 30-31, right wall x 37-38 (gap x 32..36 = 5 tiles), rows 4..12
	for y in range(4, 13):
		for x in [30, 31, 37, 38]:
			terrain.set_cell(Vector2i(x, y), 0, Vector2i(G, 0))
	# goal ledge at the top, right of the shaft: rows 4-5, x 37..52
	for x in range(37, 53):
		terrain.set_cell(Vector2i(x, 4), 0, Vector2i(G, 0))
		terrain.set_cell(Vector2i(x, 5), 0, Vector2i(G, 0))
	markers.set_cell(Vector2i(48, 3), 0, Vector2i(19, 0))
	for n in [terrain, markers, pw, enemyt, coint, spawns, ps, en, co]:
		n.owner = lvl
	var packed := PackedScene.new(); packed.pack(lvl)
	print("saved Level31.tscn err=", ResourceSaver.save(packed, "res://Level31.tscn"))
	quit()
