@tool
extends Area2D
class_name Powerup
## A placeable power-up. Three shapes for now (rectangle / square / circle) with
## NO behaviour yet — they just sit in the level and draw themselves so you can
## position them in the editor. Behaviour gets added later per your instructions.
## It's an Area2D so it can sense the player once we wire up what each one does.

@export_enum("triangle", "square", "circle", "diamond", "star", "boomerang", "waterwalk", "dash", "riderkick", "timeslow", "hover") var shape: String = "square":
	set(v):
		shape = v
		queue_redraw()

## Optional tint override; leave default to use the per-shape colour.
@export var color: Color = Color(0, 0, 0, 0):
	set(v):
		color = v
		queue_redraw()

const COLORS := {
	"triangle": Color(1.0, 0.6, 0.2),    # orange
	"square": Color(0.4, 0.9, 0.5),      # green
	"circle": Color(0.4, 0.7, 1.0),      # blue
	"diamond": Color(1.0, 0.9, 0.25),    # yellow  (wall jump)
	"star": Color(1.0, 0.35, 0.8),       # magenta (grapple beam)
	"boomerang": Color(0.3, 0.95, 0.9),  # cyan    (boomerang)
	"waterwalk": Color(0.35, 0.7, 1.0),  # water blue (walk on water)
	"dash": Color(1.0, 0.85, 0.2),       # yellow (dash attack)
	"riderkick": Color(0.9, 0.25, 0.2),  # red (rider kick)
	"timeslow": Color(0.3, 0.55, 1.0),   # blue (overclock / time slow)
	"hover": Color(0.7, 0.8, 0.9),       # light steel (hover jets)
}


func _ready() -> void:
	z_index = 5
	if not Engine.is_editor_hint():
		# a matching collision sensor, ready for whatever behaviour we add later
		var cs := CollisionShape2D.new()
		if shape == "circle":
			var c := CircleShape2D.new()
			c.radius = 8.0
			cs.shape = c
		else:
			var r := RectangleShape2D.new()
			r.size = _dims()
			cs.shape = r
		add_child(cs)


var main                      # set by Main._wire_powerups at runtime
var collected := false

# the "power icon" art (green B badge) drawn for the morph pickup, loaded once
static var _icon: Texture2D
func _icon_tex() -> Texture2D:
	if _icon == null:
		_icon = load("res://sprites/v sprites/ball.png") as Texture2D
	return _icon


func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint() or collected or main == null or main.player == null:
		return
	# overlap test against the player's whole body (not centre distance) so a big
	# Mario settling on the ground still reliably grabs it
	var d: Vector2 = (global_position - main.player.global_position).abs()
	var reach: Vector2 = main.player.col_size / 2.0 + Vector2(10, 10)
	if d.x <= reach.x and d.y <= reach.y:
		collected = true
		main.collect_powerup(shape)
		queue_free()


func _dims() -> Vector2:
	match shape:
		"triangle": return Vector2(20, 18)
		"circle": return Vector2(16, 16)
		_: return Vector2(16, 16)   # square


func _col() -> Color:
	return color if color.a > 0.0 else COLORS.get(shape, Color.WHITE)


func _draw() -> void:
	var c := _col()
	var outline := Color(1, 1, 1, 0.9)
	match shape:
		"triangle":
			var pts := PackedVector2Array([Vector2(0, -9), Vector2(10, 8), Vector2(-10, 8)])
			draw_colored_polygon(pts, c)
			draw_polyline(pts + PackedVector2Array([pts[0]]), outline, 1.5)
		"circle":
			# the morph pickup = the user's "power icon" art (ball.png, green B badge)
			draw_texture_rect_region(_icon_tex(), Rect2(-8, -8, 16, 16), Rect2(50, 38, 16, 16))
		"diamond":
			var d := PackedVector2Array([Vector2(0, -10), Vector2(9, 0), Vector2(0, 10), Vector2(-9, 0)])
			draw_colored_polygon(d, c)
			draw_polyline(d + PackedVector2Array([d[0]]), outline, 1.5)
		"star":
			var st := PackedVector2Array()
			for i in 10:
				var ang := -PI / 2.0 + i * PI / 5.0
				var rad := 10.0 if i % 2 == 0 else 4.5
				st.append(Vector2(cos(ang) * rad, sin(ang) * rad))
			draw_colored_polygon(st, c)
			draw_polyline(st + PackedVector2Array([st[0]]), outline, 1.2)
		"boomerang":
			# a bent chevron (looks like a boomerang)
			draw_line(Vector2(-8, 5), Vector2(0, -8), c, 3.0)
			draw_line(Vector2(0, -8), Vector2(8, 5), c, 3.0)
		"waterwalk":
			# a round water badge with a white "W" (walk-on-water power)
			draw_circle(Vector2.ZERO, 9.0, c)
			draw_arc(Vector2.ZERO, 9.0, 0.0, TAU, 24, outline, 1.5)
			var w := PackedVector2Array([
				Vector2(-6, -5), Vector2(-3, 6), Vector2(0, -1), Vector2(3, 6), Vector2(6, -5)])
			draw_polyline(w, Color.WHITE, 1.6)
		"dash":
			# a round badge with a white double-chevron ">>" (dash attack)
			draw_circle(Vector2.ZERO, 9.0, c)
			draw_arc(Vector2.ZERO, 9.0, 0.0, TAU, 24, outline, 1.5)
			for ox in [-4.0, 1.0]:
				draw_polyline(PackedVector2Array([
					Vector2(ox - 1, -5), Vector2(ox + 4, 0), Vector2(ox - 1, 5)]), Color.WHITE, 1.6)
		"riderkick":
			# a round badge with a white diagonal "boot" arrow pointing down-forward (rider kick)
			draw_circle(Vector2.ZERO, 9.0, c)
			draw_arc(Vector2.ZERO, 9.0, 0.0, TAU, 24, outline, 1.5)
			draw_line(Vector2(-5, -5), Vector2(4, 4), Color.WHITE, 1.8)      # the diagonal kick line
			draw_polyline(PackedVector2Array([Vector2(0, 5), Vector2(5, 5), Vector2(5, 0)]), Color.WHITE, 1.8)  # arrowhead
		"timeslow":
			# a round badge = a clock face (overclock / time slow)
			draw_circle(Vector2.ZERO, 9.0, c)
			draw_arc(Vector2.ZERO, 9.0, 0.0, TAU, 24, outline, 1.5)
			draw_line(Vector2.ZERO, Vector2(0, -5), Color.WHITE, 1.6)        # hour hand
			draw_line(Vector2.ZERO, Vector2(4, 1), Color.WHITE, 1.6)         # minute hand
		"hover":
			# a round badge with an up-chevron over a jet plume (hover jets)
			draw_circle(Vector2.ZERO, 9.0, c)
			draw_arc(Vector2.ZERO, 9.0, 0.0, TAU, 24, outline, 1.5)
			draw_polyline(PackedVector2Array([Vector2(-4, -1), Vector2(0, -6), Vector2(4, -1)]), Color.WHITE, 1.8)
			draw_line(Vector2(0, 1), Vector2(0, 6), Color(1.0, 0.7, 0.2), 2.0)   # jet flame
		_:  # square
			var s := Rect2(-8, -8, 16, 16)
			draw_rect(s, c)
			draw_rect(s, outline, false, 1.5)
