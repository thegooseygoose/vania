extends CharacterBody2D
class_name Enemy
## Goomba / Koopa. CharacterBody2D that patrols against the world, reverses at
## walls, and is stomped by the player. Koopas retract into a kickable shell.
## Entity-vs-player/entity resolution lives in Main; this only handles motion.

var main                       # untyped to avoid a cyclic class dependency
var kind := "goomba"
var purple := false            # alt "purple" variant (purpen.png art + special AI)
var ledge_shy := false         # purple koopa: turns at ledges like an SMB1 red koopa
var fire_timer := 0.0          # purple goomba: spits a fireball on this clock
var _flip_t := 999.0           # time since the last direction reversal (wedge detect)
var _flip_streak := 0          # consecutive too-rapid reversals (wedged in a 1-tile gap)
var sprite: Sprite2D
var shape: CollisionShape2D
var rect: RectangleShape2D

var dir := -1
var active := false
var dead := false
var squished := false          # flattened goomba
var shell := false
var shell_moving := false
var dead_timer := 0.0
var remove_me := false
var dash_killed := false        # killed by the DASH: spinning cyan launch that vaporizes (see dash_kill)
var _dash_spin := 0.0           # tumble speed (rad/s) for a dash-killed enemy

# Zoomer (Metroid crawler, kind == "zoomer"): hugs surfaces and wraps around every corner.
var zoom_dir := Vector2i(1, 0)  # travel direction along the surface (grid step)
var zoom_hand := 1              # +1 = surface kept on the clockwise side of travel, -1 = ccw
var zoom_next := Vector2i.ZERO  # the grid cell it is currently crawling toward
var zoom_anim := 0.0            # 2-frame walk-cycle timer
const ZOOM := Vector2(14, 14)   # collision box (fits a 1-tile channel)
const ZOOM_SPEED := 42.0        # crawl speed (px/s)
const SERP_SPD := 10.0          # Serp (snail) patrol speed — VERY slow (normal ENEMY_SPD is 34)
const SERP_SIZE := Vector2(16, 20)  # ~ the 21px sprite so landing on it stomps (no invisible pixels)
const VIRUS_SIZE := Vector2(20, 22) # Virus: goomba-like walker; box ~ its 29x27 sprite (overhangs a touch)
var serp_hp := 3                # Serp takes 3 SHOTS to kill (flashes on each hit)
var virus_hp := 3               # Virus takes 3 SHOTS to kill (flashes on each hit)
var turret_hp := 5              # Ceiling Turret takes 5 SHOTS to kill (flashes on each hit)
const TURRET_SIZE := Vector2(14, 14)   # ceiling gunner: compact box (contact hurts the player)
const TURRET_FIRE := 0.5        # Turret: fires a shot straight AT the player every half second
var melting := false            # Virus death: it MELTS (flatten + spread + sink + fade) instead of flipping off
var melt_t := 0.0
var _melt_base_y := 0.0
const MELT_TIME := 0.7
var _flash_t := 0.0             # brief white flash when hit by a shot

# Bug (flyer, kind == "bug"): rises to the player's head height, then hovers + chases.
const BUG_SIZE := Vector2(12, 12)
const BUG_SPEED := 57.5         # horizontal chase speed once it has risen (was 46 — +25%)
const BUG_RISE := 62.0          # vertical climb / head-height tracking speed
const BUG_BOB_AMP := 3.0        # gentle up/down hover bob (px)
const BUG_BOB_FREQ := 6.0
const BUG_RESPAWN_DELAY := 1.4  # after dying, a bug re-emerges from its origin after this long
var bug_risen := false          # false while still climbing up to head height
var bug_bob_t := 0.0            # flap + bob timer
var bug_spawn_pos := Vector2.ZERO  # where it first appeared (its pipe) — it respawns here

# Metroid boss (flyer, kind == "metroid"): slow menacing float that homes onto the player.
# SHOT-only: immune to stomp/dash/rider-kick; each shot chips 1 off BOSS_HP; contact hurts you.
const METROID_SIZE := Vector2(18, 18)
const METROID_SPEED := 30.0     # slow homing float toward the player
const METROID_BOB := 10.0       # vertical wobble amplitude while drifting
const BOSS_HP := 12             # shots to kill
var boss_hp := BOSS_HP
var metroid_t := 0.0            # pulse + wobble timer

# Brood boss (grounded boss, kind == "brood"): a heavy melee/projectile boss with 3 HP-based
# phases. Uses the SHARED horizontal-patrol/gravity/wall-bounce code (like virus/goomba) rather
# than its own dedicated _xxx_move, then layers phase-based attacks on top of it (see the
# "Brood boss attacks" block in _physics_process). SHOT-only, like the Metroid boss/turret/serp.
const BROOD_SIZE := Vector2(26, 24)
const BROOD_SPEED := 24.0        # slow patrol speed
const BROOD_CHARGE_SPEED := 150.0
const BROOD_CHARGE_WIND := 0.4   # brief telegraph pause before a charge
const BROOD_CHARGE_TIME := 0.9   # how long a charge burst lasts
const BROOD_HP := 32             # shots to kill (charge beam power=3 per hit) -- high enough that
                                  # a player mashing the normal shot (~0.2-0.3s/shot) still spends
                                  # enough time in each phase (32/3 ≈ 11 hp per phase) to see all 3
