@tool
extends Area2D
class_name Bike
## A placeable rideable bike. Walk into it to hop on; press DOWN to hop off. While
## riding, LAVA becomes safe solid ground you can drive across (player.riding is set,
## and the floor helpers treat lava as footing). Placeable in the editor like the
## power-ups — drop a Bike node and position it. main is set by Main._wire_powerups.

@export var color: Color = Color(0.95, 0.25, 0.2)   # red bike

var main                       # set by Main._wire_powerups at runtime
var ridden := false            # currently carrying the player (mount/dismount via the bike button)
var _near := false             # player is in mount range → show the "PRESS E/RB" prompt
var _font: PixelFont


func _ready() -> void:
	z_index = 4                                     # under Mario (he sits on the seat)
	_font = PixelFont.new()
	if not Engine.is_editor_hint():
		var cs := CollisionShape2D.new()
		var r := RectangleShape2D.new()
		r.size = Vector2(26, 16)
		cs.shape = r
		add_child(cs)


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint() or main == null or main.player == null:
		return
	# mounting is driven by the player pressing the bike button (main.nearest_bike); the
	# bike itself just rides under the player's feet while it's the one being ridden.
	if ridden:
		global_position = main.player.global_position + Vector2(0, main.player.col_size.y * 0.5 - 10.0)
		if _near:
			_near = false
			queue_redraw()
		return
	# show the "PRESS E/RB" prompt when the player is close enough to hop on
	var was_near := _near
	_near = not main.player.riding \
		and main.player.global_position.distance_to(global_position) <= main.player.BIKE_MOUNT_RANGE
	if _near != was_near:
		queue_redraw()


# called by the player when they hop off; the bike stays where it is
func dismount() -> void:
	ridden = false


func _draw() -> void:
	var c := color
	var spoke := Color(1, 1, 1, 0.85)
	# two wheels
	for wx in [-9.0, 9.0]:
		draw_arc(Vector2(wx, 5), 5.5, 0.0, TAU, 18, c, 2.0)
		draw_arc(Vector2(wx, 5), 1.2, 0.0, TAU, 8, spoke, 1.0)
	# frame (triangle) + seat post + handlebars
	draw_line(Vector2(-9, 5), Vector2(0, -3), c, 2.0)
	draw_line(Vector2(0, -3), Vector2(9, 5), c, 2.0)
	draw_line(Vector2(-9, 5), Vector2(9, 5), c, 2.0)
	draw_line(Vector2(0, -3), Vector2(-4, -8), c, 2.0)     # seat
	draw_line(Vector2(9, 5), Vector2(11, -6), c, 2.0)      # fork/handlebar post
	draw_line(Vector2(11, -6), Vector2(7, -8), c, 2.0)     # handlebar
	# floating "PRESS E/RB" prompt when the player is close enough to mount
	if _near and _font:
		var label := "PRESS E / RB"
		var x: float = -_font.text_w(label, 1.0) / 2.0
		_font.draw_text(self, Vector2(x + 1.0, -21.0), label, 1.0, Color(0, 0, 0, 0.75))  # shadow
		_font.draw_text(self, Vector2(x, -22.0), label, 1.0, Color(1.0, 0.9, 0.3))
