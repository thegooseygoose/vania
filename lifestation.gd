@tool
extends Area2D
class_name LifeStation
## A health-refill tile (paint EnemyTiles atlas col 39). Walk onto it: it locks your movement in
## place and slowly refills your HP; walking away (or just stepping off) lets you leave early.

const HEAL_RANGE := 14.0
const HEAL_RATE := 20.0        # HP per second while in range

var main                       # set by Main._wire_powerups
var _t := 0.0                  # animation clock
var _active := false           # currently healing? (drives the draw pulse)
var _heal_accum := 0.0         # fractional HP banked between frames (player.hp is an int)
var _fill_sfx: AudioStreamPlayer = null   # looping "filling up" sound while active

func _ready() -> void:
	z_index = 4
	if not Engine.is_editor_hint():
		var cs := CollisionShape2D.new()
		var r := RectangleShape2D.new()
		r.size = Vector2(16, 28)
		cs.shape = r
		add_child(cs)

func _physics_process(delta: float) -> void:
	_t += delta
	_active = false
	if not Engine.is_editor_hint() and main != null and main.player != null:
		var p = main.player
		var d: float = global_position.distance_to(p.global_position)
		# only engages while actually hurt -- at full health it just sits there, no lock/no pull
		if d <= HEAL_RANGE and p.hp < p.MAX_HP:
			_active = true
			p.heal_lock = true          # stand still on the tile while it works
			# p.hp is an int, so banking the fractional heal here (instead of truncating it
			# away every frame) is what lets a sub-1-HP/frame rate actually accumulate.
			_heal_accum += HEAL_RATE * delta
			var whole := int(_heal_accum)
			if whole > 0:
				p.hp = mini(p.MAX_HP, p.hp + whole)
				_heal_accum -= whole
		elif p.heal_lock:
			p.heal_lock = false         # left the tile (or topped off) — free to move again
	if _active:
		if _fill_sfx == null or not is_instance_valid(_fill_sfx) or not _fill_sfx.playing:
			_fill_sfx = main.sfx("sonic_spin")   # looping "filling up" hum, retriggered while active
	else:
		_heal_accum = 0.0
		if _fill_sfx != null and is_instance_valid(_fill_sfx):
			_fill_sfx.stop()
			_fill_sfx.queue_free()
		_fill_sfx = null
	queue_redraw()

func _draw() -> void:
	# a warm "life" pod: dark cabinet + a glowing pulsing cross, cyber-matching the save terminal
	var body := Color(0.16, 0.07, 0.09)
	var edge := Color(1.0, 0.30, 0.42)
	var glow := Color(1.0, 0.55, 0.62)
	# cabinet
	draw_rect(Rect2(-7, -18, 14, 26), body)
	draw_rect(Rect2(-7, -18, 14, 26), edge, false, 1.0)
	# screen backdrop
	draw_rect(Rect2(-5, -15, 10, 9), Color(0.08, 0.03, 0.04))
	# pulsing cross icon (faster/brighter pulse while actively healing)
	var speed: float = 6.0 if _active else 3.0
	var pulse: float = 0.55 + 0.45 * sin(_t * speed)
	var c := Color(glow.r, glow.g, glow.b, pulse)
	draw_rect(Rect2(-1, -14, 2, 7), c)
	draw_rect(Rect2(-4, -11, 8, 2), c)
	# base
	draw_rect(Rect2(-8, 8, 16, 3), body)
	# a soft glow disc under it
	draw_circle(Vector2(0, -10), 12.0, Color(edge.r, edge.g, edge.b, 0.06 * pulse))