var brood_hp := BROOD_HP
var brood_fire_t := 0.0
var brood_charge_t := 0.0        # cooldown timer between charges (phase 2+)
var brood_state := "patrol"      # "patrol" | "winding" | "charging"
var brood_state_t := 0.0

# Urchin (spiky floating mine, kind == "urchin"): sits in place, slowly bobbing
# up and down. No patrol, no gravity, no chasing — a stationary contact hazard.
const URCHIN_SIZE := Vector2(16, 16)
const URCHIN_BOB_AMP := 44.0    # how far it drifts above/below its spawn point (px)
const URCHIN_BOB_FREQ := 1.4    # a full sine cycle (up, down, back) takes 2*PI/freq ≈ 4.5s
var urchin_spawn_pos := Vector2.ZERO
var urchin_t := 0.0             # bob + pulse timer

# shell timers
var shell_timer := 0.0         # how long the shell has sat still
var push_timer := 0.0          # how long the shell has slid in the current direction
var shell_cd := 0.0            # brief lockout after a kick/stop so a single overlap can't
                               # oscillate the shell moving<->still under the player's feet
var _was_moving := false
var _prev_dir := -1
var waking := false            # shell about to pop back into a koopa
var wake_timer := 0.0

# block-bump: a koopa knocked from below becomes a normal, kickable shell that's
# just drawn upside-down (belly_up). Same shell physics as a stomped shell.
var belly_up := false

const GOOMBA := Vector2(14, 14)
# KOOPA collision is 14 tall (not the ~24px sprite) so a walking koopa fits under a
# 1-tile (16px) gap with ~2px headroom, SMB1-style — its tall shell/head sprite just
# overhangs the box (same trick as small Mario's 14px box under a 16px ceiling).
const KOOPA := Vector2(14, 14)
const SHELL := Vector2(14, 14)
const FIRE_INTERVAL := 1.0     # purple goomba: seconds between fireball spits
const VIRUS_FIRE_INTERVAL := 0.9   # Virus: spits a projectile at the player fast (every 0.9s)
const WEDGE_WINDOW := 0.1      # reversals closer together than this count as "wedged"
const WEDGE_HITS := 5          # this many rapid reversals -> it's stuck -> drop & die
const WAKE_DELAY := 15.0       # still-shell seconds before it wakes
const WAKE_FLASH := 2.0        # flicker time before the koopa climbs out


func _ready() -> void:
	collision_layer = 4
	collision_mask = 1
	rect = RectangleShape2D.new()
	shape = CollisionShape2D.new()
	shape.shape = rect
	add_child(shape)
	sprite = Sprite2D.new()
	sprite.texture_filter = TEXTURE_FILTER_NEAREST
	sprite.z_index = 4
	add_child(sprite)


func get_rect() -> Rect2:
	return Rect2(global_position - rect.size / 2.0, rect.size)


func spawn(feet_pos: Vector2) -> void:
	if kind == "zoomer":
		rect.size = ZOOM
		# the painted (empty) cell whose bottom edge is feet_pos
		var pc := Vector2i(int(floor(feet_pos.x / main.TILE)), int(floor((feet_pos.y - 1.0) / main.TILE)))
		zoom_hand = 1
		# cling to whichever side has a block: prefer floor, then CEILING, then walls.
		# Paint the zoomer on the empty cell that touches the surface you want it on.
		var w := Vector2i(0, 1)
		for cand in [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)]:
			if _zoom_solid(pc + cand):
				w = cand
				break
		zoom_dir = Vector2i(w.y, -w.x)     # travel along that surface (hand +1)
		zoom_next = pc
		global_position = _zoom_center(pc)
		return
	if kind == "bug":
		rect.size = BUG_SIZE
		dir = -1
		bug_risen = false
		bug_bob_t = 0.0
		global_position = Vector2(feet_pos.x, feet_pos.y - rect.size.y / 2.0)  # sits on the painted cell, then rises
		bug_spawn_pos = global_position   # remember its origin (the pipe) so it can respawn there
		_animate()
		return
	if kind == "metroid":
		rect.size = METROID_SIZE
		dir = -1
		boss_hp = BOSS_HP
		metroid_t = 0.0
		global_position = Vector2(feet_pos.x, feet_pos.y - rect.size.y / 2.0)   # floats from where it's painted
		_animate()
		return
	if kind == "turret":
		rect.size = TURRET_SIZE
		# CLING TO THE CEILING: sprite top flush with the top of the painted cell (hangs down from
		# the block above). Paint the turret tile on the empty cell just below a ceiling block.
		var cell_top: float = feet_pos.y - main.TILE
		global_position = Vector2(feet_pos.x, cell_top + rect.size.y / 2.0)
		_animate()
		return
	if kind == "urchin":
		rect.size = URCHIN_SIZE
		urchin_t = 0.0
		global_position = Vector2(feet_pos.x, feet_pos.y - rect.size.y / 2.0)   # floats where it's painted
		urchin_spawn_pos = global_position   # bobs around this centre point
		_animate()
		return
	if kind == "brood":
		brood_hp = BROOD_HP
		brood_fire_t = 0.0
		brood_charge_t = 0.0
		brood_state = "patrol"
		brood_state_t = 0.0
	rect.size = BROOD_SIZE if kind == "brood" else (VIRUS_SIZE if kind == "virus" else (SERP_SIZE if kind == "serp" else (KOOPA if kind == "koopa" else GOOMBA)))
	dir = -1
	global_position = Vector2(feet_pos.x, feet_pos.y - rect.size.y / 2.0)
	velocity = Vector2(dir * (BROOD_SPEED if kind == "brood" else (SERP_SPD if kind == "serp" else main.ENEMY_SPD)), 0)
	_animate()   # set the initial sprite frame NOW so it's visible in place before it activates
	             # (otherwise it has no texture until it first moves → it "pops in")


