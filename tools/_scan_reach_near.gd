extends SceneTree
const W := 480
const H := 450
func idx(x:int,y:int)->int: return y*W+x
func _initialize(): call_deferred("_run")
func _run():
	var ff := FileAccess.open("res://tools/_reach_fwd.raw", FileAccess.READ)
	var fwd := ff.get_buffer(W*H); ff.close()
	var x0 := 100; var x1 := 220
	var y0 := 100; var y1 := 200
	for y in range(y0, y1+1):
		var line := ""
		for x in range(x0, x1+1):
			line += ("R" if fwd[idx(x,y)]==1 else ".")
		if line.contains("R"):
			print("y=%3d: %s" % [y, line])
	quit()
