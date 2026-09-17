extends CharacterBody2D
class_name Player
## The player character. Uses CharacterBody2D + move_and_slide against the
## world StaticBody. Handles walk/run, a variable-height jump, growth/shrink,
## damage, death and the flagpole win sequence.

var main                       # Main level manager (untyped to avoid a cyclic class dependency)
var sprite: Sprite2D
var _kamen_tex := {}            # KAMEN character: baked head-replaced pose sprites, keyed like main.tex
var _simple_tex := {}           # simple 3-frame characters: {char: {walk1,walk2,jump}} (guy, grass)
const SIMPLE_CHARS := ["guy", "grass", "hal2"]   # guy/grass/hal2 — 2 walk + 1 jump, art faces RIGHT.
									# hal2 is an ORIGINAL placeholder character (not derived from any
									# existing game) — swap in real final art later.
var shape: CollisionShape2D
var col_size: Vector2             # AABB size used for gameplay hit tests
var _caps: CapsuleShape2D         # physics shape — a capsule glides over tile seams

const SMALL := Vector2(12, 14)   # 14 (not 16) so small Mario fits through a 1-tile gap
								 # with ~2px headroom, SMB1-style (his 16px sprite overhangs)
const BIG := Vector2(12, 28)
const GUY_SIZE := Vector2(12, 24)   # GUY is shorter — his hitbox matches his 24px sprite so he
                                     # bonks ceilings by the SPRITE, not invisible pixels above it
const DUCK := Vector2(12, 14)       # crouch collision — ~1 tile tall so big/fire Mario fits
									# UNDER a 1-tile gap and can slide through it (SMB1)
const DUCK_DECEL := 120.0           # ABSOLUTE duck-slide deceleration (px/s²). A ~6-tile slide
									# from full run. NOT derived from FRICTION (which is now the gentle
									# SMB1 coast 133 → scaling it made the duck slide on ice).
# SMB1 "RUN over 1-tile gaps": while moving fast, momentum carries Mario across a single-
# tile gap if a foot corner is still over a block — but if he's slow or stopped he FALLS
# straight in (the gaps are real, not invisible floors). Only kicks in above GAP_MIN_SPEED
# (between walk 85.5 and run 148.5, so you must be running). FOOT_SPAN = corner offset;
# CARRY_FALL = how far he can have dropped and still be caught back onto the ledge.
const FOOT_SPAN := 8.0
const CARRY_FALL := 10.0
const GAP_MIN_SPEED := 55.0    # halved to match the halved run speed

var big := false
var fire := false               # fire power (implies big); can shoot fireballs
var facing := 1
var walk_anim := 0.0
var _ai_jump_hold := 0.0          # attract-demo: how long to keep the jump button held
var wall_push := 0.0            # >0 while pushing into a wall (is_on_wall flickers)
var ducking := false            # big/fire Mario crouching (hold Down)
var duck_locked := false        # a duck-jump stays ducked until it lands (ignores Down release)

# ---- Vania power-ups (collected from the shape items) ----------------------
var has_double_jump := false    # SQUARE: one extra jump in mid-air
var has_break := false          # TRIANGLE: jump then Down to slam & break blocks below
var has_morph := false          # CIRCLE: press Down on the ground to become a morph ball
var has_bombs := false          # BOMB pickup: lets the morph ball drop bombs (needs the ball too)
var has_balljump := false       # SPRING BALL pickup: the morph ball can jump (2 tiles) without unrolling
var has_walljump := false       # DIAMOND: slide down walls and leap off them
var has_grapple := false        # STAR: shoot X near a grab point to zip up to it
var has_boomerang := false      # BOOMERANG: press X to throw a returning boomerang
const SHOT_RECOIL := 95.0       # firing the SHOT kicks the shooter back (opposite facing)
const SHOT_RECOIL_UP := 65.0    # a little upward pop so the recoil floats back instead of just sliding
var has_waterwalk := false      # W: walk on top of water (it becomes solid footing; no sink/slow)
var has_dash := false            # DASH: press Dash (F / controller LB) to lunge forward, smashing enemies + brittle blocks
var dashing := false
var dash_timer := 0.0
var dash_cd := 0.0
const DASH_SPEED := 245.0
const DASH_TIME := 0.20
const DASH_COOLDOWN := 0.35
var has_riderkick := false        # RIDER KICK: in the AIR, press Dash to dive-kick down-forward (Kamen's finisher)
var riderkicking := false
var has_timeslow := false         # OVERCLOCK: press to briefly slow the world (not you)
var has_boostball := false        # BOOST BALL: while morphed, hold Dash + a direction to charge a
                                   # high-speed roll that smashes brittle blocks and enemies on contact
var boosting := false
var boost_charge := 0.0
var _boost_run_held := false      # last frame's RUN state (own edge-detect — see _morph_physics)
var _boost_charge_sfx: AudioStreamPlayer = null   # the revving sound, looped manually while charging
var boost_timer := 0.0
const BOOST_CHARGE_TIME := 0.45   # seconds held before it launches
const BOOST_SPEED := 780.0        # speed of the boost roll — 3x the original 260
const BOOST_TIME := 0.35          # how long the boost roll lasts
var has_chargebeam := false       # CHARGE BEAM: hold Shot to charge a blast worth 3 normal shots
var charge_t := 0.0
const CHARGE_TIME := 1.8          # seconds held to reach a full charge (was 0.9 -- doubled)
var _charge_beam_sfx: AudioStreamPlayer = null   # the charging-up sound, looped manually while charging
var has_longbeam := false         # LONG BEAM: the shot travels a full screen width instead of 48px
var has_hover := false            # HOVER JETS: hold Jump in the air to float down slowly (limited fuel)
var hover_fuel := 0.0
const HOVER_FUEL_MAX := 1.1       # seconds of hover per airtime
const HOVER_FALL := 26.0          # capped fall speed while hovering (gentle float)
const KICK_X := 175.0             # forward speed of the dive-kick
const KICK_Y := 300.0             # downward speed of the dive-kick
const KICK_BOUNCE := -235.0       # pop off the ground/wall/enemy after a kick lands
const KICK_HOP := -120.0          # small upward pop at the START (leap into the bicycle kick)
const KICK_SPIN := 26.0           # how fast the body somersaults (bicycle-kick spin, rad/s)
var riding := false             # on the bike — lava becomes solid footing you drive across
var bike = null                # the Bike node currently being ridden
const BIKE_MOVE := 1.08         # bike speed of normal (0.72 +50%)
const BIKE_MOUNT_RANGE := 28.0  # how close you must be to a bike to press the button and mount
var boomerangs: Array = []      # active shots in flight (up to MAX_ACTIVE_SHOTS at once)
const MAX_ACTIVE_SHOTS := 2     # fire rate: was locked to 1 shot in flight at a time; 2 = double rate
var wall_dir := 0               # -1 wall on left, +1 wall on right, 0 none (wall-jump)
var last_wall_dir := 0          # last wall jumped from, to alternate in a tight shaft
const WALL_SLIDE_MAX := 46.0    # slow cling-slide down a wall (easy to time the jump)
const WALLJUMP_X := 215.0       # strong shove ACROSS to the opposite wall
const WALLJUMP_Y := -262.0      # good height per wall-jump so you climb the shaft
const WALL_LOCK_TIME := 0.16    # briefly hold the shove so you actually reach the far wall
var wall_lock := 0.0
var grappling := false
var grapple_target := Vector2.ZERO
var rope_len := 0.0              # fixed pendulum length while swinging
var extending := false          # BIONIC COMMANDO: the claw is shooting out toward a hook, not latched yet
var extend_target := Vector2.ZERO
var extend_time := 0.0
const EXTEND_TIME := 0.24       # seconds for the claw to fly out and reach the hook (half speed = visible throw)
const GRAPPLE_RANGE := 85.0      # how close you must be to latch on; the rope then reels to ROPE_SET
								 # so the swing is the same length no matter how far you grabbed from
const SWING_GRAV := 1000.0       # gravity while swinging (halved — slower, gentler swing)
const SWING_ACCEL := 700.0       # left/right pump strength (halved)
const SWING_MAX := 180.0         # cap swing speed (halved = swing at half speed)
const ROPE_MIN := 40.0
const ROPE_MAX := 85.0           # longest swing the chain art can cover (art chains are ~88px); the
								 # rope STARTS at the grab distance (capped here) then reels to ROPE_SET
const ROPE_SET := 48.0           # the swing normalises to THIS length after latching, so every grab
								 # swings at the same, lava-clearing height (no more "sometimes too long")
const REEL_SPEED := 150.0        # px/s the rope reels toward ROPE_SET (in OR out) once latched
const FIST_X := 5.0              # Mario's raised-hand offset from centre (jump-pose fist at tex(13,2));
const FIST_Y := -16.0            # x flips with facing. The rope pivots and the chain ends at THIS
								 # hand pixel, so it visibly grabs his fist instead of floating nearby.
const FLING_MAX := 360.0         # cap on release speed (= SWING_MAX, so a full swing carries fully)
const FLING_GRAV := 0.9          # only a SLIGHT gravity ease so the arc carries — not floaty
const FLING_DRAG := 60.0         # light drag: horizontal momentum carries you across the gap
var fling_t := 0.0               # after a swing release, keep the flung momentum this long
var air_jump_used := false      # spent the mid-air jump this airtime
var air_was_submerged := false  # was in water since last on the ground → no double-jump out of it
var slamming := false           # a down-break slam is in progress
var morphed := false            # currently a morph ball
var _ball_tex: ImageTexture     # generated morph-ball sprite
var _claw_r: Array = []         # facing-right claw textures, index 0..2 = horizontal,45,vertical
var _claw_l: Array = []         # facing-left  claw textures, same order
var _claw_tip_r: Array = []     # claw-head anchor point (0..1 within cell), facing right
var _claw_tip_l: Array = []     # claw-head anchor point, facing left
var _claw_dir_r: Array = []     # chain direction in box-space (from tip toward chain end), facing right
var _claw_dir_l: Array = []     # chain direction in box-space, facing left
const MORPH := Vector2(12, 12)  # tiny ball collision — rolls into gaps
const SLAM_SPEED := 520.0       # ground-pound crash speed (faster than normal MAX_FALL)
const SLAM_FREEZE := 0.25       # seconds Mario hovers tucked in the duck before crashing
var slam_timer := 0.0

# ---- WATER (Super Metroid style) -------------------------------------------
# You don't swim — you still walk/jump — but while submerged everything is heavily
# slowed: move speed, jump height and fall all drop. main.in_water() marks the zones.
const WATER_MOVE := 0.25        # horizontal top-speed + acceleration multiplier in water (halved from 0.5;
								#  only applies WITHOUT the water power-up — has_waterwalk skips water physics)
const WATER_JUMP := 0.72        # jump-launch multiplier — a small ~1-tile hop off footing
const WATER_GRAV := 0.42        # gravity multiplier in water (applies to BOTH rise and sink,
								# so the hop pops once with no floaty hold-jump rise)
const WATER_MAX_FALL := 90.0    # steady sink speed — drifts down to the bottom, no hovering
const WATER_TINT := Color(0.55, 0.75, 1.0)   # blue tint on Mario while he's underwater
var submerged := false          # updated each frame in _update_alive
var _water_split := false        # this frame: split-tint the sprite at the surface line
var _water_surface_y := 0.0      # world-Y of the water surface at the player's column
var _water_mat: ShaderMaterial   # canvas shader — tints only fragments BELOW _water_surface_y

# sprite tier for the current power state: "small" / "big" / "fire"
func tier() -> String:
	if fire: return "fire"
	if big: return "big"
	return "small"

var dead := false
var dead_timer := 0.0
var died_by_pit := false
var death_launched := false      # enemy death: pop-up starts after a brief pose hold

var transforming := false
var transform_timer := 0.0
var transform_to_big := false
var transform_fire := false     # big -> fire flicker (no size change)
# EXACT SMB1 grow/shrink: HandleChangeSize advances one step every 4th frame for
# 10 steps = 40 frames, driven by ChangeSizeOffsetAdder (smbdis / Xkeeper0 smb1).
# Grow alternates small(0)/big(1) with an intermediate(2); shrink alternates
# small(0)/big(1). We map the SMB1 states onto the GROW.png frames.
const TRANSFORM_TIME := 40.0 / 60.0                 # 10 steps x 4 frames @ 60fps (grow)
# SMB1 halts Mario only ~15 frames on an injury shrink (TimerControl $ff→$f0), THEN he
# keeps moving while flashing — far shorter than the ~1s grow freeze, so momentum barely
# stalls. Ours matches that brief hitch instead of pinning him for the full grow length.
const SHRINK_TIME := 55.0 / 60.0                    # SMB1 injury freeze = TimerControl $ff→$c8 = 55 frames (~0.9s)
const TRANSFORM_STEP := 4.0 / 60.0                  # SMB1 change-size cadence: one flicker step per 4 frames
# fire-flower flash: SMB1 CyclePlayerPalette swaps sprite palette every 4 frames
# (FrameCounter/4 & 3), running while TimerControl counts $ff->$c0 = 63 frames,
# then forces palette 0 (fire). Palette 0 = fire; 1..3 = the fl1.png recolours.
const FIRE_TIME := 63.0 / 60.0                       # $ff-$c0 = 63 frames (~1.05s)
const FIRE_STEP := 4.0 / 60.0                        # a new palette every 4 frames
const GROW_SEQ := [0, 1, 0, 1, 0, 1, 2, 0, 1, 2]    # SMB1 growing adder pattern
const SHRINK_SEQ := [0, 1, 0, 1, 0, 1, 0, 1, 0, 1]  # SMB1 shrinking: small<->big
const GROW_FRAME := ["grow1", "grow4", "grow2"]     # 0 small, 1 big, 2 intermediate
const SHRINK_FRAME := ["shrink4", "shrink1"]        # 0 small (D), 1 big (A)

