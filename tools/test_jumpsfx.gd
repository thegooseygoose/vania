extends SceneTree
func _initialize(): call_deferred("_run")
func _run() -> void:
	var s = load("res://audio/vania/jump sound.wav")
	print("jump sound loads: %s (%s)" % ["YES" if s else "NO", s.get_class() if s else "null"])
	quit()
