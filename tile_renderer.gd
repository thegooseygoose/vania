extends Node2D
class_name TileRenderer
## Draws the non-tile visuals in world space (the terrain itself is now a
## TileMapLayer in Level1.tscn). Two instances are used:
##   mode "bg" — parallax clouds + hills, behind the terrain
##   mode "fg" — flag, castle detail, coins and particles, in front of it

var main                       # untyped to avoid a cyclic class dependency
var font: Font
var mode := "bg"

const TILE := 16

const C_Q := Color("fcac00")
const C_QDARK := Color("e08000")
const C_BRICK := Color("c84c0c")
const C_CASTLE := Color("c84c0c")
const C_FLAG := Color("3cbc3c")
const C_POLE := Color("e0e0e0")


var tiles_tex: Texture2D
var castle_tex: Texture2D
var endpipe_tex: Texture2D
var pipeover_tex: Texture2D
var coins_tex: Texture2D
var coinpop_tex: Texture2D
var flag_ball_tex: Texture2D
var flag_flag_tex: Texture2D
var flag_base_tex: Texture2D
var sign_tex: Array = []                 # [sign1, sign2] — 2-frame blinking background sign
const SIGN_SRC := Rect2(7, 19, 82, 76)   # trimmed content region within the 100x100 sign PNGs

func _ready() -> void:
	font = ThemeDB.fallback_font
	tiles_tex = load("res://tiles.png")
	castle_tex = load("res://sprites/castle.png")
	endpipe_tex = load("res://sprites/new player/end pipe.png")
	# trim the transparent padding around the pipe so its foot anchors to the tile
	# regardless of how the source canvas is sized/positioned
	var po_img: Image = load("res://sprites/new player/pipe over.png").get_image()
	po_img.convert(Image.FORMAT_RGBA8)
	var used: Rect2i = po_img.get_used_rect()
	pipeover_tex = ImageTexture.create_from_image(po_img.get_region(used))
	coins_tex = load("res://sprites/coins.png")   # 3 spin frames, 16px each
	coinpop_tex = load("res://sprites/coin_pop.png")  # 4 frames (A1..A4), 16px each
	flag_ball_tex = load("res://sprites/flagpole_ball.png")
	flag_flag_tex = load("res://sprites/flagpole_flag.png")
	flag_base_tex = load("res://sprites/flagpole_base.png")
	sign_tex = [load("res://sprites/sign/sign 1.png"), load("res://sprites/sign/sign 2.png")]
	_gen_stars()


func _draw() -> void:
	if mode == "bg":
		if main.intro_12:
			if not main.underground:
				_draw_stars(main.cam_x)   # overworld starfield behind the intro scene
			_draw_intro_scene()    # ground + castle, BEHIND Mario (sky = clear colour)
			return
		if not main.underground:   # 1-4 underground = plain black backdrop, no stars
			_draw_stars(main.cam_x)
		_draw_signs()              # blinking background signs (behind Mario)
	else:
		if main.intro_12:
			_draw_intro_pipe()     # pipe, IN FRONT of Mario so he vanishes behind it
			if main._intro_sonic:
				_draw_sonic_demo() # 3-2: Sonic jumps in and foot-taps on top of the pipe
			return
		if main.has_flag:                  # levels with a custom ending (1-2) draw neither
			_draw_flag(main.cam_x)
			_draw_castle(main.cam_x)
		_draw_pipeovers()
		if main.sonic_demo or main.sonic_cut or main._arena_sonic:
			_draw_sonic_demo()
		if main.show_rescue:
			_draw_rescue()
		_draw_qblocks()
		_draw_block_bumps()
		_draw_coins()
		_draw_particles()


# draw the giant "pipe over" sprite at every placed anchor tile (ATLAS_PIPEUP). The
# sprite's bottom-left corner is aligned to the anchor cell, so it rises up-and-right.
# Level10 preview: draw the current Sonic frame at main.sonic_x, feet on the floor line
# (raised by sonic_jump_off during a hop). SONIC_W/H = 32, bottom-aligned canvas.
func _draw_sonic_demo() -> void:
	var key := "sonic_%s_%s%d" % [main.sonic_state, main.sonic_face, main.sonic_frame]
	if not main.tex.has(key):
		return
	var t: Texture2D = main.tex[key]
	var feet_y: float = main.FLOOR * TILE + main.sonic_jump_off
	draw_texture(t, Vector2(roundf(main.sonic_x) - 16.0, roundf(feet_y) - 32.0))