func _physics_process(delta: float) -> void:
	if main.paused or main.intro_12 or main.actors_frozen() or main._door_walk_pair != null:
		return   # also frozen for the WHOLE door transition (walk + settle), so enemies in the
		         # room you enter don't move until the camera has finished framing it
	delta *= main.world_slow        # OVERCLOCK: enemies crawl while the world is slowed (player isn't)
	if not active:
		# Serp waits until it's actually ON screen before it starts crawling (no 32px off-screen
		# pre-activation), so it never "appears" already moving — it holds still, then walks once
		# it has entered the view. Other enemies keep the usual small lookahead.
		var appear_margin: float = 0.0 if kind == "serp" else 32.0
		if global_position.x < main.cam_x + main.VIEW_W + appear_margin:
			active = true
		else:
			return

	if dead:
		dead_timer += delta
		if melting:
			# MELT: flatten down, spread wide, sink into the ground, and fade to nothing.
			melt_t += delta
			var pm: float = clampf(melt_t / MELT_TIME, 0.0, 1.0)
			sprite.scale = Vector2(1.0 + pm * 0.5, maxf(0.05, 1.0 - pm))
			sprite.position.y = _melt_base_y + pm * rect.size.y * 0.6
			sprite.modulate = Color(0.55, 0.7, 1.0, 1.0 - clampf((pm - 0.3) / 0.7, 0.0, 1.0))
			if melt_t >= MELT_TIME:
				remove_me = true
			return
		if not squished:
			# small pop peaks ~20px up, then a natural gravity pulls it down while
			# the constant horizontal carries it diagonally off the screen
			velocity.y = minf(velocity.y + main.GRAVITY * 0.4 * delta, main.MAX_FALL)
			global_position += velocity * delta
		if dash_killed:
			# DASH KILL: blasted off spinning, wrapped in a bright cyan energy glow,
			# then vaporizes (fades to nothing) — reads very differently from a normal kill.
			sprite.rotation += _dash_spin * delta
			var f: float = clampf((0.9 - dead_timer) / 0.4, 0.0, 1.0)   # solid, then fade over the last 0.4s
			sprite.modulate = Color(0.6, 1.7, 2.3, f)
			if dead_timer > 0.9:
				remove_me = true
			return
		if kind == "bug":
			# bugs don't get removed — they re-emerge from their origin (the pipe) after a beat
			if dead_timer > BUG_RESPAWN_DELAY:
				_bug_respawn()
			return
		if dead_timer > (0.5 if squished else 4.0):
			remove_me = true
		return

	# Zoomer: crawl along the surface (its own movement, no gravity/patrol)
	if kind == "zoomer":
		_zoomer_move(delta)
		return

	# Bug: fly up to head height, then hover + chase (no gravity/patrol)
	if kind == "bug":
		_bug_move(delta)
		return

	# Metroid boss: slow homing float toward the player (no gravity/patrol)
	if kind == "metroid":
		_metroid_move(delta)
		return

	# Urchin: stays put, slowly bobbing up and down (no gravity/patrol/chasing)
	if kind == "urchin":
		_urchin_move(delta)
		return

	# Turret: clings to the ceiling, never moves; fires a shot straight DOWN every 0.5s.
	if kind == "turret":
		velocity = Vector2.ZERO
		if _on_screen() and is_instance_valid(main.player) and not main.player.dead:
			fire_timer += delta
			if fire_timer >= TURRET_FIRE:
				fire_timer = 0.0
				var muzzle := global_position + Vector2(0.0, rect.size.y * 0.5)   # barrel at its underside
				main.enemy_shoot_at(muzzle, muzzle + Vector2(0.0, 32.0))          # straight down
		_animate()
		if _flash_t > 0.0:
			_flash_t -= delta
			sprite.modulate = Color(3.0, 3.0, 3.0)
		else:
			sprite.modulate = Color.WHITE
		return

	# horizontal patrol
	var spd: float = 0.0 if (shell and not shell_moving) else absf(velocity.x)
	if shell and not shell_moving:
		velocity.x = 0.0
	else:
		if kind == "serp":
			spd = SERP_SPD                 # snail crawl — force the very-slow speed every frame
		elif kind == "brood":
			# winding = braced still (telegraph); charging = full speed toward the player;
			# patrol = slow drift, forced every frame like the serp so it never coasts at old speed
			spd = 0.0 if brood_state == "winding" else (BROOD_CHARGE_SPEED if brood_state == "charging" else BROOD_SPEED)
		elif spd == 0.0:
			spd = 200.0 if shell_moving else main.ENEMY_SPD
		velocity.x = dir * spd

	velocity.y = minf(velocity.y + main.GRAVITY * delta, main.MAX_FALL)
	# OVERCLOCK: move_and_slide() uses the real physics delta, so scale VELOCITY here to actually
	# slow the enemy's movement while time is slowed (velocity.x is re-set from dir*spd next frame).
	velocity *= main.world_slow
	move_and_slide()
	_flip_t += delta
	if is_on_wall():
		if shell and shell_moving:
			# sliding shell bounced off a wall/pipe — one bump sound per real hit
			# (skip while wedged so it doesn't machine-gun the sfx)
			if _flip_t >= WEDGE_WINDOW and main.player.global_position.distance_to(global_position) <= 200.0:
				main.sfx("bump")
			_reverse()
		elif is_on_floor():
			# a walking enemy that ran into a wall/pipe turns around
			_reverse()
		# else: a walking enemy fell into a gap and is wedged mid-air — don't flip,
		# just let it drop.

	# fell into a pit
	if global_position.y > main.lvl_bottom + 40:
		remove_me = true
		return

	# purple koopa (SMB1 red koopa): won't stride off a ledge — turn at the edge
	if ledge_shy and not shell and _at_ledge():
		_reverse()

	# purple goomba: spit a Mario-style fireball toward the player every FIRE_INTERVAL (1s), while on-screen
	if purple and kind == "goomba" and not shell and _on_screen():
		fire_timer += delta
		if fire_timer >= FIRE_INTERVAL:
			fire_timer = 0.0
			var to_player := signi(main.player.global_position.x - global_position.x)
			if to_player == 0:
				to_player = dir
			main.enemy_shoot_fireball(global_position, to_player)

	# Virus: spit a HORIZONTAL projectile toward the player's side, while on-screen
	if kind == "virus" and _on_screen():
		fire_timer += delta
		if fire_timer >= VIRUS_FIRE_INTERVAL:
			fire_timer = 0.0
			var tp := signi(main.player.global_position.x - global_position.x)
			if tp == 0:
				tp = dir
			main.enemy_shoot_fireball(global_position, tp, true)   # true = straight/horizontal

	# Brood boss: 3 HP-based phases layered on top of the shared patrol above.
	#   phase 1 (>66% hp): patrol + a 3-way projectile spread every 2.5s.
	#   phase 2 (33-66%):  also charges the player every 4s (0.4s telegraph, then a 0.9s rush).
	#   phase 3 (<33%):    faster/denser — 5-way spread every 1.5s, charges every 2.5s.
	if kind == "brood" and _on_screen():
		var phase := 1
		if brood_hp <= BROOD_HP * 0.33: phase = 3
		elif brood_hp <= BROOD_HP * 0.66: phase = 2
		match brood_state:
			"patrol":
				brood_fire_t += delta
				var fire_iv: float = 1.5 if phase == 3 else 2.5
				if brood_fire_t >= fire_iv:
					brood_fire_t = 0.0
					var spread: int = 5 if phase == 3 else 3
					var base_dir: Vector2 = (main.player.global_position - global_position).normalized()
					if base_dir == Vector2.ZERO: base_dir = Vector2(dir, 0)
					for i in range(spread):
						var a: float = (float(i) - float(spread - 1) / 2.0) * 0.28
						var d2: Vector2 = base_dir.rotated(a)
						main.enemy_shoot_at(global_position, global_position + d2 * 64.0)
				if phase >= 2:
					brood_charge_t += delta
					var charge_iv: float = 2.5 if phase == 3 else 4.0
					if brood_charge_t >= charge_iv:
						brood_charge_t = 0.0
						brood_state = "winding"
						brood_state_t = 0.0
						main.sfx("sonic_spin")   # revving growl -- telegraphs the charge is coming
			"winding":
				brood_state_t += delta
				if brood_state_t >= BROOD_CHARGE_WIND:
					dir = signi(main.player.global_position.x - global_position.x)
					if dir == 0: dir = 1
					brood_state = "charging"
					brood_state_t = 0.0
			"charging":
				brood_state_t += delta
				if brood_state_t >= BROOD_CHARGE_TIME:
					brood_state = "patrol"
					brood_state_t = 0.0

	if kind == "koopa" and shell:
		_update_shell(delta)

	_animate()
	# white flash when hit by a shot (e.g. serp taking one of its 3 hits)
	if _flash_t > 0.0:
		_flash_t -= delta
		sprite.modulate = Color(3.0, 3.0, 3.0)
	elif kind == "brood" and (brood_state == "winding" or brood_state == "charging"):
		# telegraph the charge attack with a pulsing red glow, on top of the walk animation
		var pulse: float = 1.6 + 0.6 * sin(brood_state_t * 24.0)
		sprite.modulate = Color(pulse, 1.0, 1.0)
	else:
		sprite.modulate = Color.WHITE


