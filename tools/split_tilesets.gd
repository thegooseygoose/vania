extends SceneTree
# Give each layer its OWN tileset so the editor palette is separate:
#   Terrain  keeps its tileset but WITHOUT the marker/power-up tiles
#   Markers  -> tiles_markers.tileset.tres   (only 16,17,18,19; door 17 solid)
#   Powerups -> tiles_powerups.tileset.tres  (only 48..54)

const TEX := "res://tiles.png"
const MARKERS := [16, 17, 18, 19]
const POWERUPS := [48, 49, 50, 51, 52, 53, 54]
const SOLID := [16, 17, 18]           # door + markers that carry collision (16/18 erased at load)
var SQUARE := PackedVector2Array([Vector2(-8, -8), Vector2(8, -8), Vector2(8, 8), Vector2(-8, 8)])
const LEVELS := ["res://Level1.tscn", "res://Level2.tscn", "res://Level3.tscn"]

func _init() -> void:
	_build("res://tiles_markers.tileset.tres", MARKERS, SOLID)
	_build("res://tiles_powerups.tileset.tres", POWERUPS, [])
	# strip the specials out of the SHARED terrain tileset (used by Level2/3 Terrain)
	_strip(load("res://tiles.tileset.tres"))
	ResourceSaver.save(load("res://tiles.tileset.tres"), "res://tiles.tileset.tres")
	for path in LEVELS:
		_apply(path)
	quit()

func _build(path: String, cols: Array, solid: Array) -> void:
	var ts := TileSet.new()
	var src := TileSetAtlasSource.new()
	src.texture = load(TEX)
	src.texture_region_size = Vector2i(16, 16)
	for c in cols:
		src.create_tile(Vector2i(c, 0))
	ts.add_source(src, 0)
	if solid.size() > 0:
		ts.add_physics_layer(-1)
		ts.set_physics_layer_collision_layer(0, 1)
		for c in solid:
			var td := src.get_tile_data(Vector2i(c, 0), 0)
			td.set_collision_polygons_count(0, 1)
			td.set_collision_polygon_points(0, 0, SQUARE)
	ResourceSaver.save(ts, path)
	print("built %s (%d tiles)" % [path, cols.size()])

func _strip(ts: TileSet) -> void:
	var src := ts.get_source(0) as TileSetAtlasSource
	for c in MARKERS + POWERUPS:
		if src.has_tile(Vector2i(c, 0)):
			src.remove_tile(Vector2i(c, 0))

func _apply(path: String) -> void:
	var packed: PackedScene = load(path)
	var root: Node = packed.instantiate()
	var terrain: TileMapLayer = root.get_node("Terrain")
	# Level1 Terrain uses an EMBEDDED tileset — strip specials from it too
	_strip(terrain.tile_set)
	var m: TileMapLayer = root.get_node_or_null("Markers")
	var p: TileMapLayer = root.get_node_or_null("Powerups")
	if m: m.tile_set = load("res://tiles_markers.tileset.tres")
	if p: p.tile_set = load("res://tiles_powerups.tileset.tres")
	var out := PackedScene.new()
	out.pack(root)
	ResourceSaver.save(out, path)
	print("%s: terrain tiles=%d, markers set=%s, powerups set=%s"
		% [path, (terrain.tile_set.get_source(0) as TileSetAtlasSource).get_tiles_count(),
			m != null, p != null])