func _draw_pipeovers() -> void:
	if pipeover_tex == null:
		return
	var h: int = pipeover_tex.get_height()
	for coord in main.pipeover_cells:
		draw_texture(pipeover_tex, Vector2(coord.x * TILE, (coord.y + 1) * TILE - h))


# Blinking background sign(s): decoration only (no collision). Blinks between the two
# frames every 1/3s. Anchored bottom-centre on the painted cell (post base rests on the
# tile's bottom edge, same "paint on the row whose bottom sits on the ground" convention).
func _draw_signs() -> void:
	if main.sign_cells.is_empty() or sign_tex.size() < 2:
		return
	var frame: int = int(main.qanim_phase / (1.0 / 3.0)) % 2   # swap every 1/3 second
	var t: Texture2D = sign_tex[frame]
	if t == null:
		return
	for coord in main.sign_cells:
		var dst := Rect2(
			(coord.x + 0.5) * TILE - SIGN_SRC.size.x / 2.0,
			(coord.y + 1) * TILE - SIGN_SRC.size.y,
			SIGN_SRC.size.x, SIGN_SRC.size.y)
		draw_texture_rect_region(t, dst, SIGN_SRC)


func _draw_qblocks() -> void:
	# pulse every ? / mushroom block through its three frames
	var frames: Array = main.QANIM_FRAMES
	var f: int = frames[int(main.qanim_phase / main.QANIM_STEP) % frames.size()]
	var src := Rect2(f * TILE, 0, TILE, TILE)
	for coord in main.qblock_cells:
		var dst := Rect2(coord.x * TILE, coord.y * TILE, TILE, TILE)
		draw_texture_rect_region(tiles_tex, dst, src)


func _draw_block_bumps() -> void:
	# a bumped block hops up 5px and back; its real tilemap cell is hidden while
	# this overlay draws the tile sprite at the animated y offset
	for b in main.block_bumps:
		var off: float = roundf(main.bump_offset(b.t))
		var src := Rect2(b.atlas_x * TILE, 0, TILE, TILE)
		var dst := Rect2(b.coord.x * TILE, b.coord.y * TILE - off, TILE, TILE)
		draw_texture_rect_region(tiles_tex, dst, src)


func _rect(x: float, y: float, w: float, h: float, col: Color) -> void:
	draw_rect(Rect2(x, y, w, h), col)


func _draw_coins() -> void:
	# spin through the 3 frames on the same cadence as the ? blocks
	var f: int = int(main.qanim_phase / main.QANIM_STEP) % 3
	var src := Rect2(f * 16, 0, 16, 16)
	for c in main.coins_list:
		if c.got:
			continue
		draw_texture_rect_region(coins_tex, Rect2(c.pos.x - 2, c.pos.y, 16, 16), src)


func _draw_particles() -> void:
	for p in main.particles:
		if p.type == "coinpop":
			# SMB1 block-coin: arcs up fast off the block and back down, spinning
			# FAST and continuously through the 4 frames A1->A2->A3->A4
			var e: float = clampf(main.COINPOP_DUR - p.life, 0.0, main.COINPOP_DUR)
			var u: float = e / main.COINPOP_DUR                 # 0..1
			# asymmetric arc: rises from the block (0) to the peak, then falls back
			# only to COINPOP_END (a tile above the block) where it vanishes
			var rise: float
			if u <= 0.5:
				var k: float = 2.0 * u                          # 0..1 going up
				rise = main.COINPOP_PEAK * (1.0 - (1.0 - k) * (1.0 - k))
			else:
				var k: float = 2.0 * u - 1.0                    # 0..1 coming down
				rise = lerp(main.COINPOP_PEAK, main.COINPOP_END, k * k)
			rise = roundf(rise)
			var f: int = int(e / 0.04) % 4                      # ~3 spins over the pop
			var src := Rect2(f * 16, 0, 16, 16)
			var sz: float = main.COINPOP_SIZE
			var bottom: float = p.top - rise                    # coin sits on the block, then lifts off
			var dst := Rect2(roundf(p.cx - sz / 2.0) + 1.0, roundf(bottom - sz), sz, sz)  # nudged 1px right
			draw_texture_rect_region(coinpop_tex, dst, src)
		elif p.type == "debris":
			# a single tumbling brick-break chunk (8px art centred in a 16px cell),
			# rotated about its centre — 4 of these fly apart when a brick breaks
			var sz := 16.0
			var src := Rect2(p.atlas_x * TILE, 0, TILE, TILE)
			draw_set_transform(p.pos, p.ang, Vector2.ONE)
			draw_texture_rect_region(tiles_tex, Rect2(-sz / 2.0, -sz / 2.0, sz, sz), src)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		elif p.type == "fireburst":
			# SMB1 fireball explosion: 3 growing frames, each held 2 game-frames
			var age: float = main.FIREPOP_DUR - p.life
			var f: int = clampi(int(age / (2.0 / 60.0)), 0, 2)
			var s := 16.0
			draw_texture_rect(main.tex["fpop%d" % f],
				Rect2(p.pos.x - s / 2.0, p.pos.y - s / 2.0, s, s), false)