# Turn around — but if reversals keep coming faster than WEDGE_WINDOW it's stuck in
# a too-narrow 1-tile gap/perch (walls or ledges on both sides), so after a couple
# of those, stop fighting and drop through to its death instead of jittering.
func _reverse() -> void:
	_flip_streak = _flip_streak + 1 if _flip_t < WEDGE_WINDOW else 0
	_flip_t = 0.0
	if _flip_streak >= WEDGE_HITS:
		_drop_out()
	else:
		dir = -dir

func _drop_out() -> void:
	collision_mask = 0        # let it fall through the world
	shell_moving = false      # settle a buzzing shell so it drops straight
	ledge_shy = false
	_flip_streak = 0


# a downward probe just past the leading foot: no ground there => at a ledge
func _at_ledge() -> bool:
	if not is_on_floor():
		return false
	var foot_y := global_position.y + rect.size.y / 2.0
	var ahead_x := global_position.x + dir * (rect.size.x / 2.0 + 2.0)
	var space := get_world_2d().direct_space_state
	var q := PhysicsRayQueryParameters2D.create(
		Vector2(ahead_x, foot_y - 2.0), Vector2(ahead_x, foot_y + 10.0))
	q.collision_mask = 1
	q.exclude = [self]
	return space.intersect_ray(q).is_empty()


