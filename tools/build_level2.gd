extends SceneTree
## Builds Level2.tscn = "1-2", a gauntlet that uses ALL six power-ups in order:
## double-jump, ground-pound, wall-jump, morph-ball, grapple, boomerang, then a goal.
## Run: Godot --headless --path . -s tools/build_level2.gd

const G := 0     # ground / solid
const B := 1     # brick (ground-poundable)
const LT := 28   # lava top
const LV := 29   # lava body
const SW := 16   # door switch tile
const DR := 17   # door tile
const ST := 18   # start tile
const GL := 19   # goal tile

var terrain: TileMapLayer
var enemyt: TileMapLayer
var coint: TileMapLayer

func t(x, y, a): terrain.set_cell(Vector2i(x, y), 0, Vector2i(a, 0))
func solid(x0, x1, y0, y1, a=G):
	for x in range(x0, x1 + 1):
		for y in range(y0, y1 + 1):
			t(x, y, a)
func ground(x0, x1): solid(x0, x1, 13, 14, G)         # floor rows
func lava(x0, x1):
	for x in range(x0, x1 + 1):
		t(x, 13, LT); t(x, 14, LV); t(x, 15, LV)
func coin(x, y): coint.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
func goomba(x, y): enemyt.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
func koopa(x, y): enemyt.set_cell(Vector2i(x, y), 0, Vector2i(1, 0))

var lvl: Node2D
func _pow(name, shape, x, y):
	var p := Area2D.new()
	p.name = name
	p.set_script(load("res://powerup.gd"))
	p.set("shape", shape)
	p.position = Vector2(x * 16 + 8, y * 16 + 8)
	lvl.add_child(p); p.owner = lvl
func _grab(x, y):
	var g := Node2D.new()
	g.name = "GrabPoint"
	g.set_script(load("res://grabpoint.gd"))
	g.position = Vector2(x * 16 + 8, y * 16 + 8)
	lvl.add_child(g); g.owner = lvl

func _initialize(): call_deferred("_run")
func _run() -> void:
	lvl = Node2D.new(); lvl.name = "Level2"
	terrain = TileMapLayer.new(); terrain.name = "Terrain"; terrain.tile_set = load("res://tiles.tileset.tres"); lvl.add_child(terrain)
	enemyt = TileMapLayer.new(); enemyt.name = "EnemyTiles"; enemyt.tile_set = load("res://enemy_tiles.tileset.tres"); enemyt.visible = false; lvl.add_child(enemyt)
	coint = TileMapLayer.new(); coint.name = "CoinTiles"; coint.tile_set = load("res://coin_tiles.tileset.tres"); coint.visible = false; lvl.add_child(coint)
	var spawns := Node2D.new(); spawns.name = "Spawns"; lvl.add_child(spawns)
	var ps := Marker2D.new(); ps.name = "PlayerStart"; ps.position = Vector2(2 * 16 + 8, 13 * 16); spawns.add_child(ps)
	var en := Node2D.new(); en.name = "Enemies"; spawns.add_child(en)
	var co := Node2D.new(); co.name = "Coins"; spawns.add_child(co)

	# ===== SECTION 1: START (x0..15) =====
	ground(0, 15)
	t(2, 12, ST)                              # start tile
	coin(6, 11); coin(8, 11); coin(10, 11)
	# goomba(12, 12)

	# ===== SECTION 2: DOUBLE JUMP (x15..28) — hop over a tall pillar =====
	ground(15, 28)
	_pow("PowSquare", "square", 17, 11)
	solid(23, 23, 7, 12)                      # 1-wide pillar, top at row 7 → needs a double jump
	coin(23, 5)                               # a coin over the top as a hint
	# goomba(26, 12)

	# ===== SECTION 3: GROUND POUND (x28..42) — pound the brick floor, tunnel under a wall =====
	ground(28, 33)
	_pow("PowTriangle", "triangle", 30, 11)
	solid(30, 38, 6, 6)                       # low ceiling so you can't just jump the wall
	solid(34, 37, 13, 14, B)                  # BRICK floor — pound through it
	solid(15, 42, 17, 17)                     # bedrock under the tunnel
	solid(38, 38, 6, 14)                      # the wall you must go UNDER (rows 15-16 stay open)
	terrain.erase_cell(Vector2i(38, 15)); terrain.erase_cell(Vector2i(38, 16))
	ground(39, 50)                            # surface resumes past the wall
	coin(35, 15); coin(36, 15)

	# ===== SECTION 4: WALL JUMP (x42..54) — climb the shaft =====
	ground(39, 49)
	_pow("PowDiamond", "diamond", 43, 12)
	solid(49, 49, 0, 12)                      # left wall
	solid(53, 53, 5, 12)                      # right wall (open at the top, rows 0..4)
	solid(53, 68, 4, 4)                       # top exit floor (row 4) → you stand at row 3
	coin(51, 8); coin(51, 4)

	# ===== SECTION 5: MORPH BALL (x54..68) — squeeze the 1-tile tunnel =====
	_pow("PowCircle", "circle", 55, 3)
	solid(53, 60, 1, 1)                       # approach: 2-tile-tall headroom (rows 2..3)
	solid(61, 67, 0, 2)                       # squeeze: ceiling down to row 2 → only row 3 is open
	coin(63, 3); coin(65, 3)
	# drop off the row-4 ledge at x68 back to the ground
	solid(68, 76, 12, 14)                     # a ledge/steps down to ground level

	# ===== SECTION 6: GRAPPLE (x68..86) — swing the lava gap =====
	ground(68, 76)
	_pow("PowStar", "star", 70, 11)
	lava(77, 85)                              # wide lava gap
	_grab(81, 5)                              # grab point over the middle
	ground(86, 104)

	# ===== SECTION 7: BOOMERANG + DOOR (x86..104) =====
	_pow("PowBoomerang", "boomerang", 88, 12)
	solid(97, 97, 9, 12, DR)                  # DOOR blocking the path
	t(102, 12, SW)                            # SWITCH beyond the door — throw the boomerang through it
	# goomba(92, 12)
	coin(99, 12); coin(100, 12)

	# ===== SECTION 8: GOAL (x104..112) =====
	ground(104, 112)
	t(108, 11, GL)                            # goal star
	coin(106, 12)

	for n in [terrain, enemyt, coint, spawns, ps, en, co]:
		n.owner = lvl
	var packed := PackedScene.new()
	packed.pack(lvl)
	var err := ResourceSaver.save(packed, "res://Level2.tscn")
	print("saved Level2.tscn err=", err, "  width~126 tiles")
	quit()
