extends SceneTree
# Move special tiles off Terrain onto their own layers:
#   Markers  = door-switch(16), door(17), start(18), goal(19)
#   Powerups = power-up icons(48..54)
# Migrates existing painted cells in each level scene and adds the two TileMapLayers.

const MARKERS := [16, 17, 18, 19]
const POWERUPS := [48, 49, 50, 51, 52, 53, 54]
const LEVELS := ["res://Level1.tscn", "res://Level2.tscn", "res://Level3.tscn"]

func _init() -> void:
	for path in LEVELS:
		_do(path)
	quit()

func _do(path: String) -> void:
	var packed: PackedScene = load(path)
	var root: Node = packed.instantiate()
	var terrain: TileMapLayer = root.get_node("Terrain")
	var ts := terrain.tile_set

	# reuse existing layers if a previous run already added them, else create
	var markers: TileMapLayer = root.get_node_or_null("Markers")
	if markers == null:
		markers = TileMapLayer.new(); markers.name = "Markers"; markers.tile_set = ts
		root.add_child(markers); markers.owner = root
	var powerups: TileMapLayer = root.get_node_or_null("Powerups")
	if powerups == null:
		powerups = TileMapLayer.new(); powerups.name = "Powerups"; powerups.tile_set = ts
		root.add_child(powerups); powerups.owner = root

	var mv := 0
	var pv := 0
	for cell in terrain.get_used_cells():
		var sid: int = terrain.get_cell_source_id(cell)
		var ax: int = terrain.get_cell_atlas_coords(cell).x
		if ax in MARKERS:
			markers.set_cell(cell, sid, Vector2i(ax, 0))
			terrain.erase_cell(cell); mv += 1
		elif ax in POWERUPS:
			powerups.set_cell(cell, sid, Vector2i(ax, 0))
			terrain.erase_cell(cell); pv += 1

	var out := PackedScene.new()
	out.pack(root)
	ResourceSaver.save(out, path)
	print("%s: moved %d marker + %d powerup cells" % [path, mv, pv])
