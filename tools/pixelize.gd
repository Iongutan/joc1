extends SceneTree
## Transformă o ilustrație într-un sprite pixel art:
## scoate fundalul alb, micșorează la înălțimea țintă, reduce culorile, adaugă contur.
## Folosire: godot --headless --script pixelize.gd -- in1.jpg in2.jpg ... --out=preview.png --h=96

func _init() -> void:
	var inputs: Array = []
	var out_path := "preview.png"
	var target_h := 96
	var clear_bottom := false
	var out_dir := ""
	var suffix := "_pixel"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--out="):
			out_path = a.substr(6)
		elif a.begins_with("--h="):
			target_h = a.substr(4).to_int()
		elif a == "--clear-bottom-white":
			clear_bottom = true
		elif a.begins_with("--dir="):
			out_dir = a.substr(6)
		elif a.begins_with("--suffix="):
			suffix = a.substr(9)
		else:
			inputs.append(a)
	var sprites: Array[Image] = []
	for p in inputs:
		var img := Image.load_from_file(p)
		if img == null:
			push_error("nu pot încărca " + p)
			continue
		img.convert(Image.FORMAT_RGBA8)
		_remove_background(img)
		if clear_bottom:
			_clear_bottom_white(img)
		var used := img.get_used_rect()
		img = img.get_region(used)
		var scale: float = float(target_h) / img.get_height()
		var w: int = maxi(1, int(round(img.get_width() * scale)))
		img.resize(w, target_h, Image.INTERPOLATE_BILINEAR)
		_quantize(img)
		img = _outline(img)
		sprites.append(img)
		var single := img.duplicate()
		var base: String = p.get_file().get_basename()
		var dest: String = (out_dir + "/" + base + suffix + ".png") if out_dir != "" else (p.get_basename() + suffix + ".png")
		single.save_png(dest)
	# foaie de previzualizare: toate sprite-urile mărite de 4 ori pe fundal închis
	var pad := 8
	var total_w := pad
	var max_h := 0
	for s in sprites:
		total_w += s.get_width() + pad
		max_h = maxi(max_h, s.get_height())
	var sheet := Image.create_empty(total_w, max_h + pad * 2, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.1, 0.09, 0.14))
	var x := pad
	for s in sprites:
		sheet.blend_rect(s, Rect2i(Vector2i.ZERO, s.get_size()), Vector2i(x, pad + max_h - s.get_height()))
		x += s.get_width() + pad
	sheet.resize(sheet.get_width() * 4, sheet.get_height() * 4, Image.INTERPOLATE_NEAREST)
	sheet.save_png(out_path)
	print("gata: ", out_path)
	quit()


## Fundalul alb (și umbrele foarte deschise) devin transparente, pornind de la margini.
func _remove_background(img: Image) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var seen := PackedByteArray()
	seen.resize(w * h)
	var stack: Array[Vector2i] = []
	for x in w:
		stack.append(Vector2i(x, 0))
		stack.append(Vector2i(x, h - 1))
	for y in h:
		stack.append(Vector2i(0, y))
		stack.append(Vector2i(w - 1, y))
	while not stack.is_empty():
		var p: Vector2i = stack.pop_back()
		if p.x < 0 or p.y < 0 or p.x >= w or p.y >= h:
			continue
		var i := p.y * w + p.x
		if seen[i] == 1:
			continue
		seen[i] = 1
		var c := img.get_pixelv(p)
		if c.v > 0.86 and c.s < 0.12:
			img.set_pixelv(p, Color(0, 0, 0, 0))
			stack.append(p + Vector2i(1, 0))
			stack.append(p + Vector2i(-1, 0))
			stack.append(p + Vector2i(0, 1))
			stack.append(p + Vector2i(0, -1))


## Paletă redusă: fiecare canal pe câteva niveluri, ca la pixel art-ul clasic.
func _quantize(img: Image) -> void:
	var levels := 7.0
	for y in img.get_height():
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			if c.a < 0.5:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
				continue
			c.r = round(c.r * levels) / levels
			c.g = round(c.g * levels) / levels
			c.b = round(c.b * levels) / levels
			c.a = 1.0
			img.set_pixel(x, y, c)


## Contur de 1 pixel, mai închis decât culoarea vecină.
func _outline(img: Image) -> Image:
	var w := img.get_width() + 2
	var h := img.get_height() + 2
	var out := Image.create_empty(w, h, false, Image.FORMAT_RGBA8)
	out.fill(Color(0, 0, 0, 0))
	out.blit_rect(img, Rect2i(Vector2i.ZERO, img.get_size()), Vector2i(1, 1))
	var src := out.duplicate()
	for y in h:
		for x in w:
			if src.get_pixel(x, y).a > 0.5:
				continue
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var nx: int = x + d.x
				var ny: int = y + d.y
				if nx >= 0 and ny >= 0 and nx < w and ny < h and src.get_pixel(nx, ny).a > 0.5:
					var o: Color = src.get_pixel(nx, ny).darkened(0.7)
					o.a = 1.0
					out.set_pixel(x, y, o)
					break
	return out


## Scoate petele albe/gri-deschis din sfertul de jos (pământul desenat sub personaj).
func _clear_bottom_white(img: Image) -> void:
	var h := img.get_height()
	for y in range(int(h * 0.72), h):
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			if c.a > 0.5 and c.v > 0.7 and c.s < 0.2:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
