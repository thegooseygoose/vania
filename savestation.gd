@tool
extends Area2D
class_name SaveStation
## A placeable save point, drawn as a small solid block you actually stand ON TOP of. Get close
## and press UP to save your progress (abilities + position) — dying then respawns you here
## with those abilities. Editor-placeable/movable like the others.

var main                       # set by Main._wire_powerups
var _t := 0.0                  # animation clock
var _near := false             # player is close enough to save — shows the "PRESS UP" prompt
var _flash_t := 0.0            # brief bright flash right after an actual save
var _font: PixelFont

func _ready() -> void:
	z_index = 4
	_font = PixelFont.new()
	if not Engine.is_editor_hint():
		var cs := CollisionShape2D.new()
		var r := RectangleShape2D.new()
		r.size = Vector2(16, 16)
		cs.shape = r
		add_child(cs)
		# a REAL solid body (same technique as the door halves) so the block is something you
		# can physically stand on top of, not just a floor decoration you walk up next to.
		var body := StaticBody2D.new()
		body.collision_layer = 1     # layer 1 = world; the player (mask 1) collides with it
		body.collision_mask = 0
		var bcs := CollisionShape2D.new()
		var br := RectangleShape2D.new()
		br.size = Vector2(16, 16)
		bcs.shape = br
		body.add_child(bcs)
		add_child(body)

func _physics_process(delta: float) -> void:
	_t += delta
	if _flash_t > 0.0:
		_flash_t = maxf(0.0, _flash_t - delta)
	if not Engine.is_editor_hint() and main != null and main.player != null:
		# a box reach (not a circular distance) so this triggers whether you're standing ON TOP
		# of the block (vertical offset ~ half the player's height) or beside it (horizontal
		# offset) — same technique Powerup uses for its own touch check.
		var d: Vector2 = (global_position - main.player.global_position).abs()
		var reach: Vector2 = main.player.col_size / 2.0 + Vector2(10.0, 10.0)
		_near = d.x <= reach.x and d.y <= reach.y
		if _near and Input.is_action_just_pressed("move_up"):
			main.save_checkpoint(global_position)   # snapshot + write the save file
			_flash_t = 0.5
	queue_redraw()

func _draw() -> void:
	# a small solid-looking green data block, flush with the ground — stand by it and press
	# UP to save (same floating-prompt convention as the Bike's "PRESS E / RB")
	var body := Color(0.10, 0.16, 0.12)
	var edge := Color(0.20, 0.85, 0.38)
	var top := Color(0.25, 1.0, 0.45)
	var pulse: float = 1.0 if _flash_t > 0.0 else 0.55 + 0.45 * sin(_t * 3.0)
	# the block itself (16x16 — one tile, so it visually reads as a block you stand on)
	draw_rect(Rect2(-8, -8, 16, 16), body)
	draw_rect(Rect2(-8, -8, 16, 16), edge, false, 1.0)
	# glowing top face + a pulsing status light
	draw_rect(Rect2(-6, -7, 12, 3), Color(top.r, top.g, top.b, pulse))
	draw_circle(Vector2(0, 2), 2.0, Color(top.r, top.g, top.b, pulse))
	# floating "PRESS UP TO SAVE" prompt when close enough — raised well above the block (clears
	# a player standing ON TOP of it, not just one beside it) and flashing to draw the eye
	if _near and _font and fmod(_t, 0.8) < 0.5:
		var label := "PRESS UP TO SAVE"
		var x: float = -_font.text_w(label, 1.0) / 2.0
		_font.draw_text(self, Vector2(x + 1.0, -57.0), label, 1.0, Color(0, 0, 0, 0.75))  # shadow
		_font.draw_text(self, Vector2(x, -58.0), label, 1.0, Color(0.4, 1.0, 0.55))
