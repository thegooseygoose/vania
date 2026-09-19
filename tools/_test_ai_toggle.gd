extends SceneTree
func _key(kc: int) -> InputEventKey:
	var e := InputEventKey.new(); e.keycode = kc; e.pressed = true; return e
func _initialize(): call_deferred("_run")
func _run() -> void:
	var intro = load("res://Intro.tscn").instantiate()
	get_root().add_child(intro)
	for i in range(5): await process_frame
	intro._open_files()
	print("phase=%s variant=%d" % [intro.phase, Main.enemy_variant])
	for i in range(4): intro._mainmenu_input(_key(KEY_DOWN))   # LEVEL A -> ... -> AI
	print("selected=%s" % str(intro._menu_list()[intro.mm_sel]))
	intro._mainmenu_input(_key(KEY_ENTER))
	print("after Enter #1: phase=%s variant=%d" % [intro.phase, Main.enemy_variant])
	intro._mainmenu_input(_key(KEY_ENTER))
	print("after Enter #2: phase=%s variant=%d" % [intro.phase, Main.enemy_variant])
	quit()
