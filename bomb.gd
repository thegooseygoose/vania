extends Node2D
## MORPH-BALL BOMB (Metroid): dropped while rolled into a ball. It sits with a blinking fuse,
## then detonates — a pixel-art blast that breaks bricks around it, damages nearby enemies, and
## pops the ball UP a little (so you can bomb-jump). Your own bomb never hurts you.

var main
var t := 0.0
const FUSE := 0.8                # seconds before it goes off
const BLAST_TILES := 1          # break bricks within this many tiles (a 3x3 around the bomb)
const BLAST_PX := 26.0          # enemies/player within this range are caught in the blast
const BOMB_JUMP := 250.0        # upward pop given to the ball (bomb-jump)
const ExplosionFX := preload("res://explosion.gd")


func _ready() -> void:
	z_index = 6
	set_process(true)


func _process(delta: float) -> void:
	if main != null and main.actors_frozen():
		return                   # hold the fuse while the world is frozen (power-up freeze etc.)
	t += delta
	queue_redraw()
	if t >= FUSE:
		_explode()


func _explode() -> void:
	# pixel-art blast
	var fx := ExplosionFX.new()
	var parent := get_parent()
	if parent:
		parent.add_child(fx)
		fx.global_position = global_position
	# break bricks in a small radius (bombs open blocks just like a shot does)
	var tile: int = main.TILE
	var cx := int(floor(global_position.x / float(tile)))
	var cy := int(floor(global_position.y / float(tile)))
	for dy in range(-BLAST_TILES, BLAST_TILES + 1):
		for dx in range(-BLAST_TILES, BLAST_TILES + 1):
			main.smash_tile(cx + dx, cy + dy)
	# damage every enemy caught in the blast (kills like a shot — tough enemies take one hit)
	for e in main.enemies:
		if is_instance_valid(e) and not e.dead and global_position.distance_to(e.global_position) <= BLAST_PX:
			if e.has_method("boomerang_kill"):
				e.boomerang_kill(1)
			elif e.has_method("knock_out"):
				e.knock_out(1)
	# BOMB-JUMP: pop the player up if they're on/beside the bomb (never hurts them)
	var p = main.player
	if is_instance_valid(p) and not p.dead and global_position.distance_to(p.global_position) <= BLAST_PX + 8.0:
		p.velocity.y = minf(p.velocity.y, -BOMB_JUMP)
		if p.has_method("bomb_bounced"):
			p.bomb_bounced()
	main.sfx("brick")            # the boom
	if main.bombs.has(self):
		main.bombs.erase(self)
	queue_free()


func _draw() -> void:
	# a small dark bomb; a fuse light on top blinks FASTER as detonation nears
	var f := clampf(t / FUSE, 0.0, 1.0)
	var blink: bool = int(t * (7.0 + f * 26.0)) % 2 == 0
	draw_circle(Vector2.ZERO, 5.0, Color(0.10, 0.10, 0.14))        # body
	draw_circle(Vector2(-1.5, -1.5), 1.6, Color(0.34, 0.34, 0.44)) # highlight
	var lit := Color(1.0, 0.55, 0.2) if blink else Color(0.45, 0.16, 0.08)
	draw_rect(Rect2(-0.5, -7.0, 1.0, 2.0), Color(0.3, 0.25, 0.2))  # fuse stub
	draw_circle(Vector2(0.0, -7.5), 1.7, lit)                      # blinking spark