# ---- cyberpunk "inside a computer" circuit-board background ----------------
const STAR_CELL := 384          # circuit pattern this wide, tiled across the screen (name kept)
const GRID := 16                # PCB grid spacing
const C_GRID := Color(0.12, 0.5, 0.22, 0.16)   # faint green grid
const C_TRACE := Color(0.16, 0.78, 0.34)       # circuit trace
const C_GLOW := Color(0.2, 1.0, 0.45, 0.10)    # soft glow under traces
const C_NODE := Color(0.45, 1.0, 0.55)         # solder pad / node
const C_PULSE := Color(0.75, 1.0, 0.8)         # bright data pulse
var _stars := []                # trace polylines (cell-space) — name kept: the bg layer
var _nodes := []                # {pos, r} solder pads
var _pulses := []               # {idx, speed, phase} animated dots along traces

func _gen_stars() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 20260729
	var vh: float = float(main.VIEW_H)
	# lay down Manhattan-routed circuit traces on the grid
	for i in range(14):
		var pts := PackedVector2Array()
		var x := float((rng.randi() % (STAR_CELL / GRID)) * GRID)
		var y := float((rng.randi() % int(vh / GRID)) * GRID)
		pts.append(Vector2(x, y))
		var segs := 3 + rng.randi() % 4
		for s in range(segs):
			if s % 2 == 0:
				x += float((1 + rng.randi() % 4) * GRID * (1 if rng.randf() < 0.5 else -1))
				x = clampf(x, 0.0, float(STAR_CELL))
			else:
				y += float((1 + rng.randi() % 3) * GRID * (1 if rng.randf() < 0.5 else -1))
				y = clampf(y, 0.0, vh)
			pts.append(Vector2(x, y))
		_stars.append(pts)
		# solder pads at both ends
		_nodes.append({"pos": pts[0], "r": 1.5 + rng.randf() * 1.5})
		_nodes.append({"pos": pts[pts.size() - 1], "r": 1.5 + rng.randf() * 1.5})
		# ~half the traces carry a moving data pulse
		if rng.randf() < 0.55:
			_pulses.append({"idx": i, "speed": 0.15 + rng.randf() * 0.35, "phase": rng.randf()})

# point at arc-length distance `d` along a polyline
func _point_along(pts: PackedVector2Array, d: float) -> Vector2:
	for i in range(pts.size() - 1):
		var seg: float = pts[i].distance_to(pts[i + 1])
		if d <= seg:
			return pts[i].lerp(pts[i + 1], d / seg if seg > 0.0 else 0.0)
		d -= seg
	return pts[pts.size() - 1]

func _draw_stars(cam_x: float) -> void:
	var vw: float = float(main.VIEW_W)
	var vh: float = float(main.VIEW_H)
	var cam_y: float = main.cam_y              # viewport top-left in world = (cam_x, cam_y)
	# 1) PCB grid — fills the WHOLE viewport wherever the camera is (both axes), so scrolling
	#    up (climbing) still shows the grid instead of empty sky above world-y 0.
	var x := cam_x - fmod(cam_x, GRID)
	while x <= cam_x + vw:
		draw_line(Vector2(x, cam_y), Vector2(x, cam_y + vh), C_GRID, 1.0)
		x += GRID
	var y := cam_y - fmod(cam_y, GRID)
	while y <= cam_y + vh:
		draw_line(Vector2(cam_x, y), Vector2(cam_x + vw, y), C_GRID, 1.0)
		y += GRID
	# 2) circuit traces + nodes, tiled in BOTH axes with parallax so the pattern is present
	#    across the full painted level height, not just the first screen.
	var tt: float = Time.get_ticks_msec() / 1000.0
	var offx := fmod(cam_x * 0.35, float(STAR_CELL))
	var offy := fmod(cam_y * 0.35, vh)
	var kx := -STAR_CELL
	while kx < int(vw) + STAR_CELL:
		var jy := -int(vh)
		while jy <= int(vh):
			draw_set_transform(Vector2(cam_x + float(kx) - offx, cam_y + float(jy) - offy), 0.0, Vector2.ONE)
			for tr in _stars:
				draw_polyline(tr, C_GLOW, 3.0)      # soft glow
				draw_polyline(tr, C_TRACE, 1.0)     # bright core
			for n in _nodes:
				draw_circle(n.pos, n.r + 1.0, C_GLOW)
				draw_circle(n.pos, n.r, C_NODE)
			for p in _pulses:
				var tr2: PackedVector2Array = _stars[p.idx]
				var total := 0.0
				for i in range(tr2.size() - 1):
					total += tr2[i].distance_to(tr2[i + 1])
				var d: float = fmod(tt * p.speed * total + p.phase * total, total)
				var pos := _point_along(tr2, d)
				draw_circle(pos, 2.0, C_PULSE)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)   # reset
			jy += int(vh)
		kx += STAR_CELL