func _on_screen() -> bool:
	return global_position.x > main.cam_x - 16 \
		and global_position.x < main.cam_x + main.VIEW_W + 16


func _update_shell(delta: float) -> void:
	shell_cd = maxf(0.0, shell_cd - delta)
	if shell_moving:
		# restart the slide clock on the kick, and on every direction reversal
		# (bouncing off a wall/pipe), so C1/C3 replay before settling to C2
		if not _was_moving or dir != _prev_dir:
			push_timer = 0.0
		push_timer += delta
		shell_timer = 0.0
		waking = false
	else:
		# sitting still: count toward waking, then flicker, then climb out
		shell_timer += delta
		if shell_timer >= WAKE_DELAY:
			waking = true
			wake_timer += delta
			if wake_timer >= WAKE_FLASH:
				_exit_shell()
	_was_moving = shell_moving
	_prev_dir = dir


func _exit_shell() -> void:
	shell = false
	shell_moving = false
	waking = false
	belly_up = false            # the koopa climbs out the right way up
	shell_timer = 0.0
	wake_timer = 0.0
	var feet := global_position.y + rect.size.y / 2.0
	rect.size = KOOPA
	global_position.y = feet - rect.size.y / 2.0
	velocity.x = dir * main.ENEMY_SPD


func _animate() -> void:
	var t := int(Time.get_ticks_msec())
	sprite.flip_v = belly_up        # block-bumped shells render upside-down
	if kind == "serp":
		# slow 2-frame slither — the body undulates; art faces RIGHT, mirror when crawling left
		_frame(_t("serp2") if (t / 320) % 2 else _t("serp"), dir < 0)
		return
	if kind == "virus":
		# 2-frame walk (front-facing, symmetric — no flip); alternate on a ~150ms clock like the goomba
		_frame(_t("virus1") if (t / 150) % 2 else _t("virus0"), false)
		return
	if kind == "brood":
		# 2-frame lumbering walk, faster alternation while charging; flips toward travel
		var period: int = 90 if brood_state == "charging" else 220
		_frame(_t("brood1") if (t / period) % 2 else _t("brood0"), dir < 0)
		return
	if kind == "bug":
		# 2-frame wing flap; art is symmetric, flip toward travel
		_frame(_t("bug1") if int(bug_bob_t * 12.0) % 2 else _t("bug0"), dir < 0)
		return
	if kind == "turret":
		# 2-frame idle pulse (eye/muzzle glow); symmetric, no flip
		_frame(_t("turret1") if (t / 260) % 2 else _t("turret0"), false)
		return
	if kind == "metroid":
		# 2-frame pulse, drawn CENTRED on the body (not feet-aligned like _frame)
		sprite.flip_v = false
		sprite.flip_h = false
		sprite.position = Vector2.ZERO
		sprite.texture = main.tex["metroid1"] if int(metroid_t * 3.0) % 2 else main.tex["metroid0"]
		return
	if kind == "urchin":
		# 2-frame slow pulse, drawn CENTRED on the body (not feet-aligned like _frame)
		sprite.flip_v = false
		sprite.flip_h = false
		sprite.position = Vector2.ZERO
		sprite.texture = main.tex["urchin1"] if int(urchin_t * 2.0) % 2 else main.tex["urchin0"]
		return
	if kind == "goomba":
		if squished:
			_frame(_t("goomba_flat"), false)
		else:
			_frame(_t("goomba2") if (t / 150) % 2 else _t("goomba1"), false)
		return

	# koopa
	if shell:
		if shell_moving:
			# first 0.25s of a (re)start shows the directional frame — C1 moving
			# right, C3 moving left — then it settles into C2 until it reverses.
			if push_timer < 0.25:
				_frame(_t("shell_right1") if dir >= 0 else _t("shell_left"), false)
			else:
				_frame(_t("shell_right2"), false)
		elif waking:
			# flicker between the shell and the wake pose as a warning
			_frame(_t("shell_wake") if (t / 120) % 2 else _t("koopa_shell"), false)
		else:
			_frame(_t("koopa_shell"), false)
		return

	# walking koopa — art faces LEFT, so mirror only when moving right
	var kf: Texture2D = _t("koopa2") if (t / 180) % 2 else _t("koopa1")
	_frame(kf, dir > 0)

