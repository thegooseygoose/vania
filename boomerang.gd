extends Node2D
## Thrown boomerang: flies out (decelerating), then curves back to Mario, spinning.
## Knocks out any enemy it touches. Despawns when Mario catches it.

var main
var dir := 1
var t := 0.0
var returning := false
const OUT_TIME := 0.64        # flies out longer → about twice the distance
const SPEED := 420.0
const SPIN_FPS := 18.0        # boomerang.png frame cycle speed
const DRAW_SCALE := 1.8       # the art is ~8px; scale it up to a readable size

var _frames: Array = []       # 8 orientations built from the 3 art frames + mirrors = a full spin


func _ready() -> void:
	z_index = 6
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_build_frames()

# The sheet (sprites/v sprites/boom.png) has 3 crescent frames whose OPENING points right / up-right /
# up. Mirroring them fills the other four diagonals/quadrants, giving a smooth 8-step 360° spin.
func _build_frames() -> void:
	var sheet: Image = (load("res://sprites/v sprites/boom.png") as Texture2D).get_image()
	if sheet.is_compressed():
		sheet.decompress()
	sheet.convert(Image.FORMAT_RGBA8)
	var a1 := _crop(sheet, Rect2i(33, 164, 5, 8))    # opens right
	var a2 := _crop(sheet, Rect2i(61, 164, 8, 8))    # opens up-right
	var a3 := _crop(sheet, Rect2i(90, 166, 8, 5))    # opens up
	_frames = [
		ImageTexture.create_from_image(a1),                          # right
		ImageTexture.create_from_image(a2),                          # up-right
		ImageTexture.create_from_image(a3),                          # up
		ImageTexture.create_from_image(_flip(a2, true, false)),      # up-left
		ImageTexture.create_from_image(_flip(a1, true, false)),      # left
		ImageTexture.create_from_image(_flip(a2, true, true)),       # down-left
		ImageTexture.create_from_image(_flip(a3, false, true)),      # down
		ImageTexture.create_from_image(_flip(a2, false, true)),      # down-right
	]

func _crop(sheet: Image, box: Rect2i) -> Image:
	var img := Image.create(box.size.x, box.size.y, false, Image.FORMAT_RGBA8)
	img.blit_rect(sheet, box, Vector2i.ZERO)
	return img

func _flip(src: Image, fx: bool, fy: bool) -> Image:
	var img := src.duplicate()
	if fx: img.flip_x()
	if fy: img.flip_y()
	return img


func _physics_process(delta: float) -> void:
	if main == null or not is_instance_valid(main.player):
		queue_free()
		return
	t += delta
	queue_redraw()
	if not returning:
		var f: float = 1.0 - clampf(t / OUT_TIME, 0.0, 1.0)   # ease to a stop, then return
		global_position.x += dir * SPEED * delta * f
		if t >= OUT_TIME:
			returning = true
	else:
		var to: Vector2 = main.player.global_position - global_position
		if to.length() < 12.0:
			queue_free()                                     # caught
			return
		global_position += to.normalized() * SPEED * delta
	# knock out enemies it passes through
	for e in main.enemies:
		if is_instance_valid(e) and e.has_method("knock_out") and not e.dead:
			if global_position.distance_to(e.global_position) < 14.0:
				e.knock_out(dir)
				main.sfx("kick")
	# hit door switches (only the boomerang can trigger these)
	for s in main.door_switches:
		if is_instance_valid(s) and not s.triggered and global_position.distance_to(s.global_position) < 12.0:
			s.hit()


func _draw() -> void:
	if _frames.is_empty():
		return
	var tex: Texture2D = _frames[int(t * SPIN_FPS) % _frames.size()]
	var sz: Vector2 = tex.get_size() * DRAW_SCALE
	draw_texture_rect(tex, Rect2(-sz * 0.5, sz), false)   # centred, spinning via the frame cycle