const C_POLE_GREEN := Color(0, 1, 0)   # bright green pole

func _draw_flag(cam_x: float) -> void:
	return   # Vania: no flagpole
	var pole_cx: float = main.FLAG_X * TILE + 8    # pole centre x
	var pole_top: float = (main.FLOOR - 11) * TILE
	var base_top: float = (main.FLOOR - 1) * TILE  # base block sits on the ground (row FLOOR-1)
	# pole: a 2px green line from just under the ball down into the base
	draw_rect(Rect2(pole_cx - 1, pole_top, 2, base_top - pole_top), C_POLE_GREEN)
	# base block on the ground
	draw_texture(flag_base_tex, Vector2(main.FLAG_X * TILE, base_top))
	# ball topper (its bottom nub meets the pole top)
	var bw: float = flag_ball_tex.get_width()
	var bh: float = flag_ball_tex.get_height()
	draw_texture(flag_ball_tex, Vector2(roundf(pole_cx - bw / 2.0), pole_top - bh + 2))
	# flag hangs on the LEFT of the pole at the animated flag_y (right edge on the pole)
	var fw: float = flag_flag_tex.get_width()
	draw_texture(flag_flag_tex, Vector2(pole_cx - fw, roundf(main.flag_y)))


func _draw_castle(cam_x: float) -> void:
	return   # Vania: no castle/house
	# 80x80 (5x5 tile) sprite; its base sits on the FLOOR line
	var left: int = main.CASTLE_X * TILE
	var top: int = (main.FLOOR - 5) * TILE
	draw_texture(castle_tex, Vector2(left, top))

# 1-2 surface intro. Camera is fixed at cam_x=0, so world == screen here. Split across the
# two renderers so Mario (z=0) sits BETWEEN them: ground + castle in the bg (behind him, he
# strolls out of the door and over the ground), the pipe in the fg (in front, so he
# disappears behind it as he walks in).
func _draw_intro_scene() -> void:
	var floor_y: int = main.FLOOR * TILE
	# ground: two solid rows of the standard ground tile across the screen
	var src := Rect2(0, 0, TILE, TILE)
	var gx := 0
	while gx < main.VIEW_W + TILE:
		draw_texture_rect_region(tiles_tex, Rect2(gx, floor_y, TILE, TILE), src)
		draw_texture_rect_region(tiles_tex, Rect2(gx, floor_y + TILE, TILE, TILE), src)
		gx += TILE
	# castle (house) on the left, base on the ground
	draw_texture(castle_tex, Vector2(main.INTRO_CASTLE_X, float(floor_y - 5 * TILE)))

func _draw_intro_pipe() -> void:
	var floor_y: int = main.FLOOR * TILE
	draw_texture(endpipe_tex, Vector2(main.INTRO_PIPE_X, float(floor_y - endpipe_tex.get_height())))

# "mac", the rescued character at the end of Bowser's castle: alternates his two
# arm-raise frames on a timer, feet planted on the ledge (main.rescue_pos).
func _draw_rescue() -> void:
	var feet: Vector2 = main.rescue_pos
	if main._rescue_is_am:
		# DK stage (2-4): am holds A1, then switches to A2 once the beat elapses
		var at: Texture2D = main.tex["am1" if main._am_a2 else "am0"]
		draw_texture(at, Vector2(feet.x - main.AM_W / 2.0, feet.y - main.AM_H))
		return
	var frame := 0 if int(main.rescue_t / main.RESCUE_FRAME_STEP) % 2 == 0 else 1
	var t: Texture2D = main.tex["mac%d" % frame]
	var top_left := Vector2(feet.x - main.MAC_W / 2.0, feet.y - main.MAC_H)
	draw_texture(t, top_left)
