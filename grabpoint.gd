@tool
extends Node2D
class_name GrabPoint
## A grapple-beam anchor. Drop it anywhere in the level (drag it in the editor);
## with the STAR power-up, press X near one to zip up and hang from it, then jump
## off for height. Drawn as a magenta ring so you can see it while editing.


func _ready() -> void:
	z_index = 4


func _draw() -> void:
	var col := Color(1.0, 0.35, 0.8)
	draw_arc(Vector2.ZERO, 7.0, 0.0, TAU, 22, col, 2.0)
	draw_circle(Vector2.ZERO, 3.0, Color(1.0, 0.85, 1.0))
	# little nubs so it reads as a hook/anchor
	draw_line(Vector2(0, -7), Vector2(0, -11), col, 2.0)
