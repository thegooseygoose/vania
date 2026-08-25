@tool
extends Area2D
class_name GoalStar
## A placeable level-end star. Touch it → COURSE CLEAR (main.on_enter_castle → fanfare,
## then advance to the next level). Draws a gold star. Placeable/draggable in the editor
## like the bike and power-ups. main is set by Main._wire_powerups.

@export var color: Color = Color(1.0, 0.82, 0.15)   # gold

var main
var done := false


func _ready() -> void:
	z_index = 5
	if not Engine.is_editor_hint():
		var cs := CollisionShape2D.new()
		var r := RectangleShape2D.new()
		r.size = Vector2(18, 18)
		cs.shape = r
		add_child(cs)


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint() or done or main == null or main.player == null:
		return
	if main.game_state != "play":
		return
	var d: Vector2 = (global_position - main.player.global_position).abs()
	var reach: Vector2 = main.player.col_size / 2.0 + Vector2(10, 10)
	if d.x <= reach.x and d.y <= reach.y:
		done = true
		main.on_enter_castle()          # COURSE CLEAR


func _draw() -> void:
	var pts := PackedVector2Array()
	for i in 10:
		var ang := -PI / 2.0 + i * PI / 5.0
		var rad := 9.0 if i % 2 == 0 else 4.0
		pts.append(Vector2(cos(ang) * rad, sin(ang) * rad))
	draw_colored_polygon(pts, color)
	draw_polyline(pts + PackedVector2Array([pts[0]]), Color(0.5, 0.35, 0.0), 1.2)
