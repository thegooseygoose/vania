extends SceneTree

# Verifies the split-water-tint shader compiles and exposes its uniforms, and that
# main.water_surface_y() returns the top of the topmost water cell at a column.
func _init() -> void:
	var mat := ShaderMaterial.new()
	var sh := Shader.new()
	sh.code = "shader_type canvas_item;\n" \
		+ "uniform float water_y = 100000.0;\n" \
		+ "uniform vec4 tint : source_color = vec4(1.0);\n" \
		+ "varying float v_world_y;\n" \
		+ "void vertex() { v_world_y = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).y; }\n" \
		+ "void fragment() { if (v_world_y >= water_y) { COLOR.rgb *= tint.rgb; } }\n"
	mat.shader = sh
	mat.set_shader_parameter("tint", Color(0.55, 0.75, 1.0))
	mat.set_shader_parameter("water_y", 42.0)
	var names := []
	for u in sh.get_shader_uniform_list():
		names.append(u.name)
	print("shader uniforms: ", names)
	print("tint param: ", mat.get_shader_parameter("tint"))
	print("water_y param: ", mat.get_shader_parameter("water_y"))

	# water_surface_y logic (mirrors main.gd) on a fake stacked column of water rects
	var TILE := 16
	var water_rects := [
		Rect2(80, 96, TILE, TILE),   # column x=80..96, top y=96
		Rect2(80, 112, TILE, TILE),  # same column, lower cell
		Rect2(80, 128, TILE, TILE),  # same column, lowest cell
		Rect2(200, 64, TILE, TILE),  # a different column
	]
	print("surface at x=88 -> ", _surf(water_rects, Vector2(88, 130)), " (expect 96)")
	print("surface at x=208 -> ", _surf(water_rects, Vector2(208, 70)), " (expect 64)")
	print("surface at x=300 -> ", _surf(water_rects, Vector2(300, 70)), " (expect inf)")
	quit()

func _surf(rects: Array, p: Vector2) -> float:
	var best := INF
	for r in rects:
		if p.x >= r.position.x and p.x < r.position.x + r.size.x and r.position.y < best:
			best = r.position.y
	return best