# purple variants swap to the "p"-prefixed texture of the same pose
func _t(base: String) -> Texture2D:
	if purple:
		var pk := "p" + base
		if main.tex.has(pk):
			return main.tex[pk]
	return main.tex[base]

func _frame(tx: Texture2D, flip: bool) -> void:
	sprite.texture = tx
	sprite.flip_h = flip
	sprite.position.y = rect.size.y / 2.0 - tx.get_height() / 2.0


# =========================================================================
# stomp / kick results (called from Main)
# =========================================================================
func squish() -> void:
	if kind == "zoomer":
		return          # a zoomer can't be flattened — only the boomerang kills it
	squished = true
	dead = true
	dead_timer = 0.0
	velocity = Vector2.ZERO
	# shrink hitbox so it reads as flattened
	var feet := global_position.y + rect.size.y / 2.0
	rect.size = Vector2(14, 8)
	global_position.y = feet - rect.size.y / 2.0
	_frame(_t("goomba_flat"), false)

func to_shell() -> void:
	shell = true
	shell_moving = false
	shell_timer = 0.0
	push_timer = 0.0
	shell_cd = 0.1            # freshly made shell can't be insta-kicked while the stomp
	                          # that created it still overlaps the player
	wake_timer = 0.0
	waking = false
	_was_moving = false
	velocity.x = 0
	var feet := global_position.y + rect.size.y / 2.0
	rect.size = SHELL
	global_position.y = feet - rect.size.y / 2.0
	_frame(_t("koopa_shell"), false)

func flip_stun() -> void:
	# a block bumped from below knocks the koopa into an UPSIDE-DOWN shell — but it's
	# a normal, fully kickable shell (same physics as a stomped one), just drawn
	# belly-up. Left alone it wakes like any shell. (Goombas etc. just die.)
	if kind != "koopa" or dead:
		return
	to_shell()               # normal still shell (resize + reposition + timers)
	belly_up = true          # ...only difference: rendered upside-down
	sprite.flip_v = true
	velocity.y = -120.0      # small hop so the flip reads as being knocked up

func knock_out(hit_dir := 1) -> void:
	# Zoomers AND the Metroid boss shrug off every generic kill (stomp/dash/rider-kick/fireball/
	# sliding shell all route through knock_out) — ONLY the boomerang/SHOT hurts them (boomerang_kill).
	if kind == "zoomer" or kind == "metroid" or kind == "turret" or kind == "brood":
		return
	_do_knock_out(hit_dir)