var invuln := 0.0
var hurt_lock := 0.0             # brief control lock after a hit so the knockback shove reads
var heal_lock := false          # standing on a LifeStation tile — movement input ignored while true
var door_walk := 0              # !=0 = auto-walking through a door (Metroid transition), that direction
var _door_step_done := false    # one-shot guard so the door-threshold step-up hop only fires once
const DOOR_WALK_SPEED := 0.595  # fraction of walk speed for the door cutscene stroll (lower = slower; was 0.7, -15%)
const HURT_KNOCK_X := 95.625     # horizontal knockback (shoved opposite to facing) — 25% less than 127.5
const HURT_KNOCK_UP := -114.75   # upward pop on a hit — 25% less than -153 (NES Metroid: $FD = -3 px/frame)
const HURT_LOCK_TIME := 0.3      # seconds movement input is ignored after a hit
# ---- NES METROID physics, from the NES engine disassembly (metroidret/m1disasm prg7_engine.asm).
# NES speeds are px/frame at 60fps (x60 = px/s); gravity is added in 1/256 px/frame per frame. ----
const NES_JUMP_V := -217.9       # was -207.8 (25% lower than NES); +10% height on that (speed x sqrt(1.10))
const NES_JUMP_GRAV := 337.5     # $18/256 px/f^2 — the WHOLE ground jump, rising and falling
const NES_LEDGE_GRAV := 365.6    # $1A/256 — falling that isn't part of a jump (walked off a ledge)
const NES_HIT_GRAV := 787.5      # $38/256 — the knockback arc after taking a hit
const NES_MAX_FALL := 300.0      # VertAccelerate: max downward speed 5 px/frame
const NES_MIN_JUMP := 32.0       # SamusJump: a jump always rises 32px; after that, releasing Jump stops the rise
const NES_AIR_STAND := 60.0      # standing jump: horizontal speed SET to 1 px/frame each frame (no momentum)
const NES_AIR_RUN := 67.5        # running jump: SamusHorzSpeedMax = $12 = 1.125 px/frame
const NES_STOP := 20000.0        # letting go on the ground stops Samus dead (StopHorzMovement)
const NES_HURT_INVULN := 0.833   # CheckHealthStatus: blink / invincible for 50 frames
var _nes_jump := false           # in an NES ground jump until landing (NES_JUMP_GRAV + the release cut)
var _nes_run_jump := false       # that jump started while moving (running-jump air rules)
var _jump_y0 := 0.0              # y where the jump started (for the 32px minimum rise)
var _hit_arc := false            # knocked back by a hit -> NES_HIT_GRAV until landing
const MAX_HP := 100              # numeric health: starts at 100
const HP_PER_HIT := 10           # each hit costs 10; death at 0
var hp := MAX_HP                 # current health (0..100). Reset to full on spawn.
var jump_held := false
var was_rising := false
var grounded := false            # is_on_floor() OR a foot resting over a 1-tile gap (SMB1)
var stomp_bounce := false        # true during a stomp rebound → fixed arc, no jump-hold float
# sharp-turn (skid): shown when Mario reverses while MOVING on the ground (not from a
# standstill). Re-armed every frame he's still sliding the old way, so it tracks the whole
# slide (~8 frames at run with the slow TURN_ACC); SKID_TIME is just a short tail after.
var skid_timer := 0.0
var skid_dir := 0                # the NEW direction he's turning toward (art faces momentum)
const SKID_TIME := 0.04          # ~2-frame tail after the slide ends
const SKID_MIN_SPEED := 20.0     # must actually be moving to skid (standstill+opposite = no)

# win sequence
var winning := false
var win_phase := 0
var win_timer := 0.0
var win_flip := 0        # frames held on the far side of the pole after flipping over
const WIN_FLIP_HOLD := 30 # how many frames Mario pauses on the far side before dropping


func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	# Keep him planted on the floor: without this the rounded capsule leaves the floor for a
	# frame at every tile seam (default floor_snap_length is only 1px), which reads as clunky
	# micro-hopping when you run a flat corridor. Snapping down a few px glides him over seams.
	floor_snap_length = 6.0
	floor_constant_speed = true          # steady ground speed over seams/small steps
	floor_stop_on_slope = true
	_caps = CapsuleShape2D.new()
	shape = CollisionShape2D.new()
	shape.shape = _caps
	add_child(shape)
	_set_col(SMALL)
	sprite = Sprite2D.new()
	sprite.texture_filter = TEXTURE_FILTER_NEAREST
	sprite.z_index = 5
	add_child(sprite)
	# KAMEN character = Mario's body/animation with his head replaced by the baked Kamen head.
	# Load every kamen_<pose>.png keyed to match main.tex ("big_stand_r" -> kamen_big_stand_r.png).
	for tier_p in ["big", "fire"]:
		for suf in ["_stand_l", "_stand_r", "_walk1", "_walk2", "_walk3", "_walk4", "_walk5",
				"_walk6", "_jump_l", "_jump_r", "_skid", "_duck"]:
			var kp := "res://sprites/player/kamen_%s%s.png" % [tier_p, suf]
			if ResourceLoader.exists(kp):
				_kamen_tex[tier_p + suf] = load(kp)
	# simple 3-frame characters (guy, grass): 2 walk + 1 jump, art faces RIGHT
	for ch in SIMPLE_CHARS:
		var frames := {}
		for gk in ["walk1", "walk2", "jump", "up"]:   # "up" (e.g. guy_up.png) = optional aim-up pose
			var gp := "res://sprites/player/%s_%s.png" % [ch, gk]
			if ResourceLoader.exists(gp):
				frames[gk] = load(gp)
		if not frames.is_empty():
			_simple_tex[ch] = frames
	# SPLIT WATER TINT: a canvas shader that only tints fragments whose WORLD-Y is at or below
	# the water surface line. The vertex stage carries each fragment's world-Y (MODEL_MATRIX
	# folds in the player transform, sprite offset and any morph rotation), so half-submerged
	# Mario shows blue only up to the water line. Assigned in _apply_frame only while in water.
	_water_mat = ShaderMaterial.new()
	var _wsh := Shader.new()
	_wsh.code = "shader_type canvas_item;\n" \
		+ "uniform float water_y = 100000.0;\n" \
		+ "uniform vec4 tint : source_color = vec4(1.0);\n" \
		+ "varying float v_world_y;\n" \
		+ "void vertex() { v_world_y = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).y; }\n" \
		+ "void fragment() { if (v_world_y >= water_y) { COLOR.rgb *= tint.rgb; } }\n"
	_water_mat.shader = _wsh
	_water_mat.set_shader_parameter("tint", WATER_TINT)
	_ball_tex = _make_ball_tex()
	# GRAPPLE CLAW sheet (sprites/v sprites/theclaw.png): 3 angles x 2 facings, drawn WHOLE (the
	# claw + the chain the user drew — no procedural chain). Each claw is extracted into its own
	# clean texture (largest connected component, so a neighbour claw sharing a box can't bleed in).
	# Index 0..2 = horizontal, ~45, straight-up; "tip" (0..1 in the box) is the claw head / grab
	# point. Boxes come from a connected-component scan of the sheet — re-run the tools if re-saved.
	var _sheet: Image = (load("res://sprites/v sprites/theclaw.png") as Texture2D).get_image()
	if _sheet.is_compressed():
		_sheet.decompress()
	_sheet.convert(Image.FORMAT_RGBA8)
	_claw_r = [_extract_claw(_sheet, Rect2i(64, 61, 90, 7)), _extract_claw(_sheet, Rect2i(109, 60, 77, 42)), _extract_claw(_sheet, Rect2i(227, 60, 7, 97))]
	_claw_l = [_extract_claw(_sheet, Rect2i(362, 61, 90, 7)), _extract_claw(_sheet, Rect2i(330, 60, 77, 42)), _extract_claw(_sheet, Rect2i(282, 60, 7, 97))]
	_claw_tip_r = [Vector2(1.0, 0.5), Vector2(1.0, 0.0), Vector2(0.5, 0.0)]
	_claw_tip_l = [Vector2(0.0, 0.5), Vector2(0.0, 0.0), Vector2(0.5, 0.0)]
	# chain direction inside each box, from the claw head toward the chain's far end
	_claw_dir_r = [Vector2(-1, 0), Vector2(-1, 1), Vector2(0, 1)]
	_claw_dir_l = [Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]


# the morph-ball sprite = the user's ball2.png art. The ball occupies this box in
# ball2.png (getbbox = (13,31)-(29,47), 16x16 as of 2026-09-03 re-save) — RE-DETECT if re-saved.
# Fit it into a centered 16x16 (preserving aspect) so it rolls cleanly about its center.
func _make_ball_tex() -> ImageTexture:
	var sheet: Image = (load("res://sprites/v sprites/ball2.png") as Texture2D).get_image()
	if sheet.is_compressed():
		sheet.decompress()
	sheet.convert(Image.FORMAT_RGBA8)
	var src := Rect2i(13, 31, 16, 16)
	var crop := Image.create(src.size.x, src.size.y, false, Image.FORMAT_RGBA8)
	crop.blit_rect(sheet, src, Vector2i.ZERO)
	var s: float = 16.0 / float(maxi(src.size.x, src.size.y))
	var sw: int = int(round(src.size.x * s))
	var sh: int = int(round(src.size.y * s))
	crop.resize(sw, sh, Image.INTERPOLATE_LANCZOS)
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.blit_rect(crop, Rect2i(0, 0, sw, sh), Vector2i((16 - sw) / 2, (16 - sh) / 2))
	return ImageTexture.create_from_image(img)


func _set_col(sz: Vector2) -> void:
	col_size = sz
	_caps.radius = sz.x / 2.0
	_caps.height = sz.y          # height >= 2*radius (12), true for 16 and 28

# the standing (big-tier) collision size for the current character — GUY is shorter
func _stand_size() -> Vector2:
	return GUY_SIZE if main.selected_char in SIMPLE_CHARS else BIG

func half_w() -> float:
	return col_size.x / 2.0

# ---- attract-mode auto-play AI ----
# Runs right + run, and jumps over pits, obstacles (pipes/steps), and enemies ahead.
func _attract_ai(delta: float) -> void:
	Input.action_press("move_right")
	Input.action_press("run")
	Input.action_release("move_left")
	Input.action_release("move_down")
	var TILE: int = main.TILE
	var cx := int(global_position.x / float(TILE))
	var feet_row := int((global_position.y + col_size.y * 0.5) / float(TILE))
	# a pit ahead? no ground in the next few tiles under the feet (jump early to clear wide gaps)
	var gap := true
	for dc in [1, 2, 3]:
		if _ai_solid(cx + dc, feet_row):
			gap = false
			break
	# an obstacle ahead at body height (pipe / step / block) — look 1-2 tiles ahead, up to 3 tall
	var obstacle := false
	for dc in [1, 2]:
		if _ai_solid(cx + dc, feet_row - 1) or _ai_solid(cx + dc, feet_row - 2) or _ai_solid(cx + dc, feet_row - 3):
			obstacle = true
			break
	var blocked := is_on_wall()                   # pressed against a pipe/wall → hop over it
	# an enemy just ahead at about our height
	var enemy_near := false
	for e in main.enemies:
		if e.dead:
			continue
		var dxx: float = e.global_position.x - global_position.x
		var dyy: float = absf(e.global_position.y - global_position.y)
		if dxx > 4.0 and dxx < 3.0 * TILE and dyy < 1.5 * TILE:
			enemy_near = true
			break
	if is_on_floor() and _ai_jump_hold <= 0.0 and (gap or obstacle or enemy_near or blocked):
		_ai_jump_hold = 0.46                      # full-height jump (clears the tall pipes)
	if _ai_jump_hold > 0.0:
		Input.action_press("jump")
		_ai_jump_hold -= delta
		if _ai_jump_hold <= 0.0:
			Input.action_release("jump")
	else:
		Input.action_release("jump")

func _ai_solid(col: int, row: int) -> bool:
	if main.terrain == null or row < 0 or row > 14:
		return false
	return main.terrain.get_cell_source_id(Vector2i(col, row)) >= 0

func get_rect() -> Rect2:
	return Rect2(global_position - col_size / 2.0, col_size)


func spawn(feet_pos: Vector2) -> void:
	visible = true            # win phase 3 hides the player when entering the castle
	z_index = 0               # restore normal draw order (win walk raises it)
	# start at the carried-over power tier (main.saved_tier): small / big / fire. Death
	# sets it back to "small", so a respawn is small; beating a level keeps the tier.
	var t: String = main.saved_tier
	fire = (t == "fire")
	big = (t == "big" or t == "fire")
	_set_col(_stand_size() if big else SMALL)
	dead = false
	dead_timer = 0.0
	died_by_pit = false
	death_launched = false
	riding = false            # a respawn is never still on the bike
	bike = null
	grappling = false         # never still latched/firing the grapple after a respawn
	extending = false
	# METROIDVANIA: abilities are restored from the last SAVE (main.saved_abilities). With no save
	# for this level the dict is empty, so every flag defaults false = start powerless, exactly as
	# before; touching a SaveStation snapshots them so a death-respawn keeps what you had.
	var ab: Dictionary = main.saved_abilities
	has_double_jump = bool(ab.get("double_jump", false))
	has_break = bool(ab.get("break", false))
	has_morph = bool(ab.get("morph", false))
	has_bombs = bool(ab.get("bombs", false))
	has_balljump = bool(ab.get("balljump", false))
	has_walljump = bool(ab.get("walljump", false))
	has_grapple = bool(ab.get("grapple", false))
	has_boomerang = true    # SHOT: always start with it (the bullet weapon), regardless of pickups
	has_waterwalk = bool(ab.get("waterwalk", false))
	has_dash = bool(ab.get("dash", false))
	has_riderkick = bool(ab.get("riderkick", false))
	has_timeslow = bool(ab.get("timeslow", false))
	has_hover = bool(ab.get("hover", false))
	hover_fuel = HOVER_FUEL_MAX
	has_boostball = bool(ab.get("boostball", false))
	has_chargebeam = bool(ab.get("chargebeam", false))
	has_longbeam = bool(ab.get("longbeam", false))
	boosting = false
	boost_charge = 0.0
	_boost_run_held = false
	_stop_boost_charge_sfx()
	_stop_charge_beam_sfx()
	charge_t = 0.0
	dashing = false
	riderkicking = false
	dash_cd = 0.0
	morphed = false
	air_was_submerged = false
	hurt_lock = 0.0                     # no leftover knockback lock into a fresh life
	heal_lock = false                  # not standing on a LifeStation
	door_walk = 0                      # not mid-door-transition
	if sprite:
		sprite.modulate = Color.WHITE   # clear any leftover underwater tint
		sprite.rotation = 0.0           # clear any leftover morph-ball roll (reset while rolling)
		sprite.visible = true           # clear any leftover invuln-flash blink
	_water_split = false                # no split-tint until the next in-water frame
	hp = MAX_HP                         # full health at the start of every life
	set_collision_mask_value(1, true)   # kill() clears this to fall through the world;
										# restore it so a mid-death restart/warp doesn't
										# spawn Mario falling straight through the floor
	transforming = false
	invuln = 0.0
	winning = false
	win_phase = 0
	win_timer = 0.0
	stomp_bounce = false
	skid_timer = 0.0
	velocity = Vector2.ZERO
	facing = 1                    # start facing right
	global_position = Vector2(feet_pos.x, feet_pos.y - col_size.y / 2.0)
	var start_key: String = tier() + "_stand_r"     # first frame — use the Kamen head if picked
	if _simple_tex.has(main.selected_char):
		_apply_frame(_simple_tex[main.selected_char]["walk1"], facing < 0)
	else:
		_apply_frame(_kamen_tex[start_key] if (main.selected_char == "kamen" and _kamen_tex.has(start_key)) else main.tex[start_key])


