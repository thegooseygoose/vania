extends SceneTree
## Builds Level3.tscn = "1-3", a LARGER metroidvania that uses ALL power-ups with backtracking.
## Layout is a fold-back LOOP: run RIGHT along the BOTTOM collecting double-jump, ground-pound,
## morph, wall-jump; climb the wall-jump shaft UP; then BACKTRACK LEFT along a HIGH path using
## grapple, boomerang and the gravity-suit, ending at the GOAL back above the start.
## Gate types are all reused from 1-2 (proven passable). Run:
##   Godot --headless --path . -s tools/build_level3.gd

const G := 0     # ground / solid
const B := 1     # brick (ground-poundable)
const LT := 28   # lava top
const LV := 29   # lava body
const WT := 45   # water surface
const WB := 46   # water body
const SW := 16   # door switch tile
const DR := 17   # door tile
const ST := 18   # start tile
const GL := 19   # goal tile
const HK := 47   # paintable hook (grapple anchor)

# vertical layout (rows): TOP floor 5-6, BOTTOM floor 18-19, UNDERGROUND floor 22-23
const TF := 5    # top floor top row (solid 5-6, stand at row 4)
const BF := 18   # bottom floor top row (solid 18-19, stand at row 17)
const UF := 22   # underground floor top row (solid 22-23)

var terrain: TileMapLayer
var enemyt: TileMapLayer
var coint: TileMapLayer
var lvl: Node2D

func t(x, y, a): terrain.set_cell(Vector2i(x, y), 0, Vector2i(a, 0))
func solid(x0, x1, y0, y1, a=G):
	for x in range(x0, x1 + 1):
		for y in range(y0, y1 + 1):
			t(x, y, a)
func erase(x, y): terrain.erase_cell(Vector2i(x, y))
func bfloor(x0, x1): solid(x0, x1, BF, BF + 1, G)
func tfloor(x0, x1): solid(x0, x1, TF, TF + 1, G)
func ufloor(x0, x1): solid(x0, x1, UF, UF + 1, G)
func lava(x0, x1, ytop):
	for x in range(x0, x1 + 1):
		t(x, ytop, LT); t(x, ytop + 1, LV); t(x, ytop + 2, LV)
func water_col(x, y0, y1):
	t(x, y0, WT)                         # surface crest on top
	for y in range(y0 + 1, y1 + 1):
		t(x, y, WB)
func coin(x, y): coint.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
func goomba(x, y): enemyt.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))

func _pow(nm, shape, x, y):
	var p := Area2D.new(); p.name = nm; p.set_script(load("res://powerup.gd"))
	p.set("shape", shape); p.position = Vector2(x * 16 + 8, y * 16 + 8)
	lvl.add_child(p); p.owner = lvl

