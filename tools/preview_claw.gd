extends SceneTree
func _init() -> void:
	var sheet := Image.load_from_file("res://sprites/v sprites/theclaw.png"); sheet.convert(Image.FORMAT_RGBA8)
	var mario_r := Image.load_from_file("res://sprites/player/big_jump_r.png"); mario_r.convert(Image.FORMAT_RGBA8)
	var mario_l := mario_r.duplicate(); mario_l.flip_x()
	var rb := [Rect2i(64,61,90,7), Rect2i(109,60,77,42), Rect2i(227,60,7,97)]
	var lb := [Rect2i(362,61,90,7), Rect2i(330,60,77,42), Rect2i(282,60,7,97)]
	var tip_r := [Vector2(1.0,0.5), Vector2(1.0,0.0), Vector2(0.5,0.0)]
	var tip_l := [Vector2(0.0,0.5), Vector2(0.0,0.0), Vector2(0.5,0.0)]
	var dir_r := [Vector2(-1,0), Vector2(-1,1), Vector2(0,1)]
	var dir_l := [Vector2(1,0), Vector2(1,1), Vector2(0,1)]
	var claw_r := [_ex(sheet,rb[0]),_ex(sheet,rb[1]),_ex(sheet,rb[2])]
	var claw_l := [_ex(sheet,lb[0]),_ex(sheet,lb[1]),_ex(sheet,lb[2])]
	# two scenes: grab up-right (Mario faces right) and up-left (faces left)
	var scenes := [Vector2(60,-70), Vector2(-60,-70)]
	var W:=260; var H:=170
	var canvas := Image.create(W,H,false,Image.FORMAT_RGBA8); canvas.fill(Color(0.09,0.09,0.13,1))
	var centers := [Vector2(75,120), Vector2(185,120)]
	for s in 2:
		var mc: Vector2 = centers[s]           # Mario centre (origin)
		var da: Vector2 = scenes[s]
		var facing: int = 1 if da.x >= 0 else -1
		var fist: Vector2 = mc + Vector2(facing*5.0, -16.0)
		var anchor: Vector2 = fist + da
		# draw Mario jump sprite: sprite centre at origin, position.y=-2 → tex(px,py)->local(px-8,py-18)
		var msp: Image = mario_r if facing>=0 else mario_l
		var mtl := mc + Vector2(-8, -18)       # top-left of the 16x32 sprite in canvas
		canvas.blend_rect(msp, Rect2i(0,0,16,32), Vector2i(mtl))
		# pick claw
		var d := anchor - fist
		var right: bool = d.x >= 0.0
		var elev: float = clampf(atan2(-d.y,absf(d.x)),0.0,PI*0.5)
		var b := int(round(elev/(PI*0.5)*2.0))
		var tex: Image = (claw_r[b] if right else claw_l[b])
		var tip: Vector2 = (tip_r[b] if right else tip_l[b])
		var dir: Vector2 = (dir_r[b] if right else dir_l[b])
		var sz := Vector2(tex.get_width(), tex.get_height())
		var rope := fist.distance_to(anchor)
		var full_len: float = (sz.length() if (dir.x!=0.0 and dir.y!=0.0) else (sz.x if dir.x!=0.0 else sz.y))
		var f: float = clampf(rope/full_len,0.0,1.0)
		var sw: float = (sz.x*f) if dir.x!=0.0 else sz.x
		var sh: float = (sz.y*f) if dir.y!=0.0 else sz.y
		var sx: float = 0.0 if dir.x>=0.0 else sz.x-sw
		var sy: float = 0.0 if dir.y>=0.0 else sz.y-sh
		var full_tip := Vector2(tip.x*sz.x, tip.y*sz.y)
		var dest := anchor - full_tip + Vector2(sx,sy)
		canvas.blend_rect(tex, Rect2i(int(sx),int(sy),int(sw),int(sh)), Vector2i(dest))
		_disc(canvas, anchor,1.0,Color(1,0.25,0.5))
		_disc(canvas, fist,1.0,Color(0.2,1,0.3))     # his fist (chain end target)
	canvas.resize(W*3,H*3,Image.INTERPOLATE_NEAREST)
	canvas.save_png("res://tools/_claw_preview.png"); print("saved"); quit()
func _ex(sheet: Image, box: Rect2i) -> Image:
	var sub := Image.create(box.size.x,box.size.y,false,Image.FORMAT_RGBA8)
	for y in box.size.y:
		for x in box.size.x: sub.set_pixel(x,y, sheet.get_pixel(box.position.x+x,box.position.y+y))
	var lab:={}; var bid:=-1; var bc:=0; var nid:=0
	for sy in box.size.y:
		for sx in box.size.x:
			if sub.get_pixel(sx,sy).a<=0.3 or lab.has(Vector2i(sx,sy)): continue
			nid+=1; var cnt:=0; var st:=[Vector2i(sx,sy)]
			while st.size()>0:
				var p: Vector2i = st.pop_back()
				if lab.has(p) or p.x<0 or p.y<0 or p.x>=box.size.x or p.y>=box.size.y: continue
				if sub.get_pixel(p.x,p.y).a<=0.3: continue
				lab[p]=nid; cnt+=1
				for dy in range(-1,2):
					for dx in range(-1,2): st.append(Vector2i(p.x+dx,p.y+dy))
			if cnt>bc: bc=cnt; bid=nid
	for y in box.size.y:
		for x in box.size.x:
			if lab.get(Vector2i(x,y),-1)!=bid: sub.set_pixel(x,y,Color(0,0,0,0))
	return sub
func _disc(img: Image, c: Vector2, r: float, col: Color) -> void:
	for dy in range(-1,2):
		for dx in range(-1,2):
			var x:=int(c.x)+dx; var y:=int(c.y)+dy
			if x>=0 and y>=0 and x<img.get_width() and y<img.get_height(): img.set_pixel(x,y,col)
