@tool
extends Area2D
class_name SaveStation
## A placeable save point. Walk into it to save your progress (abilities + position) —
## dying then respawns you here with those abilities. Editor-placeable/movable like the others.

var main                       # set by Main._wire_powerups
var _saved := false            # already saved this visit? (reset when the player walks away)
var _t := 0.0                  # animation clock

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
	queue_redraw()                                  # pulse the screen glow
	if Engine.is_editor_hint() or main == null or main.player == null:
		return
	var d: float = global_position.distance_to(main.player.global_position)
	if d <= 16.0:
		if not _saved:
			_saved = true
			main.save_checkpoint(global_position)   # snapshot + write the save file
	elif d > 26.0:
		_saved = false                              # walked away — arm again for a re-save

func _draw() -> void:
	# a small green "data terminal": dark cabinet + a glowing screen + a base, cyber-matching the bg
	var body := Color(0.10, 0.16, 0.12)
	var edge := Color(0.20, 0.85, 0.38)
	var screen := Color(0.25, 1.0, 0.45)
	# cabinet
	draw_rect(Rect2(-7, -18, 14, 26), body)
	draw_rect(Rect2(-7, -18, 14, 26), edge, false, 1.0)
	# screen with a pulsing glow
	var pulse: float = 0.55 + 0.45 * sin(_t * 3.0)
	draw_rect(Rect2(-5, -15, 10, 9), Color(0.05, 0.1, 0.07))
	draw_rect(Rect2(-5, -15, 10, 9), Color(screen.r, screen.g, screen.b, pulse))
	# two scanlines on the screen
	draw_line(Vector2(-4, -12), Vector2(4, -12), Color(0.1, 0.3, 0.15, pulse), 1.0)
	draw_line(Vector2(-4, -10), Vector2(2, -10), Color(0.1, 0.3, 0.15, pulse), 1.0)
	# base
	draw_rect(Rect2(-8, 8, 16, 3), body)
	# a soft glow disc under it
	draw_circle(Vector2(0, -10), 12.0, Color(edge.r, edge.g, edge.b, 0.06 * pulse))