func _physics_process(delta: float) -> void:
	queue_redraw()   # keep procedural overlays (HAL2's gun, the grapple claw) current every frame —
	                 # _draw() only re-runs when this is called, not automatically on state changes
	if main.paused:
		return
	if main.axe_ending:
		return   # frozen while the bridge collapses (he stands on the axe ledge)
	if main.intro_12:
		return   # 1-2 surface intro — main drives Mario's stroll into the pipe
	if main.pipe_exit:
		return   # 1-2 exit — main drives Mario slipping into the giant pipe
	if main.game_state == "emerge":
		return   # EXTRA 1 arrival — main drives Mario rising out of the pipe
	if main.game_state == "trap":
		return   # Level11 reward trap — main drives Mario dropping out of the ceiling pipe
	if main.sonic_demo:
		return   # Level10 Sonic preview — Mario is hidden/idle
	if main.game_state == "sonic_cut":
		return   # 1-2 cutscene — Mario watches from the pipe while Sonic performs
	if main.game_state == "arena_intro":
		return   # 3-4 boss-arena intro — main walks Mario in, then drops the block wall
	if main.start_delay > 0.0:
		return   # frozen during the brief stage-start "get ready" (Mario can't move yet)
	if main.powerup_freeze_t > 0.0:
		return   # power-up get: the whole world stops while the jingle plays (Mario freezes too)
	if main._cam_lock:
		return   # camera still settling into the new room after a door walk — hold Mario until it arrives
	if transforming:
		_update_transform(delta)
		return
	if winning:
		_update_win(delta)
		return
	if dead:
		_update_dead(delta)
		return
	if main.game_state == "rescue":
		if main.rescue_walking:
			_update_rescue_walk(delta)   # scripted walk toward mac; otherwise frozen (mac talking)
		return
	if main.game_state == "clear":
		return

	if main.attract_mode:
		_attract_ai(delta)      # self-playing demo: AI drives the inputs, then normal physics run

	if main.game_state == "credits":
		# end-credits run: hold RIGHT + RUN, never jump/duck/fire — Mario just runs on.
		# Once the roll finishes ("THE END"), release everything so he stops and stands.
		if main.credits_done:
			Input.action_release("move_right")
			Input.action_release("run")
		else:
			Input.action_press("move_right")
			Input.action_press("run")
		Input.action_release("move_left")
		Input.action_release("jump")
		Input.action_release("move_down")

	_update_alive(delta)


