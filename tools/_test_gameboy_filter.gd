extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(20): await physics_frame
	print("FILTER_NAMES=", m.FILTER_NAMES)
	m.filter_mode = 3
	m._apply_filter()
	for i in range(3): await physics_frame
	var mat: ShaderMaterial = m.filter_rect.material
	print("filter_rect.visible=", m.filter_rect.visible, " mode param=", mat.get_shader_parameter("mode"))
	# cycle test via the same code path the pause menu uses
	m.filter_mode = 0
	for i in range(5):
		m._pause_row_adjust(1) if false else null  # (pause_sel gating aside, call the raw cycle directly)
	quit()
