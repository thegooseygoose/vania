@tool
extends Node2D
class_name Sector
## A placeable camera SECTOR (room). Position the node at the sector's TOP-LEFT corner and set its
## width/height (in tiles) in the Inspector. The room camera locks to whichever sector the player is
## in (2D — both axes): a sector <= the screen size is shown fixed/centred, a bigger one scrolls
## within its bounds. Add via Add Child Node -> Sector under the level root, then drag it into place.

@export var w_tiles: int = 16:
	set(v): w_tiles = maxi(1, v); queue_redraw()
@export var h_tiles: int = 15:
	set(v): h_tiles = maxi(1, v); queue_redraw()

const TILE := 16

func rect_px() -> Rect2:
	return Rect2(global_position, Vector2(w_tiles * TILE, h_tiles * TILE))

func _draw() -> void:
	if not Engine.is_editor_hint():
		return   # invisible in-game — it only defines the camera bounds
	var r := Rect2(Vector2.ZERO, Vector2(w_tiles * TILE, h_tiles * TILE))
	draw_rect(r, Color(0.3, 0.8, 1.0, 0.10))          # translucent fill
	draw_rect(r, Color(0.35, 0.85, 1.0, 0.9), false, 1.0)  # outline
	# corner ticks so the top-left origin is obvious
	draw_line(Vector2.ZERO, Vector2(6, 0), Color(1, 1, 0.3), 1.0)
	draw_line(Vector2.ZERO, Vector2(0, 6), Color(1, 1, 0.3), 1.0)