func _update_alive(delta: float) -> void:
	# DOOR TRANSITION: control is locked while Main auto-walks Mario through a door.
	if door_walk != 0:
		_door_walk_physics(delta)
		return
	# SMB1: only while RUNNING does "a foot over a block across a 1-tile gap" count as
	# grounded (so you glide across). Slow/stopped → not grounded → you fall in.
	# On the bike, lava counts as footing at ANY speed (you drive across its surface), so
	# ground support isn't gated on running fast the way the SMB gap-carry is.
	# Gap-carry footing only counts while NOT rising — otherwise jumping INTO a wall lets the foot-span
	# probe read the wall as "ground", resetting the air-jump (the against-wall triple-jump bug).
	var on_floor := is_on_floor() or (riding and _foot_support_top() > -INF) \
		or (absf(velocity.x) > GAP_MIN_SPEED and velocity.y >= 0.0 and _foot_support_top() > -INF)
	# WATER: submerged if the torso (body centre) is inside a painted water cell — but the
	# W power negates it entirely: you still DROP into the water, yet move/jump as if it
	# weren't there (no slow, no sink, no single-jump limit).
	submerged = main.in_water(global_position) and not has_waterwalk
	# The blue TINT is independent of the physics/suit: Mario shows blue whenever ANY part of
	# his body is in water (feet OR torso), even wearing the GRAVITY SUIT (which only removes
	# the slowdown, not the look). `submerged` above still drives the water PHYSICS only.
	var feet := global_position + Vector2(0.0, col_size.y * 0.5 - 2.0)
	var body_in_water: bool = main.in_water(feet) or main.in_water(global_position)
	# split the tint at the actual water surface: only the part of Mario BELOW the surface line
	# shows blue (jumping half-out leaves just his lower body tinted). While any part is in water
	# the shader does the tinting and modulate stays WHITE; the material is (re)assigned in
	# _apply_frame because _animate() nulls sprite.material every frame.
	_water_split = body_in_water
	if body_in_water:
		_water_surface_y = main.water_surface_y(global_position)
	sprite.modulate = Color.WHITE
	# latch "was in water this airtime" so a jump OUT of the water can't double-jump the
	# instant the torso clears the surface — you get no double-jump until you land again.
	# (Cleared on the floor below; the W power makes submerged always false, so no lock.)
	if submerged:
		air_was_submerged = true
	skid_timer = maxf(0.0, skid_timer - delta)
	fling_t = maxf(0.0, fling_t - delta)
	if on_floor:
		fling_t = 0.0   # landing ends the fling; normal speed resumes
	if on_floor:
		air_jump_used = false
		hover_fuel = HOVER_FUEL_MAX     # refuel the hover jets on landing
		air_was_submerged = submerged   # reset on land (still true if standing in shallow water)
		if slamming:
			slamming = false
			_do_slam_break()
	if on_floor and velocity.y >= 0.0:
		_nes_jump = false               # landed: the NES jump / knockback arc is over
		_hit_arc = false

	# BIKE on/off — press the bike button (RB on the controller / E on the keyboard). Near a
	# bike → hop on; already riding → hop off. It's an explicit toggle, so you never auto-mount
	# just by standing on / landing next to the bike.
	var was_riding := riding
	if Input.is_action_just_pressed("bike"):
		if riding:
			if bike and is_instance_valid(bike):
				bike.dismount()
			riding = false
			bike = null
			velocity.y = minf(velocity.y, -200.0)   # a hop as you step off
		else:
			var b = main.nearest_bike(global_position, BIKE_MOUNT_RANGE)
			if b != null:
				b.ridden = true
				riding = true
				bike = b
				main.sfx("powerup")

	if bomb_cd > 0.0:                 # morph-ball bomb cooldown (ticks every frame, even while rolled up)
		bomb_cd = maxf(0.0, bomb_cd - delta)
	# CIRCLE: morph ball has its own physics — enter with Down on the ground, then
	# roll around; Up or Jump stands back up (if there's room).
	if has_morph and not morphed and on_floor and not was_riding and Input.is_action_just_pressed("move_down"):
		_enter_morph()
	if morphed:
		_morph_physics(delta, on_floor)
		return

	# STAR: grapple beam has its own physics while latched
	if grappling:
		_grapple_physics(delta)
		return
	# DASH ATTACK (ground) / RIDER KICK (air): the same button, context-sensitive
	if dash_cd > 0.0:
		dash_cd = maxf(0.0, dash_cd - delta)
	if dashing:
		_dash_physics(delta)
		return
	if riderkicking:
		_riderkick_physics(delta)
		return
	# DASH (own button: F / LB) — ground only
	if has_dash and dash_cd <= 0.0 and on_floor and not extending and not submerged \
			and Input.is_action_just_pressed("dash"):
		dashing = true
		dash_timer = DASH_TIME
		dash_cd = DASH_TIME + DASH_COOLDOWN
		velocity = Vector2(float(facing) * DASH_SPEED, 0.0)
		main.sfx("jump_big" if (big or fire) else "jump_small")
		_dash_physics(delta)
		return
	# RIDER KICK (own button: K / right trigger RT) — air only
	if has_riderkick and not on_floor and not extending and not submerged \
			and Input.is_action_just_pressed("riderkick"):
		riderkicking = true
		velocity = Vector2(float(facing) * KICK_X, KICK_HOP)   # leap up first (into the bicycle kick)
		main.sfx("jump_big" if (big or fire) else "jump_small")
		_riderkick_physics(delta)
		return
	# OVERCLOCK: slow the whole world (not you) for a few seconds
	if has_timeslow and Input.is_action_just_pressed("timeslow"):
		main.start_time_slow()
	# BIONIC COMMANDO: the claw is flying out toward a hook. Mario keeps normal physics (below) while
	# it extends; when the arm reaches the hook it LATCHES and the swing begins.
	if extending:
		extend_time += delta
		queue_redraw()
		if absf(extend_target.x - global_position.x) > 2.0:   # face the way the arm is reaching
			facing = 1 if extend_target.x > global_position.x else -1
		if extend_time >= EXTEND_TIME:
			extending = false
			grappling = true
			grapple_target = extend_target
			rope_len = clampf((global_position + _fist_off()).distance_to(extend_target), ROPE_MIN, ROPE_MAX)
			main.sfx("bump")        # the "clink" of grabbing on (placeholder — was mistakenly using the fireball sfx)
	# GRAPPLE — keyboard X/K (shoot) near a grab point, or the controller Y (grapple): FIRE the claw
	if has_grapple and not grappling and not extending and (Input.is_action_just_pressed("shoot") or Input.is_action_just_pressed("grapple")):
		var gp: Vector2 = main.nearest_grab_point(global_position, GRAPPLE_RANGE)
		if gp != Vector2.INF:
			extending = true                 # shoot the claw out; it latches when it reaches gp
			extend_target = gp
			extend_time = 0.0
			main.sfx("grapple")              # the "shoot" of firing the arm (Bionic Commando sfx)
	# BOOMERANG / SHOT — its own button B on the controller, or C on the keyboard (the
	# keyboard "shoot" only throws when we didn't just start a grapple this frame).
	# CHARGE BEAM: hold the button to charge; releasing fires a power=3 blast. Without
	# the power-up it's the original instant-press shot (charged never triggers).
	boomerangs = boomerangs.filter(func(b): return is_instance_valid(b))
	var can_fire_now: bool = has_boomerang and not morphed and boomerangs.size() < MAX_ACTIVE_SHOTS
	if has_chargebeam and can_fire_now:
		var held_fire: bool = Input.is_action_pressed("boomerang") \
			or (not grappling and not extending and Input.is_action_pressed("shoot"))
		if held_fire:
			var was_full: bool = charge_t >= CHARGE_TIME
			charge_t += delta
			if not was_full and charge_t >= CHARGE_TIME:
				main.sfx("powerup_appear")   # a distinct "ready!" ding the instant it hits full charge
		# charging-up sound: loop it (retrigger when it finishes) for as long as you're still
		# charging; stop it the instant it's fully charged so silence = "ready to release" (same
		# convention as the Boost Ball's own charge sound).
		if held_fire and charge_t < CHARGE_TIME:
			if _charge_beam_sfx == null or not is_instance_valid(_charge_beam_sfx) or not _charge_beam_sfx.playing:
				_charge_beam_sfx = main.sfx("sonic_spin")
		else:
			_stop_charge_beam_sfx()
		var released_fire: bool = Input.is_action_just_released("boomerang") \
			or Input.is_action_just_released("shoot")
		if released_fire and charge_t > 0.0:
			_fire_shot(charge_t >= CHARGE_TIME)
			charge_t = 0.0
		elif not held_fire:
			charge_t = 0.0
	elif can_fire_now and (Input.is_action_just_pressed("boomerang") \
			or (not grappling and not extending and Input.is_action_just_pressed("shoot"))):
		_fire_shot(false)

	if wall_lock > 0.0:
		wall_lock = maxf(0.0, wall_lock - delta)
	if hurt_lock > 0.0:
		hurt_lock = maxf(0.0, hurt_lock - delta)

	var running := Input.is_action_pressed("run")
	var max_s: float = main.RUN_MAX if running else main.WALK_MAX
	var acc: float = (main.RUN_ACC if running else main.WALK_ACC) if on_floor else main.AIR_ACC
	if submerged or (not on_floor and air_was_submerged and not has_waterwalk):
		# water drags: much lower top speed and slower to build it up. Still applies for the
		# rest of the jump right after leaving the water (no waterwalk) — you don't regain full
		# speed the instant you clear the surface; it comes back once you land.
		max_s *= WATER_MOVE
		acc *= WATER_MOVE
	if riding:
		max_s *= BIKE_MOVE            # the bike creeps along at 1/4 speed
		acc *= BIKE_MOVE
	# NES METROID air control for a ground jump: a RUNNING jump is capped at 1.125 px/frame; a
	# STANDING jump moves at a fixed 1 px/frame set straight from the D-pad (applied below).
	var nes_air_stand := false
	if not on_floor and _nes_jump and fling_t <= 0.0 and not submerged and not riding:
		if _nes_run_jump:
			max_s = minf(max_s, NES_AIR_RUN)
		else:
			nes_air_stand = true

	# duck — big/fire Mario holding Down. ENTER only on the ground. A duck-jump stays
	# ducked for the WHOLE airtime until it lands (even if Down is released mid-air);
	# you can't newly enter a duck mid-air. On landing, normal rules resume (hold Down =
	# land ducked). While ducked you can't drive movement.
	var want_duck := ducking
	if riding:
		want_duck = false                           # on the bike you can't crouch (Down = hop off)
		duck_locked = false
	elif on_floor:
		want_duck = false                           # NO regular crouch — Down on the ground does nothing
		duck_locked = false                         # (Down still triggers morph-ball entry + the slam)
	elif duck_locked and (big or fire):
		want_duck = true                            # locked ducked until we land
	else:
		want_duck = false
		duck_locked = false
	# can't stand up under a low ceiling — stay crouched so he keeps SLIDING under the blocks
	if not want_duck and ducking and (big or fire) and _blocked_above(_stand_size().y):
		want_duck = true
	# ground-pound: hold the DUCK pose through the whole slam (freeze + crash)
	if slamming and (big or fire):
		want_duck = true
	# crouch shrinks the collision (feet stay planted) so big/fire Mario fits under a 1-tile
	# gap; standing restores full height. Small Mario never ducks.
	if big or fire:
		_set_stance(DUCK if want_duck else _stand_size())
	ducking = want_duck

	var dir := 0.0
	if not ducking and wall_lock <= 0.0 and hurt_lock <= 0.0 and not heal_lock:   # hold the wall-jump / knockback shove during the lock, or stand still on a LifeStation
		if Input.is_action_pressed("move_left"):
			dir = -1.0
			facing = -1
		elif Input.is_action_pressed("move_right"):
			dir = 1.0
			facing = 1

	if dir != 0.0:
		if velocity.x != 0.0 and signf(dir) != signf(velocity.x):
			# reversing — strong skid so turns feel crisp, not slippery
			if on_floor and absf(velocity.x) > SKID_MIN_SPEED:
				skid_timer = SKID_TIME       # show the sharp-turn frame (not from a standstill)
				skid_dir = int(dir)
			velocity.x = move_toward(velocity.x, dir * max_s, main.TURN_ACC * delta)
		elif absf(velocity.x) > max_s:
			# above top speed. Normally ease down — BUT right after a grapple fling, keep
			# the momentum (only very gentle air drag) so you sail across the gap.
			if fling_t > 0.0:
				velocity.x = move_toward(velocity.x, dir * max_s, FLING_DRAG * delta)
			else:
				velocity.x = move_toward(velocity.x, dir * max_s, main.FRICTION * delta)
		else:
			velocity.x = move_toward(velocity.x, dir * max_s, acc * delta)
	elif on_floor:
		# no input on the ground — NES Metroid stops Samus DEAD (StopHorzMovement). Speeds above normal
		# walking pace (a recoil shove, the run extra, knockback) still slide off with the old friction.
		var fr: float = DUCK_DECEL if ducking else main.FRICTION
		if not ducking and hurt_lock <= 0.0 and absf(velocity.x) <= main.WALK_MAX + 0.5:
			fr = NES_STOP
		velocity.x = move_toward(velocity.x, 0.0, fr * delta)
	# (no input in the air keeps horizontal momentum, like the real games)
	# NES standing jump: horizontal speed is SET each frame (1 px/frame while held, 0 when released)
	if nes_air_stand and wall_lock <= 0.0 and hurt_lock <= 0.0:
		velocity.x = dir * NES_AIR_STAND

	# DIAMOND wall-jump (Ninja Gaiden style): you CLING to any wall you're touching
	# in mid-air — no need to hold into it. In a tight shaft touching both walls, it
	# alternates off the last one so you zig-zag straight up.
	wall_dir = 0
	if has_walljump and not on_floor and not slamming and not grappling and not submerged:
		var wr := _wall_ahead(1)
		var wl := _wall_ahead(-1)
		if wr and not wl:
			wall_dir = 1
		elif wl and not wr:
			wall_dir = -1
		elif wr and wl:
			if last_wall_dir != 0:
				wall_dir = -last_wall_dir
			elif Input.is_action_pressed("move_left"):
				wall_dir = -1
			elif Input.is_action_pressed("move_right"):
				wall_dir = 1
			else:
				wall_dir = facing
	elif on_floor:
		last_wall_dir = 0   # reset the zig-zag when you touch ground

	# jump — fresh press only (allowed straight out of a duck, SMB-style)
	var jump_key := Input.is_action_pressed("jump")
	if jump_key and on_floor and not jump_held and not riding:   # no jumping while on the bike
		# jump HEIGHT rises with ACTUAL horizontal speed (momentum), not the run button —
		# SMB1: a real running jump goes ~17px higher, but standing still + run does not.
		# The sqrt(grav_scale) keeps launch/gravity consistent so DISTANCE is tuned apart.
		var st := _jump_speed_t()
		var base_v0: float = lerpf(main.JUMP_VELOCITY, main.JUMP_VELOCITY_RUN, st)
		if submerged:
			velocity.y = base_v0 * WATER_JUMP   # weak underwater hop (water physics unchanged)
		else:
			# NES METROID jump: launch at -4 px/frame ($FC), then one gravity ($18) for the whole arc
			velocity.y = NES_JUMP_V
			_nes_jump = true
			_nes_run_jump = absf(velocity.x) > 8.0   # moving = running jump (air cap 1.125 px/f), else standing
			_jump_y0 = global_position.y
		jump_held = true
		main.sfx("jump_big" if (big or fire) else "jump_small")
	elif jump_key and not on_floor and not jump_held and wall_dir != 0:
		# DIAMOND: leap UP and ACROSS to the opposite wall
		velocity.y = WALLJUMP_Y * (WATER_JUMP if submerged else 1.0)
		velocity.x = -wall_dir * WALLJUMP_X * (WATER_MOVE if submerged else 1.0)
		facing = -wall_dir
		wall_lock = WALL_LOCK_TIME
		last_wall_dir = wall_dir
		jump_held = true
		air_jump_used = false      # a wall jump refreshes the mid-air jump
		_nes_jump = false          # wall jump = an extra: keeps its own arc (original rise gravity)
		main.sfx("jump_big" if (big or fire) else "jump_small")
	elif jump_key and not on_floor and not jump_held and has_double_jump and not air_jump_used and not slamming and not submerged and not air_was_submerged:
		# SQUARE: one extra jump in mid-air (NOT in/out of water — a single jump only there)
		air_jump_used = true
		_nes_jump = false          # double jump = an extra: keeps its own tuned arc (original rise gravity)
		var st2 := _jump_speed_t()
		velocity.y = lerpf(main.JUMP_VELOCITY, main.JUMP_VELOCITY_RUN, st2) * sqrt(lerpf(1.0, main.JUMP_RUN_GRAV_SCALE, st2))
		if submerged:
			velocity.y *= WATER_JUMP
		jump_held = true
		main.sfx("jump_big" if (big or fire) else "jump_small")
	elif not jump_key:
		jump_held = false

	# TRIANGLE ground-pound: press Down in mid-air → FREEZE in the duck pose for a
	# moment, then CRASH straight down hard and break bricks below.
	if has_break and not slamming and not on_floor and not was_riding and Input.is_action_just_pressed("move_down"):
		slamming = true
		slam_timer = 0.0
	if slamming:
		slam_timer += delta
		velocity.x = 0.0
		if slam_timer < SLAM_FREEZE:
			velocity.y = 0.0             # hover in the air, tucked into the duck
		else:
			velocity.y = SLAM_SPEED      # then come down hard
	else:
		var g: float
		var fall_cap: float
		if submerged:
			# WATER = a steady sink. No floaty variable-jump rise, no glide/grapple float —
			# the small hop pops once then you drift straight down to the bottom.
			g = main.GRAVITY * WATER_GRAV
			fall_cap = WATER_MAX_FALL
		else:
			# gravity — lighter while rising and holding jump (variable jump height); also
			# scaled by horizontal speed to tune running-jump reach (see _jump_speed_grav_scale)
			g = main.GRAVITY * _jump_speed_grav_scale()
			if velocity.y < 0 and jump_key and not stomp_bounce:
				g *= main.JUMP_HOLD_GRAV       # rising + holding = floaty variable-height ascent
											   # (NOT after a stomp — a stomp bounce is a fixed arc)
			elif velocity.y >= 0.0:
				g *= main.FALL_GRAV_SCALE      # softer descent (SMB1 feel); height-neutral
			fall_cap = main.MAX_FALL
			if fling_t > 0.0:
				g *= FLING_GRAV                # only a SLIGHT gravity ease so the arc carries across
											   # (no feather-fall — it lands naturally, not floaty)
		# NES METROID gravity (overrides the tuned values above, except in water or a grapple fling):
		# one gravity for the whole ground jump, heavier when knocked back, slightly heavier when you
		# simply fall; max fall 5 px/frame. Non-jump upward pops (double/wall jump, recoil, bomb) keep
		# the original rise gravity computed above, so those extras keep their tuned heights.
		if not submerged and fling_t <= 0.0:
			if _hit_arc:
				g = NES_HIT_GRAV
			elif _nes_jump:
				g = NES_JUMP_GRAV
			elif velocity.y >= 0.0:
				g = NES_LEDGE_GRAV
			fall_cap = NES_MAX_FALL
		velocity.y = minf(velocity.y + g * delta, fall_cap)
		# NES variable jump: after rising 32px, letting go of Jump stops the rise instantly.
		if _nes_jump and not _hit_arc and velocity.y < 0.0 and not jump_key \
				and _jump_y0 - global_position.y >= NES_MIN_JUMP:
			velocity.y = 0.0
		# HOVER JETS: hold Jump while falling to drift down gently until the fuel runs out
		if has_hover and jump_key and velocity.y > 0.0 and hover_fuel > 0.0 and not submerged and wall_dir == 0:
			velocity.y = minf(velocity.y, HOVER_FALL)
			hover_fuel = maxf(0.0, hover_fuel - delta)
		if velocity.y >= 0.0:
			stomp_bounce = false           # bounce arc peaked → normal control resumes
		# DIAMOND wall-slide: hugging a wall caps the fall speed
		if wall_dir != 0 and velocity.y > WALL_SLIDE_MAX:
			velocity.y = WALL_SLIDE_MAX

	was_rising = velocity.y < 0
	var pre_vx := velocity.x
	var pre_x := global_position.x
	move_and_slide()
	# a glancing head-bump on a block corner shouldn't shove Mario sideways —
	# if he only clipped a ceiling (no real wall), keep his horizontal motion
	var head_hit := false
	var wall_hit := false
	for i in range(get_slide_collision_count()):
		var n := get_slide_collision(i).get_normal()
		if n.y > 0.3:
			head_hit = true
		if absf(n.x) > 0.7:
			wall_hit = true
	if head_hit and not wall_hit:
		global_position.x = pre_x + pre_vx * delta
		velocity.x = pre_vx
	_handle_head_bump()

	# SMB1 run-over-gaps: only while running fast does a foot still on a block lift Mario
	# back onto the ledge (never while rising/jumping). Slow or stopped → he drops in.
	var fast := absf(velocity.x) > GAP_MIN_SPEED
	var carry_top := _foot_support_top() if (fast or riding) else -INF
	if not is_on_floor() and velocity.y >= 0.0 and carry_top > -INF:
		global_position.y = carry_top - col_size.y / 2.0
		velocity.y = 0.0
	grounded = is_on_floor() or carry_top > -INF

	# Landing-on-a-ledge fix: if Mario dropped slightly INTO the top of a block/pipe (his feet
	# ended up a few px below its top edge), he gets wedged on the corner and can't walk off it.
	# Lift his feet back up onto the block top so he lands on it properly and can move.
	# Only when settling/falling (velocity.y >= 0) — never yank a rising player back down, or a
	# weak jump (e.g. the low underwater hop) gets cancelled the frame it leaves the ledge.
	if grounded and velocity.y >= 0.0:
		var feet2: float = global_position.y + col_size.y / 2.0
		var lift := -INF
		for dx in [-(col_size.x / 2.0 - 1.0), 0.0, col_size.x / 2.0 - 1.0]:
			lift = maxf(lift, _sunk_top(global_position.x + dx, feet2))
		if lift > -INF and feet2 > lift + 0.4:
			global_position.y = lift - col_size.y / 2.0
			velocity.y = 0.0

	# track "pushing into a wall" for the strut animation. Use a real wall at BODY height,
	# NOT is_on_wall() — the latter flickers true on a block CORNER Mario is standing on,
	# which made him "moon-walk" on a ledge edge. A block under his feet no longer counts.
	if dir != 0.0 and _wall_ahead(dir):
		wall_push = 0.12
		if on_floor:
			velocity.x = 0.0     # pinned against a wall on the ground — stop clean, no velocity buzz/jitter
	else:
		wall_push = maxf(0.0, wall_push - delta)

	# fire Mario shoots a fireball on a fresh press of the run/fire button
	# (Z / Shift) — hold to run, tap to fire, like Mario 1's B button
	# (suppressed during the end-credits auto-run so he never fires)
	if fire and Input.is_action_just_pressed("run") and main.game_state != "credits":
		var muzzle := global_position + Vector2(facing * (half_w() + 3.0), -2.0)
		main.spawn_fireball(muzzle, facing)

	if invuln > 0.0:
		invuln -= delta

	# walk animation
	if grounded and wall_push > 0.0 and dir != 0.0:
		# pushing into a wall/obstacle (not actually moving) — slow, steady
		# strut at 0.2s per frame instead of the rapid speed-based cadence
		walk_anim += delta * 5.0
	elif grounded and absf(velocity.x) > 6.0:
		walk_anim += absf(velocity.x) * delta * 0.25
	else:
		walk_anim = 0.0

	_animate()
	# HIT FLASH: while invulnerable after taking a hit, flash the sprite RED (~10 Hz) so the hit
	# reads clearly (stays visible; the red tint pulses on and off).
	if invuln > 0.0:
		sprite.visible = true
		sprite.modulate = Color(2.4, 0.25, 0.25) if int(invuln * 20.0) % 2 == 0 else Color.WHITE
	else:
		sprite.visible = true

	# reached the flagpole? (the pole tiles are solid, so the body stops a hair
	# short of the exact column — trigger a few px early so it always fires).
	# has_flag == false on levels with a custom ending (1-2) — no flagpole win there.
	if main.has_flag and not winning and global_position.x + half_w() >= main.FLAG_X * main.TILE - 6:
		_start_win()

	# LAVA now costs a HEART (not instant death) and knocks Mario back UP out of it — unless he's
	# crossing it on the bike (then it's solid ground). invuln inside hurt() prevents rapid drain.
	if not riding and not dead and invuln <= 0.0 and main.player_in_lava():
		hurt()
		if not dead:
			velocity.y = -220.0            # bounce up out of the lava
			velocity.x = -float(facing) * 120.0   # and shove back the way he came

	# Vania: pits DON'T kill — you fall through into the underground below. Only dying
	# if you drop clear out of the whole painted level (a real bottomless void).
	if global_position.y > main.lvl_bottom + 96.0:
		kill(true)


# 0 at walking pace → 1 at full run, from ACTUAL horizontal speed (momentum), NOT the
# run button — so standing still while holding run gives no jump boost.
func _jump_speed_t() -> float:
	# Sprinting (Z) gives faster GROUND speed but NO extra jump momentum — the launch
	# velocity and jump gravity stay at the walk baseline regardless of how fast you're
	# moving. (Your horizontal velocity still carries into the air on its own; this only
	# removes the SMB-style bonus jump height/air-time.)
	return 0.0


