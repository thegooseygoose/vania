extends SceneTree
## Builds Level5.tscn = "1-5": BLANK except a 30-tile-wide floor (rows 13-14) for you to edit.
## Has all the standard layers (Terrain/Markers/Powerups/EnemyTiles/CoinTiles) + a PlayerStart so
## you can paint straight away. Run: Godot --headless --path . -s tools/build_level5.gd

const G := 0     # ground / solid

var terrain: TileMapLayer
var lvl: Node2D

func _initialize(): call_deferred("_run")
func _run() -> void:
	lvl = Node2D.new(); lvl.name = "Level5"
	terrain = TileMapLayer.new(); terrain.name = "Terrain"; terrain.tile_set = load("res://tiles.tileset.tres"); lvl.add_child(terrain)
	var markers := TileMapLayer.new(); markers.name = "Markers"; markers.tile_set = load("res://tiles_markers.tileset.tres"); lvl.add_child(markers)
	var pw := TileMapLayer.new(); pw.name = "Powerups"; pw.tile_set = load("res://tiles_powerups.tileset.tres"); lvl.add_child(pw)
	var enemyt := TileMapLayer.new(); enemyt.name = "EnemyTiles"; enemyt.tile_set = load("res://enemy_tiles.tileset.tres"); enemyt.visible = false; lvl.add_child(enemyt)
	var coint := TileMapLayer.new(); coint.name = "CoinTiles"; coint.tile_set = load("res://coin_tiles.tileset.tres"); coint.visible = false; lvl.add_child(coint)
	var spawns := Node2D.new(); spawns.name = "Spawns"; lvl.add_child(spawns)
	var ps := Marker2D.new(); ps.name = "PlayerStart"; ps.position = Vector2(2 * 16 + 8, 13 * 16); spawns.add_child(ps)
	var en := Node2D.new(); en.name = "Enemies"; spawns.add_child(en)
	var co := Node2D.new(); co.name = "Coins"; spawns.add_child(co)

	# the ONLY content: a 30-tile-wide floor (columns 0..29), rows 13-14 (stand on row 12)
	for x in range(0, 30):
		terrain.set_cell(Vector2i(x, 13), 0, Vector2i(G, 0))
		terrain.set_cell(Vector2i(x, 14), 0, Vector2i(G, 0))

	for n in [terrain, markers, pw, enemyt, coint, spawns, ps, en, co]:
		n.owner = lvl
	var packed := PackedScene.new()
	packed.pack(lvl)
	var err := ResourceSaver.save(packed, "res://Level5.tscn")
	print("saved Level5.tscn err=", err)
	quit()