func _initialize(): call_deferred("_run")
func _run() -> void:
	lvl = Node2D.new(); lvl.name = "Level3"
	terrain = TileMapLayer.new(); terrain.name = "Terrain"; terrain.tile_set = load("res://tiles.tileset.tres"); lvl.add_child(terrain)
	enemyt = TileMapLayer.new(); enemyt.name = "EnemyTiles"; enemyt.tile_set = load("res://enemy_tiles.tileset.tres"); enemyt.visible = false; lvl.add_child(enemyt)
	coint = TileMapLayer.new(); coint.name = "CoinTiles"; coint.tile_set = load("res://coin_tiles.tileset.tres"); coint.visible = false; lvl.add_child(coint)
	var spawns := Node2D.new(); spawns.name = "Spawns"; lvl.add_child(spawns)
	var ps := Marker2D.new(); ps.name = "PlayerStart"; ps.position = Vector2(3 * 16 + 8, BF * 16); spawns.add_child(ps)
	var en := Node2D.new(); en.name = "Enemies"; spawns.add_child(en)
	var co := Node2D.new(); co.name = "Coins"; spawns.add_child(co)

	# ================= BOTTOM PATH (run RIGHT) =================
	# ---- S1 START (x0..14): base movement + DOUBLE JUMP ----
	bfloor(0, 14)
	t(3, BF - 1, ST)                              # start tile
	_pow("PowSquare", "square", 6, BF - 2)        # DOUBLE JUMP on the ground
	coin(9, BF - 2); coin(10, BF - 2)
	solid(14, 14, BF - 5, BF + 1)                 # DJ GATE: a tall pillar (top at row 13) — double-jump over it
	coin(14, BF - 7)                              # hint coin over the pillar

	# ---- S2 (x15..34): GROUND POUND, pound to drop underground ----
	bfloor(15, 34)
	_pow("PowTriangle", "triangle", 18, BF - 2)   # GROUND POUND
	solid(22, 34, BF - 7, BF - 7)                 # low ceiling (can't hop the coming wall)
	solid(25, 28, BF, BF + 1, B)                  # BRICK floor — pound through to drop under
	goomba(31, BF - 1)
	coin(20, BF - 2); coin(23, BF - 5)

	# ---- UNDERGROUND (x18..44): MORPH BALL + squeeze tunnel ----
	ufloor(18, 44)
	solid(18, 24, BF + 2, BF + 2)                 # ceiling of the underground under the brick drop
	solid(18, 18, BF + 2, UF)                     # left wall of underground
	_pow("PowCircle", "circle", 27, UF - 1)       # MORPH BALL
	# MORPH GATE: a 1-tile squeeze. ceiling at UF-2, floor at UF, only row UF-1 open.
	solid(31, 40, BF + 2, UF - 2)                 # thick ceiling block down to UF-2
	coin(34, UF - 1); coin(37, UF - 1)
	# after the squeeze, steps back UP to the bottom floor at x42
	solid(41, 41, UF - 1, UF); solid(42, 42, UF - 3, UF)
	solid(43, 44, UF - 5, UF)

	# ---- S3 (x40..60): WALL JUMP + the climb shaft up to the TOP path ----
	bfloor(40, 60)
	_pow("PowDiamond", "diamond", 46, BF - 2)     # WALL JUMP
	coin(48, BF - 2); coin(50, BF - 2)
	# WALL-JUMP GATE: a shaft between x54 and x58 climbing from bottom (row 18) to top floor (row TF)
	solid(54, 54, TF + 2, BF + 1)                 # left shaft wall
	solid(58, 58, TF, BF + 1)                     # right shaft wall (a touch taller)
	tfloor(54, 72)                                # TOP floor you step onto at the shaft's top (rows 5-6)
	erase(54, TF); erase(54, TF + 1)              # open the shaft mouth into the top floor on the left side
	coin(56, BF - 6); coin(56, TF + 3)

	# ================= TOP PATH (BACKTRACK LEFT) =================
	# ---- S4 (x50..72 top): GRAPPLE, swing the lava gap ----
	_pow("PowStar", "star", 62, TF - 2)           # GRAPPLE (on the top floor, right of the lava)
	coin(64, TF - 2); coin(66, TF - 2)
	# GRAPPLE GATE: a 5-tile lava gap; hook near the RIGHT edge & low enough to grab (within ~85px)
	lava(47, 51, TF)                              # lava fills the top-floor gap (x47..51)
	t(50, TF - 4, HK)                             # hook just above the right side — reachable + swing across
	tfloor(40, 46)                                # landing floor left of the lava

	# ---- S5 (x30..45 top): BOOMERANG + door/switch ----
	_pow("PowBoomerang", "boomerang", 41, TF - 2) # BOOMERANG
	tfloor(28, 45)
	solid(33, 33, TF - 4, TF + 1, DR)             # DOOR blocking the leftward path
	t(30, TF - 2, SW)                             # SWITCH beyond the door — boomerang through to open it
	goomba(43, TF - 1)
	coin(36, TF - 2); coin(38, TF - 2)

	# ---- S6 (x14..28 top): GRAVITY SUIT + the water-ledge-climb finale ----
	tfloor(14, 28)
	_pow("PowWaterwalk", "waterwalk", 22, TF - 2) # GRAVITY SUIT
	coin(18, TF - 2); coin(20, TF - 2)
	# SUIT GATE — a WATER pit with ledges you must DOUBLE-JUMP up. In water, jumps are tiny & you
	# sink UNLESS you wear the suit, which restores full jumping — so the 2-tile ledge hops are
	# only makeable with the suit. Pit x5..13, floor row BF+2, water filling it up to row TF.
	var PB := TF + 9                              # pit bottom
	solid(5, 5, TF - 2, PB)                       # left pit wall
	solid(13, 13, TF, PB)                         # right pit wall
	solid(5, 13, PB, PB)                          # pit floor (you land here after dropping in)
	# drop-in from the top floor: open the right wall high up so you fall into the pit
	erase(13, TF); erase(13, TF + 1)
	for xx in range(6, 13):                       # fill the pit with water FIRST (surface crest at TF)
		water_col(xx, TF, PB - 1)
	# climbing ledges (alternating sides), 2 tiles apart — stamped OVER the water so they're solid
	solid(11, 12, PB - 2, PB - 2)                 # ledge 1 (right)
	solid(6, 7, PB - 4, PB - 4)                   # ledge 2 (left)
	solid(11, 12, PB - 6, PB - 6)                 # ledge 3 (right)
	solid(6, 7, PB - 8, PB - 8)                   # ledge 4 (left) — near the top
	# ---- GOAL: hop off the top ledge onto the left landing, above the start ----
	tfloor(2, 5)                                  # top-left landing above the start
	t(4, TF - 1, GL)                              # GOAL star
	coin(9, TF - 3)

	for n in [terrain, enemyt, coint, spawns, ps, en, co]:
		n.owner = lvl
	var packed := PackedScene.new()
	packed.pack(lvl)
	var err := ResourceSaver.save(packed, "res://Level3.tscn")
	print("saved Level3.tscn err=", err)
	quit()