# Jump gravity multiplier from horizontal speed (1.0 at walk → main.JUMP_RUN_GRAV_SCALE at
# full run). Tunes running-jump air-time / horizontal reach independently of jump height.
func _jump_speed_grav_scale() -> float:
	return lerpf(1.0, main.JUMP_RUN_GRAV_SCALE, _jump_speed_t())


# ---- Vania power-up mechanics ----------------------------------------------
func _enter_morph() -> void:
	morphed = true
	ducking = false
	duck_locked = false
	_set_stance(MORPH)
	sprite.texture = _ball_tex
	sprite.position = Vector2(0, -1)   # morph ball sits 1px higher
	sprite.rotation = 0.0
	main.sfx("morph")                  # rolling-up sound (unrolling keeps the bump)


func _exit_morph() -> bool:
	var stand: Vector2 = _stand_size() if (big or fire) else SMALL
	if _blocked_above(stand.y):
		return false                     # no headroom — stay a ball
	morphed = false
	_set_stance(stand)
	sprite.rotation = 0.0
	main.sfx("bump")
	return true


const MORPH_SPEED := 1.0          # NES Metroid: the ball rolls at normal running speed (1.5 px/frame)
var bomb_cd := 0.0               # cooldown before the next morph-ball bomb can be dropped
const BOMB_COOLDOWN := 3.0       # you can place a bomb once every 3 seconds
# SPRING BALL: hop height = 4 TILES (64px), but the motion is 25% SLOWER than a plain 412 pop:
# launch speed x0.75 (412 -> 309) with LIGHTER gravity only while rising (SPRING_RISE_GRAV), so
# the apex stays at 4 tiles. apex ~ v^2/(2*g*k) + v/120 = 64px  ->  k ~= 0.555.
const BALL_JUMP := 309.0
const SPRING_RISE_GRAV := 0.555
var _spring_rising := false      # true from a spring hop until its apex (uses SPRING_RISE_GRAV)
var _ball_bounced := false       # true after a drop's ONE bounce, until the ball settles again
const BALL_BOUNCE_MIN := 100.0   # only bounce when landing faster than this (a real drop, not a step)
const BALL_BOUNCE_FACTOR := 1.0  # bounce keeps this fraction of the impact speed (1.0 = ~2x the old hop)
const BALL_BOUNCE_MAX := 280.0   # cap on the bounce speed
# A morph-ball bomb popped the ball upward — clear the one-shot landing-bounce latch so the ball
# can bounce again next landing (lets you chain bomb-jumps).
func bomb_bounced() -> void:
	_ball_bounced = false
	_nes_jump = false          # a bomb pop is its own arc, not the NES jump (no release cut)


# Fires the SHOT. `charged` = a full CHARGE BEAM blast (power=3, bigger orange bolt).
func _fire_shot(charged: bool) -> void:
	var aim_up := _facing_up()   # only shoot UP when actually FACING up (standing still / jumping) — not while walking
	if aim_up:
		# DIAGONAL: while aiming up, ALSO holding Left/Right fires at a 45° diagonal instead of
		# straight up (Contra/Metroid-style). Reuses the same up-pose art/muzzle — no dedicated
		# diagonal art exists, and the pose reads close enough either way.
		var side := 0
		if Input.is_action_pressed("move_left"): side = -1
		elif Input.is_action_pressed("move_right"): side = 1
		const DIAG := 0.70710678   # sqrt(2)/2, so the diagonal travels at the same speed as straight shots
		var aim_dir: Vector2 = Vector2(float(side) * DIAG, -DIAG) if side != 0 else Vector2(0, -1)
		# fire UP/DIAGONAL: bullet leaves the GUN MUZZLE (the raised barrel sits ~2px to the facing
		# side of centre in the up-pose art), just above the barrel tip; recoil shoves him DOWN a touch
		var muzzle := global_position + Vector2(float(facing) * 2.0, -col_size.y * 0.5 - 4.0)
		boomerangs.append(main.throw_boomerang(muzzle, facing, aim_dir, charged, has_longbeam))
		velocity.y += SHOT_RECOIL_UP * 0.7
		_nes_jump = false          # the recoil pop keeps its floaty arc (not cut by the NES jump release)
	else:
		boomerangs.append(main.throw_boomerang(global_position + Vector2(facing * 8, -4), facing, Vector2(facing, 0), charged, has_longbeam))
		velocity.x -= float(facing) * SHOT_RECOIL   # recoil: shove the shooter back
		# the floaty upward pop is only for firing from the GROUND (or rising) — clamping velocity.y
		# unconditionally used to yank an active FALL upward too, killing your jump's natural drop the
		# instant you fired mid-air. Grounded firing keeps the little responsive hop; airborne firing
		# (rising or falling) now leaves velocity.y completely alone, so you fall/arc as normal.
		if grounded:
			velocity.y = minf(velocity.y, -SHOT_RECOIL_UP)
	main.sfx("shot")                                  # gun shot (own sound; "fireball" stays for enemy/Mario fire)


func _morph_physics(delta: float, on_floor: bool) -> void:
	if boosting:
		_boost_physics(delta)
		return
	# BOMB: while rolled up, the shoot button DROPS a morph-ball bomb (Metroid) — but only once every
	# BOMB_COOLDOWN (6s); the rest of the time the button does nothing in ball mode.
	if has_bombs and bomb_cd <= 0.0 and (Input.is_action_just_pressed("shoot") or Input.is_action_just_pressed("boomerang")):
		main.spawn_bomb(global_position + Vector2(0.0, col_size.y * 0.5 - 3.0))
		bomb_cd = BOMB_COOLDOWN
	# BOOST BALL: hold the RUN button (X on a controller, Z/Shift on keyboard) while
	# rolled up to charge in place — it does NOT launch while held, even once fully
	# charged, it just holds at max charge. RELEASE the button to launch in the
	# direction you're FACING (no need to hold a direction). Releasing before it's
	# fully charged (or leaving the ground) cancels with no launch.
	var run_held := Input.is_action_pressed("run")
	if has_boostball and on_floor and run_held:
		boost_charge = minf(boost_charge + delta, BOOST_CHARGE_TIME)
		_boost_run_held = true
		_boost_charge_physics(delta)
		return
	# own edge-detect for the release (not Input.is_action_just_released — in this
	# project's frame timing that flag can fire a frame after "pressed" already
	# reads false, which is one frame too late once something else has already
	# reset the charge; comparing to our OWN remembered previous state is exact).
	if has_boostball and _boost_run_held and not run_held and boost_charge >= BOOST_CHARGE_TIME:
		boosting = true
		boost_timer = BOOST_TIME
		boost_charge = 0.0
		_boost_run_held = false
		main.sfx("explode")                                # blast-off launch sound
		_boost_physics(delta)
		return
	boost_charge = 0.0
	_boost_run_held = false
	_stop_boost_charge_sfx()        # cut the revving sound if the charge was cancelled early
	sprite.modulate = Color.WHITE   # clear any leftover boost-charge flicker
	var running := Input.is_action_pressed("run") and not has_boostball
	var max_s: float = (main.RUN_MAX if running else main.WALK_MAX) * MORPH_SPEED
	var acc: float = ((main.RUN_ACC if running else main.WALK_ACC) if on_floor else main.AIR_ACC) * MORPH_SPEED
	if submerged or (not on_floor and air_was_submerged and not has_waterwalk):
		# water drags the ball too, same as walking — and the same lingering penalty right
		# after leaving the water without the power-up (skipped entirely with waterwalk)
		max_s *= WATER_MOVE
		acc *= WATER_MOVE
	var dir := 0.0
	if Input.is_action_pressed("move_left"):
		dir = -1.0; facing = -1
	elif Input.is_action_pressed("move_right"):
		dir = 1.0; facing = 1
	if dir != 0.0:
		velocity.x = move_toward(velocity.x, dir * max_s, acc * delta)
	elif on_floor:
		# NES: letting go stops the ball dead, like standing Samus; faster pushes still slide off
		var bfr: float = NES_STOP if absf(velocity.x) <= max_s + 0.5 else main.FRICTION
		velocity.x = move_toward(velocity.x, 0.0, bfr * delta)
	var g: float = main.GRAVITY * (main.FALL_GRAV_SCALE if velocity.y >= 0.0 else (SPRING_RISE_GRAV if _spring_rising else 1.0))
	velocity.y = minf(velocity.y + g * delta, main.MAX_FALL)
	# SPRING BALL: with the power-up, JUMP hops the ball 2 tiles and STAYS rolled up (Up stands up).
	# Without it, Jump or Up both just stand you back up (if there's room); jump_held blocks the
	# held-jump from firing a jump the frame after standing.
	if has_balljump and Input.is_action_just_pressed("jump"):
		if on_floor:
			velocity.y = -BALL_JUMP
			_spring_rising = true           # lighter rise gravity until the apex (slower, same height)
			_ball_bounced = true            # this hop isn't a landing-bounce
			main.sfx("jump")
	elif Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("move_up"):
		if _exit_morph():
			jump_held = true
			return
	var was_air := not is_on_floor()
	var vy_impact := velocity.y                # downward speed at the moment of landing
	move_and_slide()
	# METROID morph-ball bounce: a drop pops back up ONCE, then settles (no repeated bouncing).
	if is_on_floor():
		if was_air and vy_impact > BALL_BOUNCE_MIN and not _ball_bounced:
			velocity.y = -minf(vy_impact * BALL_BOUNCE_FACTOR, BALL_BOUNCE_MAX)
			_ball_bounced = true
			main.sfx("bump")
		elif velocity.y >= -1.0:
			_ball_bounced = false              # settled on the ground → ready for the next drop's bounce
	# roll the ball in the travel direction
	sprite.texture = _ball_tex
	sprite.position = Vector2(0, -1)   # morph ball sits 1px higher
	sprite.rotation += velocity.x * delta * 0.14
	grounded = is_on_floor()


func _dash_physics(delta: float) -> void:
	velocity = Vector2(float(facing) * DASH_SPEED, 0.0)     # flat horizontal lunge, no gravity
	# smash brittle blocks across the WHOLE body height at the column just ahead (tunnel through walls)
	var col := int(floor((global_position.x + float(facing) * (half_w() + 4.0)) / main.TILE))
	var top := int(floor((global_position.y - col_size.y / 2.0 + 2.0) / main.TILE))
	var bot := int(floor((global_position.y + col_size.y / 2.0 - 2.0) / main.TILE))
	for row in range(top, bot + 1):
		main.smash_tile(col, row)
	# blast any enemy we plough through — dash_kill = the flashy spinning cyan vaporize
	for e in main.enemies:
		if is_instance_valid(e) and not e.dead \
				and global_position.distance_to(e.global_position) < 16.0:
			if e.has_method("dash_kill"):
				e.dash_kill(facing)
			elif e.has_method("knock_out"):
				e.knock_out(facing)
			main.sfx("kick")
	move_and_slide()
	_animate()
	_spawn_afterimage(Color(0.4, 0.9, 1.0, 0.55))          # cyan motion-blur ghost trail
	# strobe a bright cyan flash on Mario himself while dashing
	sprite.modulate = Color(1.8, 2.2, 3.0) if int(dash_timer * 40.0) % 2 == 0 else Color(0.6, 1.2, 2.2)
	dash_timer -= delta
	if dash_timer <= 0.0 or is_on_wall():
		dashing = false


# Revs in place while the boost charges up: settle horizontal speed to a stop,
# still fall/land normally, and pulse the ball brighter+faster the closer it gets
# to launching so the charge-up actually reads on screen.
func _stop_boost_charge_sfx() -> void:
	if _boost_charge_sfx != null and is_instance_valid(_boost_charge_sfx):
		_boost_charge_sfx.stop()
		_boost_charge_sfx.queue_free()
	_boost_charge_sfx = null


func _stop_charge_beam_sfx() -> void:
	if _charge_beam_sfx != null and is_instance_valid(_charge_beam_sfx):
		_charge_beam_sfx.stop()
		_charge_beam_sfx.queue_free()
	_charge_beam_sfx = null


func _boost_charge_physics(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, main.FRICTION * delta)
	var g: float = main.GRAVITY * (main.FALL_GRAV_SCALE if velocity.y >= 0.0 else 1.0)
	velocity.y = minf(velocity.y + g * delta, main.MAX_FALL)
	move_and_slide()
	sprite.texture = _ball_tex
	sprite.position = Vector2(0, -1)
	var pct: float = clampf(boost_charge / BOOST_CHARGE_TIME, 0.0, 1.0)
	sprite.rotation += float(facing) * (40.0 + pct * 400.0) * delta   # spins faster as it charges
	var pulse: float = 0.5 + 0.5 * sin(boost_charge * (18.0 + pct * 40.0))   # flicker speeds up near launch
	sprite.modulate = Color(1.0 + pct * 1.5, 1.0 + pct * 1.0, 1.0).lerp(Color.WHITE, 1.0 - pulse)
	grounded = is_on_floor()
	# revving sound: loop it (retrigger when it finishes) for as long as you're still
	# charging; stop it the instant it's fully charged so silence = "ready to release".
	if pct < 1.0:
		if _boost_charge_sfx == null or not is_instance_valid(_boost_charge_sfx) or not _boost_charge_sfx.playing:
			_boost_charge_sfx = main.sfx("sonic_spin")
	else:
		_stop_boost_charge_sfx()


func _boost_physics(delta: float) -> void:
	velocity.x = float(facing) * BOOST_SPEED
	var g: float = main.GRAVITY * (main.FALL_GRAV_SCALE if velocity.y >= 0.0 else 1.0)
	velocity.y = minf(velocity.y + g * delta, main.MAX_FALL)
	# smash brittle blocks across the ball's height at the column just ahead
	var col := int(floor((global_position.x + float(facing) * (half_w() + 4.0)) / main.TILE))
	var top := int(floor((global_position.y - col_size.y / 2.0 + 2.0) / main.TILE))
	var bot := int(floor((global_position.y + col_size.y / 2.0 - 2.0) / main.TILE))
	for row in range(top, bot + 1):
		main.smash_tile(col, row)
	# blast any enemy it ploughs through
	for e in main.enemies:
		if is_instance_valid(e) and not e.dead \
				and global_position.distance_to(e.global_position) < 16.0:
			if e.has_method("dash_kill"):
				e.dash_kill(facing)
			elif e.has_method("knock_out"):
				e.knock_out(facing)
			main.sfx("kick")
	move_and_slide()
	sprite.texture = _ball_tex
	sprite.position = Vector2(0, -1)
	sprite.rotation += velocity.x * delta * 0.22          # spins faster than a normal roll
	sprite.modulate = Color(1.8, 2.2, 3.0) if int(boost_timer * 40.0) % 2 == 0 else Color(0.6, 1.2, 2.2)
	_spawn_afterimage(Color(0.4, 1.0, 0.5, 0.55))          # green motion-blur speed streak
	grounded = is_on_floor()
	boost_timer -= delta
	if boost_timer <= 0.0 or is_on_wall():
		boosting = false
		sprite.modulate = Color.WHITE                      # clear the flash when the boost ends


