extends SceneTree
## Construiește un sprite sheet pixel art dintr-o specificație JSON.
##
## Pași: încarcă pozele sursă → taie marginile goale → (opțional) cuantizează la paletă →
## generează cadrele animațiilor (din cadre desenate sau derivate din poze) → aliniază
## fiecare cadru pe pivot (picioarele) → lasă margini transparente → exportă PNG + JSON.
##
## Folosire (din folderul proiectului):
##   godot --headless --script tools/sprite_pipeline/build_sheet.gd -- art/sheets/corvin.spec.json
##
## Specificația (vezi art/sheets/corvin.spec.json):
##   name, cell [w,h], pivot [x,y] (în celulă), margin (px goi pe margini), palette (.hex opțional),
##   extract_palette (int, opțional: extrage N culori din surse și le salvează în palette),
##   animations: { nume: { source | files[], frames, fps, loop, fx } }
##   fx = breathe | hop | recoil | flash | float | none

const FX := ["none", "breathe", "hop", "recoil", "flash", "float"]


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		push_error("Lipsește calea către specificație (.spec.json)")
		quit(2)
		return
	var spec_path: String = args[0]
	var spec: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(spec_path))
	if spec == null or spec.is_empty():
		push_error("Specificație invalidă: " + spec_path)
		quit(2)
		return
	var root: String = spec_path.get_base_dir()
	var cell := Vector2i(int(spec["cell"][0]), int(spec["cell"][1]))
	var pivot := Vector2i(int(spec["pivot"][0]), int(spec["pivot"][1]))
	var margin: int = int(spec.get("margin", 2))

	# 1) paleta: extrasă din surse sau citită din fișier
	var palette: PackedColorArray = []
	if spec.has("extract_palette"):
		var sources: Array[Image] = []
		for anim in spec["animations"].values():
			for f in _sources_of(anim):
				sources.append(_load(root, f))
		palette = Palette.extract(sources, int(spec["extract_palette"]))
		Palette.save_hex(_resolve(root, spec["palette"]), palette)
		print("paletă extrasă: %d culori → %s" % [palette.size(), spec["palette"]])
	elif spec.has("palette"):
		palette = Palette.load_hex(_resolve(root, spec["palette"]))

	# 2) cadrele fiecărei animații
	var rows: Array = []
	var meta := {"name": spec["name"], "cell": [cell.x, cell.y], "pivot": [pivot.x, pivot.y], "animations": {}}
	var max_frames: int = 1
	for anim_name in spec["animations"]:
		var a: Dictionary = spec["animations"][anim_name]
		var frames: Array[Image] = []
		if a.has("files"):
			for f in a["files"]:
				frames.append(_prepare(_load(root, f), palette))
		else:
			var base := _prepare(_load(root, a["source"]), palette)
			for i in int(a.get("frames", 1)):
				frames.append(_fx(base, String(a.get("fx", "none")), i, int(a.get("frames", 1))))
		var cells: Array[Image] = []
		for fr in frames:
			cells.append(_place(fr, cell, pivot, margin))
		rows.append(cells)
		max_frames = maxi(max_frames, cells.size())
		meta["animations"][anim_name] = {"row": rows.size() - 1, "frames": cells.size(),
			"fps": float(a.get("fps", 8)), "loop": bool(a.get("loop", true))}

	# 3) sheet: un rând pe animație
	var sheet := Image.create_empty(cell.x * max_frames, cell.y * rows.size(), false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0, 0, 0, 0))
	for r in rows.size():
		for c in (rows[r] as Array).size():
			sheet.blit_rect(rows[r][c], Rect2i(Vector2i.ZERO, cell), Vector2i(c * cell.x, r * cell.y))
	var out_png := _resolve(root, spec.get("out_png", "%s_sheet.png" % spec["name"]))
	var out_json := _resolve(root, spec.get("out_json", "%s_sheet.json" % spec["name"]))
	meta["image"] = out_png.get_file()
	sheet.save_png(out_png)
	var fa := FileAccess.open(out_json, FileAccess.WRITE)
	fa.store_string(JSON.stringify(meta, "  "))
	fa.close()
	print("sheet: %s (%dx%d, %d animații) + %s" % [out_png, sheet.get_width(), sheet.get_height(), rows.size(), out_json])
	quit(0)


func _sources_of(anim: Dictionary) -> Array:
	return anim["files"] if anim.has("files") else [anim["source"]]


