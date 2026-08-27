@tool
extends Node2D
class_name GrabPoint
## A grapple-beam anchor. Drop it anywhere in the level (drag it in the editor);
## with the STAR power-up, press X near one to zip up and hang from it, then jump
## off for height. Drawn as the "hook point" sprite (theclaw.png) — the claw latches
## onto the sprite's centre (this node's origin).

const SHEET: Texture2D = preload("res://sprites/v sprites/theclaw.png")
const HOOK_REGION := Rect2(154, 8, 8, 5)   # the little U-shaped hook in the sheet (NOT the block demo)


func _ready() -> void:
	z_index = 4
	texture_filter = TEXTURE_FILTER_NEAREST   # crisp pixels, no blur


func _draw() -> void:
	# the claw grabs this node's origin, so centre the hook sprite on it. Use an INTEGER offset
	# (floor) — a fractional dest (e.g. -2.5 for the odd 5px height) drops the bottom row of the
	# sprite under nearest filtering, which was chopping off the hook's cross-bar.
	var off := (-HOOK_REGION.size * 0.5).floor() + Vector2(-1, 0)   # nudged 1px left to sit centred
	draw_texture_rect_region(SHEET, Rect2(off, HOOK_REGION.size), HOOK_REGION)