# RIDER KICK: a diagonal down-forward dive-kick. Smashes enemies + brittle blocks; pops off on impact.
func _riderkick_physics(delta: float) -> void:
	# arc: leap up briefly (KICK_HOP) then accelerate into a steep dive — like a bicycle kick
	velocity.x = float(facing) * KICK_X
	velocity.y = minf(velocity.y + 2600.0 * delta, KICK_Y)
	# smash brittle blocks across the body height at the column ahead, plus the cell below the feet
	var feet := global_position.y + col_size.y / 2.0
	var acol := int(floor((global_position.x + float(facing) * (half_w() + 2.0)) / main.TILE))
	var atop := int(floor((global_position.y - col_size.y / 2.0 + 2.0) / main.TILE))
	var abot := int(floor((feet + 2.0) / main.TILE))
	for row in range(atop, abot + 1):
		main.smash_tile(acol, row)
	main.smash_tile(int(floor(global_position.x / main.TILE)), abot)   # straight down through a floor
	# blast any enemy the kick reaches
	var hit := false
	for e in main.enemies:
		if is_instance_valid(e) and not e.dead and e.has_method("knock_out") \
				and global_position.distance_to(e.global_position) < 18.0:
			e.knock_out(facing)
			main.sfx("kick")
			hit = true
	move_and_slide()
	_animate()
	sprite.rotation += float(facing) * KICK_SPIN * delta   # somersault — the bicycle-kick flip
	_spawn_afterimage(Color(1.0, 0.7, 0.2, 0.6))           # orange kick streak
	sprite.modulate = Color(3.0, 2.2, 0.8) if int(Engine.get_physics_frames()) % 2 == 0 else Color(2.2, 1.4, 0.4)
	# land the kick on a floor / wall / enemy -> pop off and end it
	if is_on_floor() or is_on_wall() or hit:
		riderkicking = false
		velocity = Vector2(float(facing) * 90.0, KICK_BOUNCE)
		air_jump_used = false                              # reward a clean kick with a fresh air-jump
		main.sfx("stomp" if hit else "bump")
		sprite.modulate = Color.WHITE
		sprite.rotation = 0.0                              # land upright

# a fading echo of the current pose, left behind at this position (dash / kick streak)
func _spawn_afterimage(col: Color) -> void:
	var parent := get_parent()
	if parent == null or sprite.texture == null:
		return
	var ghost := Sprite2D.new()
	ghost.texture = sprite.texture
	ghost.flip_h = sprite.flip_h
	ghost.rotation = sprite.global_rotation               # match the spin (bicycle-kick flip)
	ghost.texture_filter = TEXTURE_FILTER_NEAREST
	ghost.z_index = 4                                      # just behind Mario (his sprite is z 5)
	ghost.modulate = col
	parent.add_child(ghost)
	ghost.global_position = sprite.global_position
	var tw := ghost.create_tween()
	tw.tween_property(ghost, "modulate:a", 0.0, 0.22)
	tw.tween_callback(ghost.queue_free)


func _do_slam_break() -> void:
	var feet: float = global_position.y + col_size.y / 2.0
	var hw := half_w()
	var broke := 0
	for dx in [-(hw - 2.0), 0.0, hw - 2.0]:
		var tx := int(floor((global_position.x + dx) / main.TILE))
		var ty := int(floor((feet + 2.0) / main.TILE))
		broke += main.smash_tile(tx, ty)
	if broke > 0:
		velocity.y = 140.0                # punch on through the broken block


# Mario's raised fist in local space (jump pose). X flips with facing so it tracks the hand when
# he turns to face the grab point; the rope hangs from here and the chain ends here.
func _fist_off() -> Vector2:
	return Vector2(float(facing) * FIST_X, FIST_Y)


func _grapple_physics(delta: float) -> void:
	# SUPER METROID-style swing: a rigid pendulum of length rope_len around the grab
	# point. HOLD the grapple button (Y / C) to stay latched and swing — pump with
	# Left/Right — then RELEASE the button to let go and LAUNCH out with your momentum.
	var anchor: Vector2 = grapple_target
	queue_redraw()
	if not (Input.is_action_pressed("grapple") or Input.is_action_pressed("shoot")):
		grappling = false
		# NATURAL PENDULUM RELEASE: let go with your OWN swing momentum, like a real rope. A hard,
		# low swing flings you fast and flat ACROSS a gap; a weak one doesn't. Keep the swing's
		# actual velocity (just cap the extreme + guarantee a small up so you clear the lip). No
		# fixed speed, no big pop = predictable and tied to how you swung, not random.
		velocity.x = clampf(velocity.x, -FLING_MAX, FLING_MAX)
		velocity.y = minf(velocity.y, -60.0)                 # keep upswing momentum; else a small hop up
		fling_t = 0.6                                         # briefly hold the horizontal through the arc
		jump_held = true
		air_jump_used = false
		main.sfx("jump_big" if (big or fire) else "jump_small")
		return
	# pump the swing with left/right, plus gravity
	var swing := 0.0
	if Input.is_action_pressed("move_left"):
		swing -= 1.0; facing = -1
	if Input.is_action_pressed("move_right"):
		swing += 1.0; facing = 1
	velocity.y += SWING_GRAV * delta
	velocity.x += swing * SWING_ACCEL * delta
	if velocity.length() > SWING_MAX:
		velocity = velocity.normalized() * SWING_MAX
	# keep facing the grab point so his raised hand stays pointed at the chain
	if absf(anchor.x - global_position.x) > 2.0:
		facing = 1 if anchor.x > global_position.x else -1
	# REEL: normalise the rope toward ROPE_SET so however far you grabbed from, the swing settles to
	# the same lava-clearing length (reels in if too long, lets out a touch if too short).
	rope_len = move_toward(rope_len, ROPE_SET, REEL_SPEED * delta)
	# integrate, then constrain to the rope (remove the radial part of the velocity). The pendulum
	# hangs from Mario's FIST (his raised hand), not his centre, so the chain end sits on his hand.
	var fist_off := _fist_off()
	var newfist: Vector2 = global_position + fist_off + velocity * delta
	var to: Vector2 = newfist - anchor
	if to.length() > 0.01:
		var radial: Vector2 = to.normalized()
		newfist = anchor + radial * rope_len
		velocity -= radial * velocity.dot(radial)
	global_position = newfist - fist_off
	_animate()


func _draw() -> void:
	# STAR grapple: draw ONLY the user's claw+chain sprite (no procedural line) at the grab point
	# he's latched to. Pick the sheet cell by which SIDE the anchor is on (facing) and its
	# ELEVATION angle (horizontal / ~45 / straight-up), placing the claw head on the anchor.
	if (grappling or extending) and _claw_r.size() == 3:
		var fist_local := _fist_off()
		var fist_world := global_position + fist_local
		# the claw head is at the grab point when latched, or partway out toward it while extending
		# (Bionic-Commando arm shooting out — the chain grows until it reaches the hook)
		var tip_world: Vector2 = grapple_target
		if extending:
			tip_world = fist_world.lerp(extend_target, clampf(extend_time / EXTEND_TIME, 0.0, 1.0))
		var t := to_local(tip_world)
		var real_dist := (fist_local - t).length()                 # ACTUAL fist->head gap this frame
		var d := tip_world - fist_world                             # angle from his raised fist
		var right := d.x >= 0.0
		var elev := clampf(atan2(-d.y, absf(d.x)), 0.0, PI * 0.5)   # 0=horizontal .. PI/2=up
		var bucket := int(round(elev / (PI * 0.5) * 2.0))           # 0=horizontal,1=45,2=vertical
		var tex: Texture2D = (_claw_r[bucket] if right else _claw_l[bucket])
		var tip: Vector2 = (_claw_tip_r[bucket] if right else _claw_tip_l[bucket])
		var dir: Vector2 = (_claw_dir_r[bucket] if right else _claw_dir_l[bucket])
		var sz := tex.get_size()
		# CLIP: the art chain is drawn long; show only from the claw head down to his ACTUAL fist
		# this frame (not the intended rope_len), so the chain always reaches wherever he really is.
		var full_len: float = (sz.length() if (dir.x != 0.0 and dir.y != 0.0) else (sz.x if dir.x != 0.0 else sz.y))
		var f: float = clampf(real_dist / full_len, 0.0, 1.0)
		var sw: float = (sz.x * f) if dir.x != 0.0 else sz.x
		var sh: float = (sz.y * f) if dir.y != 0.0 else sz.y
		var sx: float = 0.0 if dir.x >= 0.0 else sz.x - sw   # tip at the right edge when chain runs left
		var sy: float = 0.0 if dir.y >= 0.0 else sz.y - sh
		var src := Rect2(sx, sy, sw, sh)
		var full_tip := Vector2(tip.x * sz.x, tip.y * sz.y)
		var dest := t - full_tip + src.position                 # keep the claw head on the anchor
		# AIM: the 3 fixed sprites otherwise leave the chain ~20px off his hand mid-swing. Rotate
		# the chosen claw a little around the anchor so its chain points EXACTLY at his fist, then
		# the clipped end lands on the fist at every angle. Small residual = negligible pixel skew.
		var true_dir := fist_local - t                           # anchor -> fist, in local space
		# the sprite's ACTUAL chain vector (tip -> chain end) respects the box aspect ratio — a
		# 77x42 diagonal runs at ~61 deg, not 45. Rotate THAT onto true_dir so the chain aims true.
		var chain_vec := Vector2(dir.x * sz.x, dir.y * sz.y)
		var residual := 0.0
		if true_dir.length() > 0.01:
			residual = wrapf(true_dir.angle() - chain_vec.angle(), -PI, PI)
		draw_set_transform(t, residual, Vector2.ONE)            # rotate around the anchor (the tip)
		draw_texture_rect_region(tex, Rect2(dest - t, src.size), src)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)      # reset

	# HAL 2: placeholder art has no arms/weapon drawn, so his gun is a procedural overlay — a
	# short barrel held out in the facing direction, swinging to point straight up above his head
	# while aiming up (mirrors _facing_up(), the same check the shot code uses for its direction).
	if main.selected_char == "hal2" and not grappling and not extending and not morphed:
		const GUN_COLOR := Color(0.85, 0.15, 0.15)   # bright red — easy to spot against his blue suit
		# FROZEN during the power-up banner: _draw() re-runs every frame regardless of the freeze
		# (queue_redraw() is unconditional, unlike _update_alive which is what actually stops while
		# frozen), so without this the gun kept swinging to match whatever direction keys you were
		# still holding even while the rest of the world was paused. Falls back to the neutral
		# chest-height pose, same as standing still with nothing held.
		var powerup_frozen: bool = main.powerup_freeze_t > 0.0
		if not powerup_frozen and _facing_up():
			# DIAGONAL: holding Left/Right too (see _fire_shot's matching check) swings the barrel to
			# a 45° angle instead of straight up, so the gun visibly points where the shot is actually
			# going. Anchored near the same spot the straight-up barrel starts from, just rotated.
			var side := 0
			if Input.is_action_pressed("move_left"): side = -1
			elif Input.is_action_pressed("move_right"): side = 1
			if side != 0:
				var ang: float = -PI / 4.0 if side > 0 else -3.0 * PI / 4.0   # up-right / up-left
				draw_set_transform(Vector2(0.0, -13.0), ang, Vector2.ONE)
				draw_rect(Rect2(0.0, -1.5, 9.0, 3.0), GUN_COLOR)              # barrel extends outward
				draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)           # reset
			else:
				draw_rect(Rect2(-1.5, -20.0, 3.0, 8.0), GUN_COLOR)     # barrel above the head
		else:
			var gx: float = 6.0 if facing >= 0 else -14.0
			draw_rect(Rect2(gx, -5.0, 8.0, 3.0), GUN_COLOR)        # barrel at chest height

	# CHARGE BEAM: a pulsing muzzle flash at the gun while charging, so it's visible from the
	# instant you start holding the shot button — quickens and brightens as the charge builds,
	# then flips to the "charged" orange (matching the bigger orange bolt _fire_shot fires once
	# CHARGE_TIME is reached) so releasing right then reads as "topped off, let go now".
	if has_chargebeam and charge_t > 0.0 and not grappling and not extending and not morphed:
		var cpct: float = clampf(charge_t / CHARGE_TIME, 0.0, 1.0)
		var muzzle_local: Vector2
		if main.powerup_freeze_t <= 0.0 and _facing_up():
			muzzle_local = Vector2(float(facing) * 2.0, -col_size.y * 0.5 - 4.0)
		else:
			muzzle_local = Vector2(float(facing) * 8.0, -4.0)
		var full_charge: bool = charge_t >= CHARGE_TIME
		var flash_col: Color = Color(1.0, 0.55, 0.15) if full_charge else Color(1.0, 0.95, 0.5)
		var pulse: float = 0.6 + 0.4 * sin(charge_t * (10.0 + cpct * 30.0))   # flicker speeds up near full
		var r: float = (2.0 + cpct * 3.0) * pulse
		draw_circle(muzzle_local, r * 1.8, Color(flash_col.r, flash_col.g, flash_col.b, 0.35 * pulse))
		draw_circle(muzzle_local, r, flash_col)
		var ray_len: float = 3.0 + cpct * 5.0
		for i in 4:
			var ang: float = (PI / 4.0) * float(i) + charge_t * 6.0   # rays slowly spin
			var rp: Vector2 = Vector2(cos(ang), sin(ang)) * ray_len * pulse
			draw_line(muzzle_local, muzzle_local + rp, flash_col, 1.0)


