extends SceneTree
func _initialize(): call_deferred("_run")
func _run() -> void:
	var Hud = load("res://hud.gd")
	var h = Hud.new()
	var cases = ["JUMP", "JUMP.", "DOWN.", "DOWN", "AIRBORNE.", "A", "THE", "X", "L3", "PRESS"]
	for c in cases:
		print(c, " -> ", h._is_control_word(c))
	quit()