# The boomerang/SHOT's kill — the one thing that takes a zoomer down (works on any enemy).
# `power` is how many normal shots this hit is worth (CHARGE BEAM fires a power=3 blast).
func boomerang_kill(hit_dir := 1, power := 1) -> void:
	if kind == "serp":
		# Serp is tough: 3 shots to kill, flashing white on each hit
		serp_hp -= power
		_flash_t = 0.18
		if serp_hp <= 0:
			_do_knock_out(hit_dir)
		return
	if kind == "metroid":
		# the Metroid boss: BOSS_HP shots to kill, flashing on each hit
		boss_hp -= power
		_flash_t = 0.16
		if boss_hp <= 0:
			_do_knock_out(hit_dir)
		return
	if kind == "virus":
		# Virus is tough: 10 shots to kill, flashing white on each hit
		virus_hp -= power
		_flash_t = 0.18
		if virus_hp <= 0:
			_do_knock_out(hit_dir)
		return
	if kind == "turret":
		# Ceiling Turret: 5 shots to kill, flashing white on each hit
		turret_hp -= power
		_flash_t = 0.16
		if turret_hp <= 0:
			_do_knock_out(hit_dir)
		return
	if kind == "brood":
		# Brood boss: BROOD_HP shots to kill, flashing on each hit (see phase logic in _physics_process)
		brood_hp -= power
		_flash_t = 0.16
		if brood_hp <= 0:
			_do_knock_out(hit_dir)
		return
	_do_knock_out(hit_dir)

func _do_knock_out(hit_dir := 1) -> void:
	# Virus: it MELTS in place (flatten + spread + sink + fade) instead of flipping off.
	if kind == "virus":
		dead = true
		melting = true
		melt_t = 0.0
		squished = false
		dead_timer = 0.0
		collision_mask = 0
		velocity = Vector2.ZERO
		_melt_base_y = sprite.position.y
		return
	# Zoomer, Serp, Metroid boss, Turret, Urchin & Brood: they EXPLODE instead of flipping off — a pixel-art burst, then gone.
	if kind == "zoomer" or kind == "serp" or kind == "metroid" or kind == "turret" or kind == "urchin" or kind == "brood":
		_spawn_explosion()
		dead = true
		squished = false
		dead_timer = 0.0
		collision_mask = 0
		sprite.visible = false
		remove_me = true
		return
	dead = true
	squished = false
	dead_timer = 0.0
	collision_mask = 0
	# small pop (~20px up, ~20px over) then it keeps drifting in the knock
	# direction and falls off the screen diagonally
	velocity = Vector2(hit_dir * 110.0, -180.0)
	# koopas flip to an upside-down shell; goombas just flip over
	if kind == "koopa":
		_frame(_t("koopa_shell"), false)
	sprite.flip_v = true
	sprite.rotation = 0.0        # a dying zoomer drops its surface-hugging tilt so the flip reads right

# A chunky PIXEL-ART explosion at the enemy's position (used when a zoomer is killed).
const ExplosionFX := preload("res://explosion.gd")
func _spawn_explosion() -> void:
	var parent := get_parent()
	if parent == null:
		return
	var fx := ExplosionFX.new()
	parent.add_child(fx)
	fx.global_position = global_position
	if main:
		main.sfx("explode")

# =========================================================================
# Zoomer movement — a boundary (wall) follower: it keeps the surface on one
# side and walks the outline of the solid terrain, wrapping cleanly around
# both convex and concave corners (Metroid's Zoomer / Geemer).
# =========================================================================
func _zoom_cell() -> Vector2i:
	return Vector2i(int(floor(global_position.x / main.TILE)), int(floor(global_position.y / main.TILE)))

func _zoom_center(c: Vector2i) -> Vector2:
	return Vector2(c.x * main.TILE + main.TILE / 2.0, c.y * main.TILE + main.TILE / 2.0)

# rotate a grid step 90° in the hug handedness (+1 = clockwise on screen, y-down)
func _zoom_rot(v: Vector2i) -> Vector2i:
	return Vector2i(-v.y, v.x) if zoom_hand >= 0 else Vector2i(v.y, -v.x)

func _zoom_solid(c: Vector2i) -> bool:
	var src: int = main.terrain.get_cell_source_id(c)
	if src < 0:
		return false
	var ax: int = main.terrain.get_cell_atlas_coords(c).x
	if ax == main.ATLAS_BLOCK_NORMAL or ax == main.ATLAS_BLOCK_BREAKABLE or ax >= main.WALL_PALETTE_START:
		return true                                      # BLOKZ blocks ARE real terrain to hug
	# don't cling to water / lava / hook / painted-special tiles — only real terrain
	if ax >= main.ATLAS_WATER_TOP:                       # 45+ = water, hook, powerups, goal
		return false
	if ax == main.ATLAS_LAVA or ax == main.ATLAS_LAVA_TOP:
		return false
	return true

# reached zoom_next: pick the next cell, wrapping around corners so the surface
# stays on the hug side (zoom_dir rotated by handedness).
func _zoom_advance() -> void:
	var cell := zoom_next
	var wall := _zoom_rot(zoom_dir)          # the side the surface is on
	if not _zoom_solid(cell + wall):
		zoom_dir = wall                       # convex corner: curl toward the surface
	elif _zoom_solid(cell + zoom_dir):
		zoom_dir = -_zoom_rot(zoom_dir)       # concave corner: turn away from the surface
	zoom_next = cell + zoom_dir