# Copy one claw's box out of the sheet into its own texture, keeping ONLY the largest
# 8-connected opaque blob so a neighbouring claw whose bounding box overlaps this one can't
# bleed stray pixels into the corner. Re-run the CCL box detection if the art is re-saved.
func _extract_claw(sheet: Image, box: Rect2i) -> ImageTexture:
	var sub := Image.create(box.size.x, box.size.y, false, Image.FORMAT_RGBA8)
	for y in box.size.y:
		for x in box.size.x:
			sub.set_pixel(x, y, sheet.get_pixel(box.position.x + x, box.position.y + y))
	var lab := {}
	var best_id := -1
	var best_cnt := 0
	var nid := 0
	for sy in box.size.y:
		for sx in box.size.x:
			var k := Vector2i(sx, sy)
			if sub.get_pixel(sx, sy).a <= 0.3 or lab.has(k):
				continue
			nid += 1
			var cnt := 0
			var stack := [k]
			while stack.size() > 0:
				var p: Vector2i = stack.pop_back()
				if lab.has(p) or p.x < 0 or p.y < 0 or p.x >= box.size.x or p.y >= box.size.y:
					continue
				if sub.get_pixel(p.x, p.y).a <= 0.3:
					continue
				lab[p] = nid
				cnt += 1
				for dy in range(-1, 2):
					for dx in range(-1, 2):
						stack.append(Vector2i(p.x + dx, p.y + dy))
			if cnt > best_cnt:
				best_cnt = cnt
				best_id = nid
	for y in box.size.y:
		for x in box.size.x:
			if lab.get(Vector2i(x, y), -1) != best_id:
				sub.set_pixel(x, y, Color(0, 0, 0, 0))
	return ImageTexture.create_from_image(sub)


func _set_stance(sz: Vector2) -> void:
	# resize the collision (crouch <-> stand) keeping the FEET planted, so ducking lowers
	# the head instead of sinking/popping Mario.
	if col_size == sz:
		return
	var feet: float = global_position.y + col_size.y / 2.0
	_set_col(sz)
	global_position.y = feet - col_size.y / 2.0

func _blocked_above(stand_h: float) -> bool:
	# would standing up to stand_h overlap a solid tile? (can't un-duck under a ceiling)
	if not main or not main.terrain:
		return false
	var feet: float = global_position.y + col_size.y / 2.0
	var top_standing: float = feet - stand_h + 1.0        # where the head would be (1px margin)
	var top_now: float = global_position.y - col_size.y / 2.0
	var hw := half_w()
	var c0 := int(floor((global_position.x - hw) / main.TILE))
	var c1 := int(floor((global_position.x + hw - 0.001) / main.TILE))
	var r0 := int(floor(top_standing / main.TILE))
	var r1 := int(floor((top_now - 0.001) / main.TILE))
	for r in range(r0, r1 + 1):
		for c in range(c0, c1 + 1):
			if main.terrain.get_cell_source_id(Vector2i(c, r)) >= 0:
				var ax: int = main.terrain.get_cell_atlas_coords(Vector2i(c, r)).x
				if ax == main.ATLAS_BLOCK_NORMAL or ax == main.ATLAS_BLOCK_BREAKABLE or ax >= main.WALL_PALETTE_START:
					return true                # BLOKZ blocks ARE a real ceiling
				if ax == main.ATLAS_WATER or ax == main.ATLAS_WATER_TOP \
						or ax == main.ATLAS_LAVA or ax == main.ATLAS_LAVA_TOP \
						or ax >= main.HOOK_TILE_ATLAS or ax == main.GOAL_TILE_ATLAS:
					continue                   # water/lava/hook/power-up/goal aren't a ceiling
				return true
	return false


# Top y of a solid tile at column `px` that Mario has sunk slightly INTO on landing (its top
# sits just above his feet, within SUNK_MAX px) — used to lift him back onto the surface so a
# corner-landing doesn't wedge him. -INF if his feet are cleanly on/above a tile top.
const SUNK_MAX := 8.0
func _sunk_top(px: float, feet_y: float) -> float:
	if not main or not main.terrain:
		return -INF
	var col := int(floor(px / main.TILE))
	var r := int(floor(feet_y / main.TILE))
	var c := Vector2i(col, r)
	if main.terrain.get_cell_source_id(c) >= 0:
		var ax: int = main.terrain.get_cell_atlas_coords(c).x
		var is_water: bool = ax == main.ATLAS_WATER_TOP or ax == main.ATLAS_WATER
		var is_lava: bool = ax == main.ATLAS_LAVA_TOP or ax == main.ATLAS_LAVA
		var is_deco: bool = (ax >= main.HOOK_TILE_ATLAS or ax == main.GOAL_TILE_ATLAS) \
				and ax != main.ATLAS_BLOCK_NORMAL and ax != main.ATLAS_BLOCK_BREAKABLE and ax < main.WALL_PALETTE_START   # hook + power-up + goal: no footing (BLOKZ blocks DO give footing)
		if not is_water and not is_deco and not (is_lava and not riding):
			var top: float = float(r) * main.TILE
			if feet_y > top and feet_y - top <= SUNK_MAX:
				return top
	return -INF

# Is there a real wall in direction `d` (-1/+1)? A solid tile beside Mario at BODY height —
# sampled between just under his head and just above his feet, so the ledge/step he's standing
# ON (a block whose top is at his feet) is never mistaken for a wall.
func _wall_ahead(d: float) -> bool:
	if not main or not main.terrain:
		return false
	var col := int(floor((global_position.x + d * (col_size.x / 2.0 + 1.0)) / main.TILE))
	var top_y: float = global_position.y - col_size.y / 2.0 + 2.0
	var bot_y: float = global_position.y + col_size.y / 2.0 - 3.0    # skip the floor block at the feet
	for r in range(int(floor(top_y / main.TILE)), int(floor(bot_y / main.TILE)) + 1):
		var c := Vector2i(col, r)
		if main.terrain.get_cell_source_id(c) >= 0:
			var ax: int = main.terrain.get_cell_atlas_coords(c).x
			if ax == main.ATLAS_BLOCK_NORMAL or ax == main.ATLAS_BLOCK_BREAKABLE or ax >= main.WALL_PALETTE_START:
				return true                    # BLOKZ blocks ARE a real wall
			if ax != main.ATLAS_LAVA_TOP and ax != main.ATLAS_LAVA \
					and ax != main.ATLAS_WATER_TOP and ax != main.ATLAS_WATER \
					and ax < main.HOOK_TILE_ATLAS and ax != main.GOAL_TILE_ATLAS:
				return true
	return false

func _foot_support_top() -> float:
	# SMB1 two-corner ground check: Mario stays up while his centre OR either foot corner
	# (a full tile apart) is over a solid tile at his feet — so 1-tile gaps never swallow
	# him. Returns the supporting tile's top y, or -INF over open space (a wider gap).
	if not main or not main.terrain:
		return -INF
	var feet_y: float = global_position.y + col_size.y / 2.0
	var best := -INF
	for dx in [-FOOT_SPAN, 0.0, FOOT_SPAN]:
		best = maxf(best, _ground_top_at(global_position.x + dx, feet_y))
	return best

func _ground_top_at(px: float, feet_y: float) -> float:
	# top y of a solid tile directly under px whose top sits within the catch window
	# around the feet ([feet-CARRY_FALL .. feet+6]); -INF if none
	var col := int(floor(px / main.TILE))
	var r0 := int(floor((feet_y - CARRY_FALL) / main.TILE))
	var r1 := int(floor((feet_y + 6.0) / main.TILE))
	for r in range(r0, r1 + 1):
		if main.terrain.get_cell_source_id(Vector2i(col, r)) >= 0:
			var ax: int = main.terrain.get_cell_atlas_coords(Vector2i(col, r)).x
			if ax == main.ATLAS_WATER or ax == main.ATLAS_WATER_TOP:
				continue                       # water gives NO footing — you drop through
			if (ax == main.ATLAS_LAVA or ax == main.ATLAS_LAVA_TOP) and not riding:
				continue                       # lava = no footing... unless you're on the bike
			if (ax >= main.HOOK_TILE_ATLAS or ax == main.GOAL_TILE_ATLAS) \
					and ax != main.ATLAS_BLOCK_NORMAL and ax != main.ATLAS_BLOCK_BREAKABLE and ax < main.WALL_PALETTE_START:
				continue                       # hook + power-up + goal give NO footing (BLOKZ blocks DO)
			var top: float = float(r) * main.TILE
			if top >= feet_y - CARRY_FALL and top <= feet_y + 6.0:
				return top
	return -INF


func _handle_head_bump() -> void:
	if not was_rising:
		return
	# Manual ceiling check by tile — do NOT gate on move_and_slide's collision: the
	# rounded capsule can slip up past a block's corner WITHOUT registering a hit, which
	# let small Mario clip through a solid block. Find the solid tile the head overlaps
	# most (scanning the whole head width so off-centre hits still register on either
	# side, while picking the single best overlap means straddling two never bumps both).
	# nudge up only 1px into the block row: enough to catch a clean stop / a penetration,
	# but LESS than small Mario's ~2px headroom so running UNDER a 1-tile ceiling (where
	# his head sits ~2px below it) does NOT false-trigger a bump.
	var head_y := global_position.y - col_size.y / 2.0 - 1.0
	var row := int(floor(head_y / main.TILE))
	var hw := half_w()
	var left := global_position.x - hw
	var right := global_position.x + hw
	var c0 := int(floor(left / main.TILE))
	var c1 := int(floor((right - 0.001) / main.TILE))
	var best_col := -9999
	var best_overlap := 0.0
	for col in range(c0, c1 + 1):
		if main.terrain.get_cell_source_id(Vector2i(col, row)) < 0:
			continue                                  # only solid tiles are bumpable
		var hax: int = main.terrain.get_cell_atlas_coords(Vector2i(col, row)).x
		if (hax == main.ATLAS_WATER or hax == main.ATLAS_WATER_TOP \
				or hax == main.ATLAS_LAVA or hax == main.ATLAS_LAVA_TOP \
				or hax >= main.HOOK_TILE_ATLAS or hax == main.GOAL_TILE_ATLAS) \
				and hax != main.ATLAS_BLOCK_NORMAL and hax != main.ATLAS_BLOCK_BREAKABLE and hax < main.WALL_PALETTE_START:
			continue                                  # water/lava/hook/power-up icons never bonk the head (BLOKZ blocks do)
		var tile_l: float = col * main.TILE
		var overlap: float = minf(right, tile_l + main.TILE) - maxf(left, tile_l)
		if overlap > best_overlap:
			best_overlap = overlap
			best_col = col
	if best_col == -9999:
		return
	# STOP the rise on any head-bump (SMB1 bonk) — do this the instant a bump is detected,
	# BEFORE bump_block runs. CRITICAL: a brick/?-block bump ERASES its tile for the hop
	# animation, so if we don't halt the rise here a fast jumper sails up through the now-
	# empty space and clips onto the block (small Mario through a 1-tile brick lip).
	if velocity.y < 0.0:
		velocity.y = 0.0
	# if the head had already pushed into the block, shove it back out below.
	var min_center_y: float = float(row + 1) * main.TILE + col_size.y / 2.0
	if global_position.y < min_center_y:
		global_position.y = min_center_y
	main.bump_block(best_col, row)


# =========================================================================
# animation
# =========================================================================
func _apply_frame(t: Texture2D, flip := false) -> void:
	# Most poses use dedicated left/right art (no flip); the single duck frame is
	# mirrored to face the way Mario was already facing.
	sprite.texture = t
	sprite.flip_h = flip
	# split-water tint rides on a shader material, (re)assigned here because this runs every
	# frame (after the water check in _update_alive) and would otherwise be lost; else no material.
	if _water_split and _water_mat:
		_water_mat.set_shader_parameter("water_y", _water_surface_y)
		sprite.material = _water_mat
	else:
		sprite.material = null
	# bottom-align the sprite to the collision box
	sprite.position.y = col_size.y / 2.0 - t.get_height() / 2.0

# TRUE when the player is in the AIM-UP pose (so a shot goes straight up OR diagonal). Needs the
# boomerang power, Up held (not Down), not grappling/ducking. Also holding Left/Right = a DIAGONAL
# shot (see _fire_shot) — that's allowed even while moving that direction, since holding the key IS
# how you ask for a diagonal. Straight-up (no side key) still needs to be airborne OR nearly still,
# so WALKING + Up alone doesn't suddenly shoot up mid-stride. Shared by the shot code and the
# animation so the pose and the shot always agree.
func _facing_up() -> bool:
	if not has_boomerang or grappling or ducking:
		return false
	if not Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down"):
		return false
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		return true
	return not grounded or absf(velocity.x) <= 9.0


func _animate() -> void:
	# SIMPLE 3-frame character (guy, grass): jump in the air, alternate walk1/walk2 while moving,
	# walk1 as the standing/idle frame. Art faces RIGHT → mirror when facing left.
	if _simple_tex.has(main.selected_char):
		var st: Dictionary = _simple_tex[main.selected_char]
		var aiming_up: bool = _facing_up() and st.has("up")   # up pose only when actually facing up
		var gk := "walk1"
		if aiming_up:
			gk = "up"                                # dedicated *_up.png aim-up pose (ground or air)
		elif not grounded or grappling:
			gk = "jump"
		elif absf(velocity.x) > 9.0 or wall_push > 0.0:
			gk = "walk2" if int(walk_anim) % 2 == 1 else "walk1"
		_apply_frame(st.get(gk, st["walk1"]), facing < 0)
		return
	var pre := tier()
	var kf := _pose_key_flip()
	var key: String = pre + kf[0]
	var t: Texture2D = main.tex[key]
	# KAMEN character: swap in the baked head-replaced sprite for this pose, if one exists
	if main.selected_char == "kamen" and _kamen_tex.has(key):
		t = _kamen_tex[key]
	_apply_frame(t, kf[1])

# The current pose as a [suffix, flip] pair, independent of the power tier — so the
# fire-flower flash can recolour whatever pose Mario is frozen in.
func _pose_key_flip() -> Array:
	# only big/fire Mario has a duck sprite — small Mario can't duck (guards against
	# "small_duck" when a duck-shrink leaves `ducking` set as we drop to the small tier)
	if grappling:
		# always the raised-arm jump pose while swinging, so his fist is where the chain attaches
		return ["_jump_r" if facing >= 0 else "_jump_l", false]
	# AIMING UP (or DIAGONAL): raised-arm pose, reads as pointing the gun up/diagonally. Delegates
	# to _facing_up() (shared with the shot code, see its comment) rather than duplicating the
	# condition — a duplicate copy here once drifted out of sync with the diagonal-shot exception.
	if _facing_up() and not ducking:
		return ["_jump_r" if facing >= 0 else "_jump_l", false]
	if ducking and (big or fire):
		# duck art faces left; mirror when facing right so it keeps facing
		return ["_duck", facing > 0]
	elif not grounded:
		return ["_jump_r" if facing >= 0 else "_jump_l", false]
	elif skid_timer > 0.0:
		# sharp-turn frame — art faces left, mirror when sliding right (skid_dir < 0)
		return ["_skid", skid_dir < 0]
	elif absf(velocity.x) > 9.0 or wall_push > 0.0:
		var base := 4 if facing >= 0 else 1   # walk 1-3 face left, 4-6 face right
		return ["_walk%d" % (base + int(walk_anim) % 3), false]
	return ["_stand_r" if facing >= 0 else "_stand_l", false]


