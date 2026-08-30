extends SceneTree
## Level9.tscn = "1-9" (menu "LEVEL F"): OVERCLOCK / time-slow showcase. Grab the power-up, then hit
## T / L3 to slow the world and calmly weave through enemy swarms + hop enemy-topped platforms over a pit.
## Run: Godot --headless --path . -s tools/build_level9.gd

const G := 0
const ST := 18
const GL := 19

var terrain: TileMapLayer
var markers: TileMapLayer
var powerups: TileMapLayer
var enemyt: TileMapLayer
var coint: TileMapLayer
var lvl: Node2D

func t(x, y, a): terrain.set_cell(Vector2i(x, y), 0, Vector2i(a, 0))
func mk(x, y, a): markers.set_cell(Vector2i(x, y), 0, Vector2i(a, 0))
func pw(x, y, a): powerups.set_cell(Vector2i(x, y), 0, Vector2i(a, 0))
func solid(x0, x1, y0, y1, a=G):
	for x in range(x0, x1 + 1):
		for y in range(y0, y1 + 1):
			t(x, y, a)
func ground(x0, x1): solid(x0, x1, 13, 14, G)
func coin(x, y): coint.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
func goomba(x, y): enemyt.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
func _save(nm, x, y):
	var s := Area2D.new(); s.name = nm; s.set_script(load("res://savestation.gd"))
	s.position = Vector2(x * 16 + 8, y * 16 + 8); lvl.add_child(s); s.owner = lvl

func _initialize(): call_deferred("_run")
func _run() -> void:
	lvl = Node2D.new(); lvl.name = "Level9"
	terrain = TileMapLayer.new(); terrain.name = "Terrain"; terrain.tile_set = load("res://tiles.tileset.tres"); lvl.add_child(terrain)
	markers = TileMapLayer.new(); markers.name = "Markers"; markers.tile_set = load("res://tiles_markers.tileset.tres"); lvl.add_child(markers)
	powerups = TileMapLayer.new(); powerups.name = "Powerups"; powerups.tile_set = load("res://tiles_powerups.tileset.tres"); lvl.add_child(powerups)
	enemyt = TileMapLayer.new(); enemyt.name = "EnemyTiles"; enemyt.tile_set = load("res://enemy_tiles.tileset.tres"); enemyt.visible = false; lvl.add_child(enemyt)
	coint = TileMapLayer.new(); coint.name = "CoinTiles"; coint.tile_set = load("res://coin_tiles.tileset.tres"); coint.visible = false; lvl.add_child(coint)
	var spawns := Node2D.new(); spawns.name = "Spawns"; lvl.add_child(spawns)
	var ps := Marker2D.new(); ps.name = "PlayerStart"; ps.position = Vector2(2 * 16 + 8, 13 * 16); spawns.add_child(ps)
	var en := Node2D.new(); en.name = "Enemies"; spawns.add_child(en)
	var co := Node2D.new(); co.name = "Coins"; spawns.add_child(co)

	# ===== S1 START + OVERCLOCK power-up + save =====
	ground(0, 20)
	mk(2, 12, ST)
	_save("Save1", 6, 12)
	pw(9, 11, 57)                         # OVERCLOCK (time-slow) tile
	coin(11, 11); coin(12, 11)

	# ===== S2 ENEMY SWARM CORRIDOR — slow time and stroll through =====
	ground(20, 40)
	for gx in [22, 24, 26, 28, 30, 32, 34, 36, 38]:
		goomba(gx, 12)                    # a packed line of goombas; slow them to weave through
	solid(20, 40, 8, 8)                   # a low ceiling so you can't just jump over the swarm
	coin(29, 10)

	# ===== S3 ENEMY-TOPPED PLATFORMS over a PIT — slow time to nail the hops =====
	# small platforms (no floor between) each patrolled by a goomba; time-slow makes the timing trivial
	ground(40, 44)
	_save("Save2", 42, 12)
	solid(48, 50, 11, 11); goomba(49, 10)
	solid(54, 56, 11, 11); goomba(55, 10)
	solid(60, 62, 11, 11); goomba(61, 10)
	ground(66, 78)                        # safe landing floor past the pit
	coin(52, 8); coin(58, 8)

	# ===== S4 GOAL =====
	mk(75, 12, GL)
	coin(72, 11); coin(73, 11)

	for n in [terrain, markers, powerups, enemyt, coint, spawns, ps, en, co]:
		n.owner = lvl
	var packed := PackedScene.new()
	packed.pack(lvl)
	print("saved Level9.tscn err=", ResourceSaver.save(packed, "res://Level9.tscn"))
	quit()