func _zoomer_move(delta: float) -> void:
	zoom_anim += delta
	var target := _zoom_center(zoom_next)
	var to := target - global_position
	var step := ZOOM_SPEED * delta
	if to.length() <= step:
		global_position = target
		_zoom_advance()                       # arrived: choose the next cell
	else:
		global_position += to.normalized() * step
	# animate: alternate the two frames, and tilt so "up" points away from the surface
	sprite.flip_v = false
	sprite.flip_h = false
	sprite.position = Vector2.ZERO
	sprite.texture = main.tex["zoomer1"] if int(zoom_anim * 8.0) % 2 == 1 else main.tex["zoomer0"]
	var up := -Vector2(_zoom_rot(zoom_dir))   # away from the surface
	sprite.rotation = up.angle() + PI / 2.0

# Bug (flyer): climb straight up until it reaches the player's head height, then hover at that
# height and chase the player horizontally with a gentle bob. No gravity, no terrain collision.
func _bug_move(delta: float) -> void:
	bug_bob_t += delta
	var p = main.player
	if p == null or not is_instance_valid(p):
		return
	# "head height" = just above the top of the player's body
	var head_y: float = p.global_position.y - p.col_size.y * 0.5 - 3.0
	if not bug_risen:
		global_position.y -= BUG_RISE * delta         # climb up out of the pipe
		if global_position.y <= head_y:
			global_position.y = head_y
			bug_risen = true
	else:
		# home toward the player horizontally, and track head height with a hover bob
		dir = 1 if p.global_position.x >= global_position.x else -1
		global_position.x = move_toward(global_position.x, p.global_position.x, BUG_SPEED * delta)
		var target_y: float = head_y + sin(bug_bob_t * BUG_BOB_FREQ) * BUG_BOB_AMP
		global_position.y = move_toward(global_position.y, target_y, BUG_RISE * delta)
	velocity = Vector2.ZERO
	_animate()

# re-emerge from the origin (pipe): reset to a fresh, un-risen bug at its spawn point
func _bug_respawn() -> void:
	dead = false
	dash_killed = false
	squished = false
	dead_timer = 0.0
	collision_mask = 1
	bug_risen = false
	bug_bob_t = 0.0
	velocity = Vector2.ZERO
	sprite.flip_v = false
	sprite.rotation = 0.0
	sprite.modulate = Color.WHITE
	global_position = bug_spawn_pos
	active = true
	_animate()

# Metroid boss: a slow, menacing homing float toward the player with a vertical wobble.
# No gravity, no terrain collision. Only the SHOT hurts it; contact hurts the player.
func _metroid_move(delta: float) -> void:
	metroid_t += delta
	var p = main.player
	if p == null or not is_instance_valid(p):
		return
	var to: Vector2 = p.global_position - global_position
	if to.length() > 1.0:
		global_position += to.normalized() * METROID_SPEED * delta
	global_position.y += sin(metroid_t * 2.4) * METROID_BOB * delta    # eerie drifting wobble
	dir = 1 if to.x >= 0.0 else -1
	velocity = Vector2.ZERO
	_animate()
	# white flash briefly after each shot lands
	if _flash_t > 0.0:
		_flash_t -= delta
		sprite.modulate = Color(2.2, 2.2, 2.2)
	else:
		sprite.modulate = Color.WHITE

# Urchin (spiky mine): holds its spawn position and drifts slowly up and down
# on a sine wave. No gravity, no terrain collision, no chasing — a pure
# stationary hazard (contact hurts the player; any weapon kills it in one hit).
func _urchin_move(delta: float) -> void:
	urchin_t += delta
	global_position.y = urchin_spawn_pos.y + sin(urchin_t * URCHIN_BOB_FREQ) * URCHIN_BOB_AMP
	velocity = Vector2.ZERO
	_animate()

# DASH KILL: a flashier death than knock_out — the enemy is rocketed away hard and
# tumbling, glowing cyan, and then vaporizes. The spin/glow/fade run in the dead branch
# of _physics_process (gated on dash_killed).
func dash_kill(hit_dir := 1) -> void:
	if kind == "zoomer" or kind == "metroid":
		return          # the dash can't kill a zoomer or the Metroid boss — only the shot can
	if kind == "virus":
		_do_knock_out(hit_dir)   # virus melts (not the cyan spin) however it dies
		return
	dead = true
	dash_killed = true
	squished = false
	dead_timer = 0.0
	collision_mask = 0
	# a hard, high launch in the dash direction (normal knock_out is only 110,-180)
	velocity = Vector2(hit_dir * 330.0, -250.0)
	_dash_spin = hit_dir * 22.0          # fast tumble
	sprite.modulate = Color(0.6, 1.7, 2.3)   # bright cyan energy glow
