extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame

func _key(kc: int) -> InputEventKey:
	var e := InputEventKey.new(); e.keycode = kc; e.pressed = true; return e

func _run() -> void:
	var intro = load("res://Intro.tscn").instantiate()
	get_root().add_child(intro)
	await _step(3)
	# jump straight to the new main menu (bypass logo)
	intro._open_files()
	await _step(1)
	print("phase after _open_files = %s (expect mainmenu)  mm_sel=%d" % [intro.phase, intro.mm_sel])

	intro._mainmenu_input(_key(KEY_DOWN)); print("after DOWN mm_sel=%d (expect 1)" % intro.mm_sel)
	intro._mainmenu_input(_key(KEY_UP));   print("after UP   mm_sel=%d (expect 0)" % intro.mm_sel)

	# KEY_2 should target level 2 (we intercept before scene-change by checking debug_start_level)
	Main.debug_start_level = -99
	# temporarily neuter the scene change so the test doesn't tear down
	intro.set_meta("noswap", true)
	intro._mainmenu_input(_key(KEY_1))
	print("after '1' debug_start_level=%d (expect 1)" % Main.debug_start_level)

	print("DONE")
	quit()
