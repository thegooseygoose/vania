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
const SERP_SIZE := Vector2(16, 22)  # taller box (~ the 24px sprite) so landing on it actually stomps

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
	rect.size = SERP_SIZE if kind == "serp" else (KOOPA if kind == "koopa" else GOOMBA)
	dir = -1
	global_position = Vector2(feet_pos.x, feet_pos.y - rect.size.y / 2.0)
	velocity = Vector2(dir * (SERP_SPD if kind == "serp" else main.ENEMY_SPD), 0)


func _physics_process(delta: float) -> void:
	if main.paused or main.intro_12 or main.actors_frozen():
		return
	delta *= main.world_slow        # OVERCLOCK: enemies crawl while the world is slowed (player isn't)
	if not active:
		if global_position.x < main.cam_x + main.VIEW_W + 32:
			active = true
		else:
			return

	if dead:
		dead_timer += delta
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
		if dead_timer > (0.5 if squished else 4.0):
			remove_me = true
		return

	# Zoomer: crawl along the surface (its own movement, no gravity/patrol)
	if kind == "zoomer":
		_zoomer_move(delta)
		return

	# horizontal patrol
	var spd: float = 0.0 if (shell and not shell_moving) else absf(velocity.x)
	if shell and not shell_moving:
		velocity.x = 0.0
	else:
		if kind == "serp":
			spd = SERP_SPD                 # snail crawl — force the very-slow speed every frame
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
	if global_position.y > main.VIEW_H + 40:
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

	if kind == "koopa" and shell:
		_update_shell(delta)

	_animate()


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
		_frame(_t("serp"), dir < 0)   # 1-frame snail; art faces RIGHT, mirror when crawling left
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
	# Zoomers shrug off every generic kill (stomp/dash/rider-kick/fireball/sliding shell all
	# route through knock_out) — ONLY the boomerang kills them (see boomerang_kill).
	if kind == "zoomer":
		return
	_do_knock_out(hit_dir)

# The boomerang's kill — the one thing that takes a zoomer down (works on any enemy).
func boomerang_kill(hit_dir := 1) -> void:
	_do_knock_out(hit_dir)

func _do_knock_out(hit_dir := 1) -> void:
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

# DASH KILL: a flashier death than knock_out — the enemy is rocketed away hard and
# tumbling, glowing cyan, and then vaporizes. The spin/glow/fade run in the dead branch
# of _physics_process (gated on dash_killed).
func dash_kill(hit_dir := 1) -> void:
	if kind == "zoomer":
		return          # the dash can't kill a zoomer — only the boomerang can
	dead = true
	dash_killed = true
	squished = false
	dead_timer = 0.0
	collision_mask = 0
	# a hard, high launch in the dash direction (normal knock_out is only 110,-180)
	velocity = Vector2(hit_dir * 330.0, -250.0)
	_dash_spin = hit_dir * 22.0          # fast tumble
	sprite.modulate = Color(0.6, 1.7, 2.3)   # bright cyan energy glow
