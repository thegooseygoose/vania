extends SceneTree
const W := 480
const H := 450
func idx(x:int,y:int)->int: return y*W+x
func _initialize(): call_deferred("_run")
func _run():
	var ff := FileAccess.open("res://tools/_reach_fwd.raw", FileAccess.READ)
	var fwd := ff.get_buffer(W*H); ff.close()
	var pts := [Vector2i(170,166), Vector2i(165,193), Vector2i(185,160), Vector2i(185,140), Vector2i(185,120),
		Vector2i(185,100), Vector2i(185,95), Vector2i(175,449), Vector2i(175,206)]
	for p in pts:
		print(p, " reached=", fwd[idx(p.x,p.y)]==1)
	quit()
