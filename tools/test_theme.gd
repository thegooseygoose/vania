extends SceneTree
func _initialize(): call_deferred("_run")
func _run() -> void:
	var s = load("res://audio/vania/level_theme.mp3")
	print("theme loads: %s (%s), loop=%s" % ["YES" if s else "NO", s.get_class() if s else "null", s.loop if s else "?"])
	quit()
