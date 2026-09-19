extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(20): await physics_frame

	var EnemyScript = load("res://enemy.gd")
	var e = EnemyScript.new()
	e.main = m
	e.kind = "urchin"
	m.add_child(e)
	e.spawn(Vector2(200, 200))
	m.enemies.append(e)

	var ys := []
	for i in range(180):
		await physics_frame
		if i % 20 == 0:
			ys.append(e.global_position.y)
	print("y samples over ~3s: ", ys)
	print("min=", ys.min(), " max=", ys.max(), " spawn_y=200")
	print("texture ok=", e.sprite.texture != null)
	quit()
