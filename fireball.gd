extends CharacterBody2D
class_name Fireball
## Fire Mario's projectile. Flies forward, bounces along the ground, dies on a
## wall or off-screen. Hitting enemies is resolved in Main.

var main                       # untyped to avoid a cyclic class dependency
var sprite: Sprite2D
var size := Vector2(8, 8)
var dead := false
var burst := false             # died on impact (wall/enemy) -> spawn a 2x burst
var enemy := false             # spat by a purple goomba -> hurts the player, not enemies
var facing := 1                # travel direction (set at launch)
var straight := false          # true = fly HORIZONTALLY (no arc/bounce/gravity) — the virus shot
var life := 2.5
var _anim := 0.0               # spin animation clock
const SPIN_STEP := 4.0 / 60.0  # SMB1: fireball tile changes every 4 frames

const SPEED := 240.0
const BOUNCE := -220.0
const GRAV := 900.0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 1          # collide with the world only
	var rect := RectangleShape2D.new()
	rect.size = size
	var cs := CollisionShape2D.new()
	cs.shape = rect
	add_child(cs)
	sprite = Sprite2D.new()
	sprite.texture_filter = TEXTURE_FILTER_NEAREST
	sprite.z_index = 5
	add_child(sprite)


func get_rect() -> Rect2:
	return Rect2(global_position - size / 2.0, size)


func launch(pos: Vector2, dir: int) -> void:
	global_position = pos
	facing = dir
	sprite.texture = main.tex["fball0"]
	velocity = Vector2(dir * SPEED, 0.0 if straight else 80.0)   # straight = level, else arc down

# Aimed straight shot (no gravity/bounce): flies in a straight line toward `target`. Used by the
# ceiling turret to fire directly AT the player at any angle.
func launch_at(pos: Vector2, target: Vector2) -> void:
	global_position = pos
	straight = true
	var v: Vector2 = (target - pos)
	v = v.normalized() if v.length() > 0.001 else Vector2(1, 0)
	facing = 1 if v.x >= 0.0 else -1
	sprite.texture = main.tex["fball0"]
	velocity = v * SPEED


func _physics_process(delta: float) -> void:
	if main.paused or main.actors_frozen():
		return
	if dead:
		return
	life -= delta
	if not straight:
		velocity.y = minf(velocity.y + GRAV * delta, 400.0)   # arcing shot: gravity + floor bounce
	# (straight shots keep their launch velocity — no gravity — so they fly level or on their aim line)
	move_and_slide()
	if not straight and is_on_floor():
		velocity.y = BOUNCE
	# straight shots die on ANY solid hit (floor/wall/ceiling); arcing shots burst on a wall
	if is_on_wall() or (straight and get_slide_collision_count() > 0):
		dead = true
		burst = true
	# spin: cycle the 4 frames, one every 4 game-frames (SMB1 tile-swap rate)
	_anim += delta
	sprite.texture = main.tex["fball%d" % (int(_anim / SPIN_STEP) % 4)]
	if life <= 0.0 or global_position.x < main.cam_x - 24 or global_position.x > main.cam_x + main.VIEW_W + 24:
		dead = true