# =========================================================================
# growth / damage / death
# =========================================================================
func grow() -> void:
	if big or transforming:
		return
	transforming = true
	transform_to_big = true
	transform_timer = 0.0
	# SMB1 keeps Mario's momentum through the grow freeze (Player_X_Speed untouched) —
	# velocity is inert during the flicker and carries straight through it.
	main.sfx("powerup")

var _fire_pose: Array = ["_stand_r", false]   # pose Mario is frozen in for the flash

func become_fire() -> void:
	# big Mario grabbing a flower gains fire power (no size change). SMB1 freezes him
	# and cycles his palette; we capture his current pose so the flash stays in it.
	if fire or transforming:
		return
	transforming = true
	transform_fire = true
	transform_timer = 0.0
	# momentum carries through the flash too (SMB1 leaves Player_X_Speed alone)
	_fire_pose = _pose_key_flip()
	main.sfx("powerup")

func _shrink() -> void:
	transforming = true
	transform_to_big = false
	transform_timer = 0.0
	# SMB1 has NO knockback on a hit — Mario keeps ALL his momentum. He pauses only for
	# the brief shrink flicker, then resumes moving at the same speed (velocity is left
	# untouched here; it's inert during the flicker and carries straight through it).
	fire = false                 # a hit drops fire power straight back to small
	main.sfx("powerdown")        # plays only on power-down, never when small (that's a kill)

func _update_transform(delta: float) -> void:
	transform_timer += delta
	# fire flower: exact SMB1 palette flash — cycle palette 0..3 every 4 frames while
	# frozen for 63 frames, ending on palette 0 (fire). 0 = fire sprite; 1..3 = the
	# green / gray / brown recolours from fl1.png.
	if transform_fire:
		var pal: int = int(transform_timer / FIRE_STEP) % 4
		var key: String = _fire_pose[0]
		var flip: bool = _fire_pose[1]
		if pal == 0:
			_apply_frame(main.tex["fire" + key], flip)     # real fire-tier pose
		else:
			_apply_frame(main.get_fire_flash(key, pal), flip)   # recoloured big pose
		if transform_timer >= FIRE_TIME:
			fire = true
			transforming = false
			transform_fire = false
			_animate()
		return
	# grow / shrink: exact SMB1 flicker — step every 4th frame through the 10-entry
	# adder table, mapping each SMB1 state onto a GROW.png frame. The step advances at a
	# FIXED 4-frame cadence (SMB1's change-size speed); a short shrink just shows fewer
	# steps at the same speed instead of cramming all 10 into the duration (a fast blur).
	var dur: float = TRANSFORM_TIME if transform_to_big else SHRINK_TIME
	var raw_step: int = int(transform_timer / TRANSFORM_STEP)
	var key: String
	if transform_to_big:
		key = GROW_FRAME[GROW_SEQ[mini(raw_step, 9)]]
	else:
		# keep the small<->big flicker going for the whole (longer) injury freeze instead
		# of holding on the last frame — SHRINK_SEQ alternates, so wrap it
		key = SHRINK_FRAME[SHRINK_SEQ[raw_step % SHRINK_SEQ.size()]]
	_apply_frame(main.tex[key], facing < 0)
	if transform_timer >= dur:
		var feet := global_position.y + col_size.y / 2.0
		if transform_to_big:
			big = true
			_set_col(_stand_size())
		else:
			big = false
			_set_col(SMALL)
			ducking = false          # small Mario can't duck — drop the crouch on shrink
			invuln = 1.5
		global_position.y = feet - col_size.y / 2.0
		transforming = false
		_animate()

func hurt() -> void:
	if invuln > 0.0 or dead or transforming or dashing or riderkicking or boosting:
		return  # dashing / rider-kicking = invulnerable attacks (you kill on contact, take no damage)
	# numeric health: every hit costs HP_PER_HIT (10); at 0 you die. (Fire power is kept until death.)
	hp -= HP_PER_HIT
	if hp <= 0:
		hp = 0
		kill()
		return
	invuln = NES_HURT_INVULN     # NES Metroid: invincible (blinking) for 50 frames after a hit
	# knockback: shoved back the way he's facing with an upward pop; hurt_lock briefly
	# ignores movement input so the shove carries (see the movement input gate).
	velocity.x = -float(facing) * HURT_KNOCK_X
	velocity.y = HURT_KNOCK_UP
	_hit_arc = true              # NES hit gravity ($38) until you land
	_nes_jump = false
	hurt_lock = HURT_LOCK_TIME
	main.sfx("powerdown")

func bounce() -> void:
	velocity.y = main.STOMP_BOUNCE
	stomp_bounce = true      # fixed rebound height — pressing/holding jump can't inflate it
	jump_held = true         # and no fresh jump can fire out of the bounce

func kill(from_pit := false) -> void:
	if dead:
		return
	dead = true
	dead_timer = 0.0
	died_by_pit = from_pit
	death_launched = false
	grappling = false                    # drop the grapple so the claw/chain doesn't stay drawn on death
	extending = false
	queue_redraw()
	set_collision_mask_value(1, false)   # fall through the world
	if not from_pit:
		velocity = Vector2.ZERO               # hold the death pose in place first
		_apply_frame(main.tex["death"])       # front-facing death pose
		_spawn_death_explosion()              # the character bursts apart on death
		sprite.visible = false                # ...hidden, so the explosion replaces the death pose
	# pit deaths keep their downward fall and current frame — no pop-up animation
	main.stop_music_play_death()

# a burst of debris particles at the player's position — the death "explosion"
var _spark_tex: ImageTexture
func _spawn_death_explosion() -> void:
	if _spark_tex == null:
		var img := Image.create(3, 3, false, Image.FORMAT_RGBA8)
		img.fill(Color.WHITE)
		_spark_tex = ImageTexture.create_from_image(img)
	var p := CPUParticles2D.new()
	p.texture = _spark_tex
	p.z_index = 20
	p.one_shot = true
	p.explosiveness = 1.0                     # all at once = a burst, not a stream
	p.amount = 30
	p.lifetime = 0.7
	p.direction = Vector2(0, -1)
	p.spread = 180.0                          # fly out in every direction
	p.initial_velocity_min = 70.0
	p.initial_velocity_max = 190.0
	p.gravity = Vector2(0, 340)
	p.scale_amount_min = 1.0
	p.scale_amount_max = 2.5
	var grad := Gradient.new()
	grad.set_color(0, Color(1.0, 1.0, 0.75, 1.0))     # bright flash
	grad.add_point(0.5, Color(1.0, 0.55, 0.15, 1.0))  # orange
	grad.set_color(1, Color(0.85, 0.12, 0.12, 0.0))   # fade out to red
	p.color_ramp = grad
	var parent := get_parent()
	if parent:
		parent.add_child(p)
		p.global_position = global_position
		p.emitting = true
		p.finished.connect(p.queue_free)      # clean up when the burst ends

# Cutscene walk through a door (Main drives the direction + opens/closes the halves). No input:
# just stroll at walk speed in `door_walk`, keep gravity so he stays on the floor.
const DOOR_STEP_HOP := -235.0   # gentle upward pop (px/s) that carries the player up a 1-tile lip
                                 # smoothly via normal gravity (reaches ~19px, safely over 16px),
                                 # instead of teleporting the position
func _door_walk_physics(delta: float) -> void:
	facing = door_walk
	# STEP-UP ASSIST: this simplified auto-walk has no normal step-climb logic, so a 1-tile
	# floor-height mismatch right at a door threshold (common with the algorithmically-placed real
	# doors on Level29 — the approach floor and the floor under the door itself are often off by
	# exactly one tile) would otherwise wedge the player against the lip and freeze the transition
	# forever. A gentle one-shot hop carries the player up smoothly (no instant teleport-pop, which
	# read as jarring/disorienting mid-transition).
	if not morphed and not _door_step_done:
		var ahead_col: int = int(floor((global_position.x + float(door_walk) * (col_size.x / 2.0 + 2.0)) / main.TILE))
		var foot_row: int = int(floor((global_position.y + col_size.y / 2.0 - 1.0) / main.TILE))
		if main.terrain.get_cell_source_id(Vector2i(ahead_col, foot_row)) >= 0 \
				and main.terrain.get_cell_source_id(Vector2i(ahead_col, foot_row - 1)) < 0 \
				and main.terrain.get_cell_source_id(Vector2i(ahead_col, foot_row - 2)) < 0:
			velocity.y = DOOR_STEP_HOP
			_door_step_done = true
	# EASE into the stroll speed (don't snap from run/walk speed → smooth entry, no jerk).
	# Keep strolling the WHOLE transition (through the camera hold too) — never pause at the door.
	var target_vx: float = float(door_walk) * main.WALK_MAX * DOOR_WALK_SPEED
	velocity.x = move_toward(velocity.x, target_vx, main.WALK_ACC * delta)
	velocity.y = minf(velocity.y + main.GRAVITY * delta, main.MAX_FALL)
	move_and_slide()
	grounded = is_on_floor()
	if morphed:
		# rolled into the door as a ball → stay a rolling ball through the transition
		# (don't pop into the walk animation)
		sprite.texture = _ball_tex
		sprite.position = Vector2(0, -1)
		sprite.rotation += velocity.x * delta * 0.14
	else:
		walk_anim += absf(velocity.x) * delta * 0.25
		_animate()

func _update_dead(delta: float) -> void:
	dead_timer += delta
	# enemy death: show the death pose in place for 0.20s, then launch the pop-up
	if not died_by_pit:
		if dead_timer < 0.20:
			return
		if not death_launched:
			velocity.y = -568                 # pop up ~35px higher than the old -420
			death_launched = true
	# fall at half speed (half gravity + half terminal) once descending
	if velocity.y >= 0.0:
		velocity.y = minf(velocity.y + main.GRAVITY * 0.5 * delta, main.MAX_FALL * 0.5)
	else:
		velocity.y = minf(velocity.y + main.GRAVITY * delta, main.MAX_FALL)
	global_position += velocity * delta
	if dead_timer > (3.6 if not died_by_pit else 3.0):
		set_collision_mask_value(1, true)
		main.saved_tier = "big"     # Vania: always respawn as mushroom (big) Mario — no small tier
		main.reset(true)


# =========================================================================
# flagpole win sequence
# =========================================================================
func _start_win() -> void:
	winning = true
	win_phase = 0
	win_timer = 0.0
	z_index = 2               # walk in front of the castle sprite (fg_renderer z=1)
	global_position.x = main.FLAG_X * main.TILE - half_w()
	velocity = Vector2.ZERO
	main.score += 2000
	main.on_reach_flag()

func _update_win(delta: float) -> void:
	win_timer += delta
	# he stops the instant his feet hit the base block (the brick), on top of it
	var stop_y: float = (main.FLOOR - 1) * main.TILE - col_size.y / 2.0
	if win_phase == 0:
		global_position.y += 130.0 * delta   # the flag lowers on its own (main._update_flag_slide)
		# cling to the pole: alternate the two flagpole-slide frames for this tier
		var f: int = int(win_timer / 0.1) % 2
		_apply_frame(main.tex[tier() + ("_pole2" if f == 1 else "_pole1")])
		# hug the pole (sprite's right edge on the pole), nudged 1px right
		global_position.x = (main.FLAG_X * main.TILE + 8) - sprite.texture.get_width() / 2.0 + 1.0
		if global_position.y >= stop_y:
			global_position.y = stop_y       # STOP the instant he hits the brick
			win_phase = 1
			win_timer = 0.0
	elif win_phase == 1:
		# stopped on the brick, still clinging — wait for the flag to finish landing
		_apply_frame(main.tex[tier() + "_pole1"])
		global_position.x = (main.FLAG_X * main.TILE + 8) - sprite.texture.get_width() / 2.0 + 1.0
		if not main.flag_sliding:
			win_phase = 2               # flag down → flip over to the other side
			win_flip = 0
			facing = -1                 # now on the RIGHT of the pole, facing it
	elif win_phase == 2:
		# flipped to the far (right) side of the pole; hold for 6 frames, then drop off
		_apply_frame(main.tex[tier() + "_pole1"], true)   # mirrored = other side
		global_position.x = (main.FLAG_X * main.TILE + 8) + sprite.texture.get_width() / 2.0 - 1.0
		win_flip += 1
		if win_flip >= WIN_FLIP_HOLD:
			win_phase = 3
			facing = 1
	elif win_phase == 3:
		velocity.x = 84.0
		velocity.y = minf(velocity.y + main.GRAVITY * delta, main.MAX_FALL)
		move_and_slide()
		grounded = is_on_floor()   # _animate() reads this; keep it fresh for the walk cycle
		walk_anim += delta * 12.0
		_animate()
		# walk all the way to the castle doorway, then vanish into it
		if global_position.x >= main.CASTLE_X * main.TILE + 29:
			win_phase = 4
			main.on_enter_castle()
	elif win_phase == 4:
		visible = false

# End of Bowser's castle: after the bridge falls Mario walks across the throne-room
# floor toward mac, stopping RESCUE_STOP_GAP tiles short. Same scripted-walk pattern as
# the flagpole finish (velocity + gravity + move_and_slide + the walk animation).
func _update_rescue_walk(delta: float) -> void:
	facing = 1
	if global_position.x < main.rescue_stop_x:
		velocity.x = 84.0
		velocity.y = minf(velocity.y + main.GRAVITY * delta, main.MAX_FALL)
		move_and_slide()
		grounded = is_on_floor()
	else:
		# arrived — snap to a clean neutral STAND (grounded, no jump/duck/skid air frame)
		velocity = Vector2.ZERO
		global_position.x = main.rescue_stop_x
		grounded = true
		ducking = false
		skid_timer = 0.0
		main.rescue_walking = false          # main advances the rescue phase
	walk_anim += delta * 12.0
	_animate()                               # stand frame on arrival, facing the rescued character
