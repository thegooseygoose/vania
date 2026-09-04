extends Node2D
## Thrown boomerang: flies out (decelerating), then curves back to Mario, spinning.
## Knocks out any enemy it touches. Despawns when Mario catches it.

var main
var dir := 1
var t := 0.0
var returning := false
const OUT_TIME := 0.64        # flies out longer → about twice the distance
const SPEED := 420.0
const BULLET_SPEED := 300.0   # NEW BOOM (bullet): straight-line travel speed
const BULLET_RANGE := 64.0    # travels this far (px), then stops & despawns
const BULLET_LIFE := 2.0      # safety despawn (also despawns if it goes off-screen)
var _bullet_traveled := 0.0   # distance the bullet has flown
const SPIN_FPS := 18.0        # boomerang.png frame cycle speed
const DRAW_SCALE := 1.8       # the art is ~8px; scale it up to a readable size

var _frames: Array = []       # 8 orientations built from the 3 art frames + mirrors = a full spin
var _bullet_tex: Texture2D    # current test look — "new boom.png" (a bullet), used instead of the spin

# Use the new bullet art ("new boom.png") for now; the old crescent-spin logic is kept below,
# just bypassed while this is true. Set false to go back to the spinning boomerang.
const USE_NEW_BOOM := true


func _ready() -> void:
	z_index = 6
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_build_frames()            # keep the old boomerang art built in the background
	_build_bullet()

# The current test visual: whatever opaque shape is drawn in "new boom.png" (auto-cropped to its
# content, so it updates when you re-save the file). Needs an --import after editing the png.
func _build_bullet() -> void:
	var path := "res://sprites/v sprites/new boom.png"
	if not ResourceLoader.exists(path):
		return
	var img: Image = (load(path) as Texture2D).get_image()
	if img.is_compressed():
		img.decompress()
	img.convert(Image.FORMAT_RGBA8)
	var r := img.get_used_rect()
	if r.size.x <= 0 or r.size.y <= 0:
		return
	var crop := Image.create(r.size.x, r.size.y, false, Image.FORMAT_RGBA8)
	crop.blit_rect(img, r, Vector2i.ZERO)
	_bullet_tex = ImageTexture.create_from_image(crop)

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
	if USE_NEW_BOOM:
		# BULLET: fly straight at constant speed until it has travelled BULLET_RANGE (64px),
		# then stop & despawn. (Also despawns off-screen / after BULLET_LIFE as a safety.)
		var step: float = BULLET_SPEED * delta
		step = minf(step, BULLET_RANGE - _bullet_traveled)   # don't overshoot the 64px range
		global_position.x += dir * step
		_bullet_traveled += step
		# blocked by a solid wall/block — it can't fly through terrain
		if _solid_wall_at(global_position):
			queue_free()
			return
		if _bullet_traveled >= BULLET_RANGE \
				or t > BULLET_LIFE \
				or global_position.x < main.cam_x - 32.0 \
				or global_position.x > main.cam_x + float(main.VIEW_W) + 32.0:
			queue_free()
			return
	elif not returning:
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
	# hit enemies it reaches
	for e in main.enemies:
		if is_instance_valid(e) and not e.dead \
				and global_position.distance_to(e.global_position) < 14.0:
			# boomerang_kill also takes down zoomers (which shrug off knock_out)
			if e.has_method("boomerang_kill"):
				e.boomerang_kill(dir)
			elif e.has_method("knock_out"):
				e.knock_out(dir)
			main.sfx("kick")
			if USE_NEW_BOOM:
				queue_free()             # the SHOT lands ONE hit and stops (serp: 3 hits to kill)
				return
	# hit door switches (only the boomerang can trigger these)
	for s in main.door_switches:
		if is_instance_valid(s) and not s.triggered and global_position.distance_to(s.global_position) < 12.0:
			s.hit()
	# the DOOR blocks the shot: it hits the near part and STOPS (can't reach the far side).
	# Half-circles also get shot out; the centre panel just blocks.
	for dp in main.door_parts:
		if is_instance_valid(dp) and dp.get_rect().has_point(global_position):
			if not dp._shot:
				dp.shoot()               # halves shoot out (no-op on the centre panel)
			if USE_NEW_BOOM:
				queue_free()             # the SHOT stops here — doesn't pass through the door
				return


# a solid wall/block at this position (not water / lava / hook) — stops the shot
func _solid_wall_at(pos: Vector2) -> bool:
	if main == null or main.terrain == null:
		return false
	var cell := Vector2i(int(floor(pos.x / 16.0)), int(floor(pos.y / 16.0)))
	if main.terrain.get_cell_source_id(cell) < 0:
		return false
	var ax: int = main.terrain.get_cell_atlas_coords(cell).x
	# not solid: lava (28/29), water (45/46), hook (47) and painted power-up tiles (48+)
	return ax != 28 and ax != 29 and ax < 45


func _draw() -> void:
	# NEW BOOM (bullet) test look — drawn centred, no spin. Old crescent spin kept below.
	if USE_NEW_BOOM and _bullet_tex != null:
		var bsz: Vector2 = _bullet_tex.get_size()
		draw_texture_rect(_bullet_tex, Rect2(-bsz * 0.5, bsz), false)
		return
	if _frames.is_empty():
		return
	var tex: Texture2D = _frames[int(t * SPIN_FPS) % _frames.size()]
	var sz: Vector2 = tex.get_size() * DRAW_SCALE
	draw_texture_rect(tex, Rect2(-sz * 0.5, sz), false)   # centred, spinning via the frame cycle
