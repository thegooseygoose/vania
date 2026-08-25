extends Node2D
## Thrown boomerang: flies out (decelerating), then curves back to Mario, spinning.
## Knocks out any enemy it touches. Despawns when Mario catches it.

var main
var dir := 1
var t := 0.0
var returning := false
const OUT_TIME := 0.64        # flies out longer → about twice the distance
const SPEED := 420.0


func _ready() -> void:
	z_index = 6


func _physics_process(delta: float) -> void:
	if main == null or not is_instance_valid(main.player):
		queue_free()
		return
	t += delta
	rotation += delta * 22.0
	queue_redraw()
	if not returning:
		var f: float = 1.0 - clampf(t / OUT_TIME, 0.0, 1.0)   # ease to a stop, then return
		global_position.x += dir * SPEED * delta * f
		if t >= OUT_TIME:
			returning = true
	else:
		var to: Vector2 = main.player.global_position - global_position
		if to.length() < 12.0:
			queue_free()                                     # caught
			return
		global_position += to.normalized() * SPEED * delta
	# knock out enemies it passes through
	for e in main.enemies:
		if is_instance_valid(e) and e.has_method("knock_out") and not e.dead:
			if global_position.distance_to(e.global_position) < 14.0:
				e.knock_out(dir)
				main.sfx("kick")
	# hit door switches (only the boomerang can trigger these)
	for s in main.door_switches:
		if is_instance_valid(s) and not s.triggered and global_position.distance_to(s.global_position) < 12.0:
			s.hit()


func _draw() -> void:
	var c := Color(0.3, 0.95, 0.9)
	draw_line(Vector2(-7, 4), Vector2(0, -7), c, 3.0)
	draw_line(Vector2(0, -7), Vector2(7, 4), c, 3.0)
