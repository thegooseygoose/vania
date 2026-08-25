extends Node2D
## Everything the player can touch: coins, the save crystal, ability orbs, the
## health-up, and the goal star. Bobs / pulses and reacts on overlap.

var world
var kind := "coin"
var cell := Vector2i.ZERO
var taken := false
var t := 0.0

const COLORS := {
	"double_jump": Color(0.3, 0.9, 1.0),
	"dash": Color(1.0, 0.7, 0.2),
	"wall_jump": Color(0.4, 1.0, 0.5),
	"fireball": Color(1.0, 0.35, 0.3),
}


func _ready() -> void:
	z_index = 3
	set_process(true)
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	t += delta
	queue_redraw()
	if taken:
		return
	var p = world.player
	if p == null:
		return
	var r := 12.0
	if kind == "coin":
		r = 11.0
	if global_position.distance_to(p.global_position) <= r:
		_collect()


func _collect() -> void:
	match kind:
		"coin":
			taken = true
			world.add_coin()
			world.sfx("coin")
			queue_free()
		"health":
			taken = true
			world.grant_health()
			world.sfx("powerup")
			queue_free()
		"checkpoint":
			# activate this crystal as the respawn point (stays in the world)
			if world.checkpoint != _feet():
				world.set_checkpoint(_feet())
		"goal":
			taken = true
			world.win()
			world.sfx("powerup")
		_:
			taken = true
			world.grant_ability(kind)
			world.sfx("powerup")
			queue_free()


func _feet() -> Vector2:
	return Vector2((cell.x + 0.5) * 16.0, (cell.y + 1) * 16.0)


func _draw() -> void:
	match kind:
		"coin": _draw_coin()
		"health": _draw_tex("mushroom", 1.0)
		"fireball": _draw_orb(COLORS["fireball"], "flower")
		"double_jump": _draw_orb(COLORS["double_jump"], "")
		"dash": _draw_orb(COLORS["dash"], "")
		"wall_jump": _draw_orb(COLORS["wall_jump"], "")
		"checkpoint": _draw_crystal()
		"goal": _draw_star()


func _bob() -> float:
	return sin(t * 3.0) * 2.0


func _draw_tex(key: String, sc: float) -> void:
	if not world.tex.has(key):
		return
	var tx: Texture2D = world.tex[key]
	var s := Vector2(tx.get_width(), tx.get_height()) * sc
	var pos := Vector2(-s.x / 2.0, -s.y / 2.0 + _bob())
	draw_texture_rect(tx, Rect2(pos, s), false)


func _draw_coin() -> void:
	var y := _bob()
	if world.tex.has("coin"):
		var f := int(world.qanim / 0.12) % 3
		var src := Rect2(f * 16, 0, 16, 16)
		draw_texture_rect_region(world.tex["coin"], Rect2(-6, -8 + y, 12, 16), src)
	else:
		draw_circle(Vector2(0, y), 5, Color(1, 0.85, 0.2))


func _draw_orb(col: Color, inner_tex: String) -> void:
	var y := _bob()
	var pulse := 0.5 + 0.5 * sin(t * 5.0)
	# glow ring
	draw_circle(Vector2(0, y), 10.0 + pulse * 2.0, Color(col.r, col.g, col.b, 0.18))
	draw_circle(Vector2(0, y), 7.0, Color(col.r, col.g, col.b, 0.9))
	draw_circle(Vector2(0, y), 4.0, Color(1, 1, 1, 0.85))
	if inner_tex != "" and world.tex.has(inner_tex):
		var tx: Texture2D = world.tex[inner_tex]
		draw_texture_rect(tx, Rect2(-7, -7 + y, 14, 14), false)


func _draw_crystal() -> void:
	var y := _bob()
	var active: bool = world.checkpoint == _feet()
	var col := Color(0.5, 1.0, 0.8) if active else Color(0.35, 0.55, 0.6)
	var glow := 0.5 + 0.5 * sin(t * 4.0)
	if active:
		draw_circle(Vector2(0, y), 12.0, Color(0.4, 1.0, 0.7, 0.12 + glow * 0.12))
	var pts := PackedVector2Array([Vector2(0, -9 + y), Vector2(6, y), Vector2(0, 9 + y), Vector2(-6, y)])
	draw_colored_polygon(pts, col)
	draw_polyline(pts + PackedVector2Array([pts[0]]), Color(1, 1, 1, 0.8), 1.0)


func _draw_star() -> void:
	var y := _bob()
	var pulse := 0.5 + 0.5 * sin(t * 4.0)
	draw_circle(Vector2(0, y), 16.0 + pulse * 4.0, Color(1.0, 0.9, 0.3, 0.14))
	var pts := PackedVector2Array()
	for i in 10:
		var ang := -PI / 2.0 + i * PI / 5.0
		var rad := 10.0 if i % 2 == 0 else 4.5
		pts.append(Vector2(cos(ang) * rad, sin(ang) * rad + y))
	draw_colored_polygon(pts, Color(1.0, 0.87, 0.25))
	draw_polyline(pts + PackedVector2Array([pts[0]]), Color(1, 1, 1, 0.9), 1.0)

