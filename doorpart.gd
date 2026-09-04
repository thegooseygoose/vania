@tool
extends Node2D
class_name DoorPart
## A placeable door piece (door.png), positioned by hand in the editor. Three parts assemble into
## the full 48x48 door:
##   LEFT / RIGHT = the two half-circles — the BOOMERANG can shoot them (shoot() is called on a hit).
##   MID          = the centre panel — drawn IN FRONT of the player so you walk BEHIND it. No collision.
## Add via Add Child Node -> DoorPart, then pick `part` in the Inspector.

enum Part { LEFT, MID, RIGHT }

@export var part: Part = Part.MID:
	set(value):
		part = value
		_refresh()

var main                       # set by Main._wire_powerups (for the shootable half-circles)
var _shot := false             # a half-circle that's been shot out
var _body: StaticBody2D        # the SOLID collider on a half-circle (you can't walk through it)

const TEX := {
	Part.LEFT: preload("res://sprites/door/door_left.png"),
	Part.MID: preload("res://sprites/door/door_mid.png"),
	Part.RIGHT: preload("res://sprites/door/door_right.png"),
}
const MID_Z := 7               # MID draws ABOVE the player (z 5) → you walk behind it
const SIDE_Z := 4              # the half-circles sit in the normal prop layer


func _ready() -> void:
	texture_filter = TEXTURE_FILTER_NEAREST
	_refresh()
	# the blue half-circles are SOLID (you can't walk through them) until you shoot them out.
	if is_half() and not Engine.is_editor_hint():
		_make_solid()

# build the solid wall collider for a half-circle (removed when shot, rebuilt when it closes)
func _make_solid() -> void:
	if _body != null:
		return
	var t: Texture2D = TEX.get(part)
	var sz: Vector2 = t.get_size() if t else Vector2(8, 48)
	_body = StaticBody2D.new()
	_body.collision_layer = 1                  # layer 1 = world; the player (mask 1) collides with it
	_body.collision_mask = 0
	var cs := CollisionShape2D.new()
	var r := RectangleShape2D.new()
	r.size = sz
	cs.shape = r
	_body.add_child(cs)
	add_child(_body)                            # centred on this node (the half-circle)

func _refresh() -> void:
	z_index = MID_Z if part == Part.MID else SIDE_Z
	queue_redraw()

func is_half() -> bool:
	return part == Part.LEFT or part == Part.RIGHT

func get_rect() -> Rect2:
	var t: Texture2D = TEX.get(part)
	var sz: Vector2 = t.get_size() if t else Vector2(8, 48)
	return Rect2(global_position - sz * 0.5, sz)

# Called by the boomerang when it hits this half-circle.
func shoot() -> void:
	if _shot or not is_half():
		return
	_shot = true
	visible = false            # the shot half-circle disappears...
	if _body:
		_body.queue_free()     # ...and its solid wall is removed, opening the passage
		_body = null
	if main:
		main.sfx("kick")

# Close the door back up (real Metroid: doors close behind you). Re-solid + visible.
func close() -> void:
	if not is_half() or not _shot:
		return
	_shot = false
	visible = true
	queue_redraw()
	_make_solid()
	if main:
		main.sfx("bump")


func _draw() -> void:
	if _shot:
		return
	var t: Texture2D = TEX.get(part)
	if t == null:
		return
	var sz := t.get_size()
	draw_texture_rect(t, Rect2(-sz * 0.5, sz), false)   # centred on the node's origin
