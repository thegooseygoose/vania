@tool
extends Node2D
class_name DoorSwitch
## A target that ONLY the boomerang can hit. When struck it opens the doors.
## Placeable/movable in the editor. Drawn as a red bullseye (green once hit).

var main
var triggered := false


func _ready() -> void:
	z_index = 4


func hit() -> void:
	if triggered:
		return
	triggered = true
	queue_redraw()
	if main:
		main.open_doors()
		main.sfx("kick")


func _draw() -> void:
	var c := Color(0.35, 0.9, 0.4) if triggered else Color(0.95, 0.25, 0.25)
	draw_circle(Vector2.ZERO, 7.0, c)
	draw_arc(Vector2.ZERO, 7.0, 0.0, TAU, 22, Color(1, 1, 1, 0.9), 1.5)
	draw_circle(Vector2.ZERO, 3.0, Color(1, 1, 1, 0.9))