func _resolve(root: String, p: String) -> String:
	if p.begins_with("res://") or p.is_absolute_path():
		return p
	return root.path_join(p)


func _load(root: String, p: String) -> Image:
	var img := Image.load_from_file(_resolve(root, p))
	if img == null:
		push_error("Nu pot încărca " + p)
		return Image.create_empty(1, 1, false, Image.FORMAT_RGBA8)
	img.convert(Image.FORMAT_RGBA8)
	return img


## Taie marginile goale și aplică paleta (dacă există).
func _prepare(img: Image, palette: PackedColorArray) -> Image:
	var used := img.get_used_rect()
	var out := img.get_region(used) if used.size.x > 0 else img
	if not palette.is_empty():
		Palette.apply(out, palette)
	return out


## Pune cadrul în celulă: picioarele (mijlocul rândului de jos) pe pivot; păstrează marginile goale.
func _place(fr: Image, cell: Vector2i, pivot: Vector2i, margin: int) -> Image:
	var out := Image.create_empty(cell.x, cell.y, false, Image.FORMAT_RGBA8)
	out.fill(Color(0, 0, 0, 0))
	var at := Vector2i(pivot.x - fr.get_width() / 2, pivot.y - fr.get_height())
	at.x = clampi(at.x, margin, maxi(margin, cell.x - margin - fr.get_width()))
	at.y = clampi(at.y, margin, maxi(margin, cell.y - margin - fr.get_height()))
	out.blend_rect(fr, Rect2i(Vector2i.ZERO, fr.get_size()), at)
	return out


## Derivă cadre de animație dintr-o singură poză (când nu există cadre desenate).
## Operațiile sunt pe pixeli întregi (fără netezire), ca rezultatul să rămână pixel art.
func _fx(base: Image, fx: String, i: int, n: int) -> Image:
	var w := base.get_width()
	var h := base.get_height()
	var phase: float = float(i) / float(maxi(n, 1))
	match fx:
		"breathe":
			# corpul se strânge cu 1–2 rânduri și revine
			var dh: int = int(round((1.0 - cos(phase * TAU)) * 1.0))
			return _resize(base, w, h - dh)
		"hop":
			# pas: corpul sare (deplasare făcută de pivot) și se turtește la aterizare
			var dh: int = 2 if i % 3 == 0 else 0
			var img := _resize(base, w + (1 if dh > 0 else 0), h - dh)
			return _pad_bottom(img, int(round(absf(sin(phase * TAU)) * 3.0)))
		"recoil":
			var img := base.duplicate()
			if i == 0:
				_tint(img, Color(1.25, 1.2, 1.1))
			return _shift_x(img, -2 if i == 0 else (-1 if i == 1 else 0))
		"flash":
			var img := base.duplicate()
			_tint(img, Color(3, 3, 3) if i == 0 else Color(1.4, 0.7, 0.7))
			return img
		"float":
			return _pad_bottom(base, int(round(3.0 + sin(phase * TAU) * 2.0)))
	return base.duplicate()


func _resize(img: Image, w: int, h: int) -> Image:
	var out := img.duplicate()
	out.resize(maxi(1, w), maxi(1, h), Image.INTERPOLATE_NEAREST)
	return out


## Ridică imaginea adăugând rânduri goale jos (pivotul rămâne pe sol).
func _pad_bottom(img: Image, px: int) -> Image:
	if px <= 0:
		return img
	var out := Image.create_empty(img.get_width(), img.get_height() + px, false, Image.FORMAT_RGBA8)
	out.fill(Color(0, 0, 0, 0))
	out.blit_rect(img, Rect2i(Vector2i.ZERO, img.get_size()), Vector2i.ZERO)
	return out


func _shift_x(img: Image, dx: int) -> Image:
	var out := Image.create_empty(img.get_width() + absi(dx), img.get_height(), false, Image.FORMAT_RGBA8)
	out.fill(Color(0, 0, 0, 0))
	out.blit_rect(img, Rect2i(Vector2i.ZERO, img.get_size()), Vector2i(maxi(0, dx), 0))
	return out


func _tint(img: Image, mul: Color) -> void:
	for y in img.get_height():
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			if c.a > 0.5:
				img.set_pixel(x, y, Color(minf(c.r * mul.r, 1.0), minf(c.g * mul.g, 1.0), minf(c.b * mul.b, 1.0), c.a))
