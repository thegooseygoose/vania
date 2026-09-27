extends SceneTree
## Builds Level32.tscn = "POWER MIX" (EXTRAS menu): a course that needs DOUBLE JUMP, WALL JUMP and DASH.
## All three pickups sit in the opening room.
##  A) x0-30 floor + the 3 pickups + a save block
##  B) two 7-tile pits (single jump can't cross; double jump can), the 2nd landing is 2 tiles higher
##  C) a 5-wide wall-jump shaft (walk in under the left wall, kick up to the ledge)
##  D) a ledge with a tall breakable wall (a DASH smashes a full body-height doorway through it) -> goal
const G := 0
const BRK := 68   # breakable block atlas
func _initialize(): call_deferred("_run")
func _run() -> void:
	var lvl := Node2D.new(); lvl.name = "LevelPowerMix"
	var terrain := TileMapLayer.new(); terrain.name = "Terrain"; terrain.tile_set = load("res://tiles.tileset.tres"); lvl.add_child(terrain)
	var markers := TileMapLayer.new(); markers.name = "Markers"; markers.tile_set = load("res://tiles_markers.tileset.tres"); lvl.add_child(markers)
	var pw := TileMapLayer.new(); pw.name = "Powerups"; pw.tile_set = load("res://tiles_powerups.tileset.tres"); lvl.add_child(pw)
	var enemyt := TileMapLayer.new(); enemyt.name = "EnemyTiles"; enemyt.tile_set = load("res://enemy_tiles.tileset.tres"); enemyt.visible = false; lvl.add_child(enemyt)
	var coint := TileMapLayer.new(); coint.name = "CoinTiles"; coint.tile_set = load("res://coin_tiles.tileset.tres"); coint.visible = false; lvl.add_child(coint)
	var spawns := Node2D.new(); spawns.name = "Spawns"; lvl.add_child(spawns)
	var ps := Marker2D.new(); ps.name = "PlayerStart"; ps.position = Vector2(3 * 16 + 8, 13 * 16); spawns.add_child(ps)
	var en := Node2D.new(); en.name = "Enemies"; spawns.add_child(en)
	var co := Node2D.new(); co.name = "Coins"; spawns.add_child(co)
	var t := func(x: int, y: int, atlas: int = G): terrain.set_cell(Vector2i(x, y), 0, Vector2i(atlas, 0))
	# A) opening floor x0..30
	for x in range(0, 31):
		t.call(x, 13); t.call(x, 14)
	pw.set_cell(Vector2i(7, 12), 0, Vector2i(49, 0))    # double jump
	pw.set_cell(Vector2i(10, 12), 0, Vector2i(53, 0))   # wall jump
	pw.set_cell(Vector2i(13, 12), 0, Vector2i(55, 0))   # dash
	pw.set_cell(Vector2i(27, 12), 0, Vector2i(85, 0))   # save block (spawns a SaveStation)
	# B) pit 1 = x31..37 (floor missing), floor x38..49, pit 2 = x50..56, raised landing rows 11-14 x57..80
	for x in range(38, 50):
		t.call(x, 13); t.call(x, 14)
	for x in range(57, 81):
		for y in range(11, 15):
			t.call(x, y)
	# C) shaft: left wall x68-69 rows 3..8 (rows 9-10 open so you can walk in), right wall x75-76 rows 3..10
	for y in range(3, 9):
		for x in [68, 69]:
			t.call(x, y)
	for y in range(3, 11):
		for x in [75, 76]:
			t.call(x, y)
	# D) ledge rows 3-4 from x75 to x104 (stand on row 2)
	for x in range(75, 105):
		t.call(x, 3); t.call(x, 4)
	# tall breakable wall at x90, rows -5..2 (8 tall: can't be jumped; a dash smashes a 2-tile doorway)
	for y in range(-5, 3):
		for x in [90]:
			t.call(x, y, BRK)
	markers.set_cell(Vector2i(100, 2), 0, Vector2i(19, 0))
	for n in [terrain, markers, pw, enemyt, coint, spawns, ps, en, co]:
		n.owner = lvl
	var packed := PackedScene.new(); packed.pack(lvl)
	print("saved Level32.tscn err=", ResourceSaver.save(packed, "res://Level32.tscn"))
	quit()
