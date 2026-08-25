@tool
extends Node2D
class_name Door
## A solid door that blocks the player until its DoorSwitch is hit by the boomerang.
## Placeable/movable in the editor. Node origin = the door's TOP-LEFT corner.

@export var size_tiles: Vector2i = Vector2i(1, 3):
	set(v):
		size_tiles = Vector2i(max(1, v.x), max(1, v.y))
		queue_redraw()

var main
var opened := false
var _body: StaticBody2D


func _ready() -> void:
	z_index = 3
	if not Engine.is_editor_hint():
		# a solid collider on the world layer so the player can't walk through
		_body = StaticBody2D.new()
		_body.collision_layer = 1
		_body.collision_mask = 0
		var cs := CollisionShape2D.new()
		var r := RectangleShape2D.new()
		r.size = Vector2(size_tiles.x * 16, size_tiles.y * 16)
		cs.shape = r
		cs.position = r.size / 2.0
		_body.add_child(cs)
		add_child(_body)


func open() -> void:
	if opened:
		return
	opened = true
	if _body:
		_body.queue_free()          # stop blocking
		_body = null
	var tw := create_tween()        # slide up + fade away
	tw.set_parallel(true)
	tw.tween_property(self, "position:y", position.y - size_tiles.y * 16, 0.4)
	tw.tween_property(self, "modulate:a", 0.0, 0.4)
	tw.chain().tween_callback(hide)


func _draw() -> void:
	var w := size_tiles.x * 16
	var h := size_tiles.y * 16
	draw_rect(Rect2(0, 0, w, h), Color(0.45, 0.28, 0.12))
	draw_rect(Rect2(2, 2, w - 4, h - 4), Color(0.6, 0.38, 0.18), false, 1.0)
	draw_rect(Rect2(0, 0, w, h), Color(0.85, 0.6, 0.3), false, 2.0)
	draw_circle(Vector2(w - 5, h / 2.0), 2.0, Color(0.95, 0.85, 0.4))   # knob
