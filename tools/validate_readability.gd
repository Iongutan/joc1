extends SceneTree
## Validează lizibilitatea sprite-urilor la scara jocului, pe fundalul fiecărui capitol,
## cu și fără strălucire (glow). Simulează întunericul din luptă: culorile normale sunt
## înmulțite cu culoarea de întuneric a capitolului; pixelii de glow nu sunt afectați.
##
## Criterii (pe fiecare fundal, în varianta FĂRĂ glow):
##   - înălțime >= MIN_H pixeli;
##   - contrast mediu (diferența de luminanță sprite ↔ fundal) >= MIN_MEAN;
##   - cel puțin MIN_ACCENT din pixeli diferă clar de fundal (>= ACCENT_DELTA);
##   - siluetă plină: pixeli opaci / dreptunghiul încadrator >= MIN_SOLID;
##   - număr de culori <= MAX_COLORS.
## Scrie docs/audit/readability.png (previzualizare 2x) și docs/audit/readability.txt.
## Cod de ieșire 1 dacă vreun sprite pică.
##
##   godot --headless --path . --script res://tools/validate_readability.gd

const MIN_H := 24
const MIN_MEAN := 0.10
const ACCENT_DELTA := 0.22
const MIN_ACCENT := 0.12
const MIN_SOLID := 0.30
const MAX_COLORS := 64
const PREVIEW_SCALE := 2
## Lumina eroului din luptă (PointLight2D, energie ~1.15) adună lumină peste întuneric.
const HERO_LIGHT := 0.85


func _init() -> void:
	var subjects: Array = []  # [nume, imagine cu glow, imagine fără glow, mască glow]
	for id in PaperDoll.EXAMPLES:
		var spec: Dictionary = PaperDoll.EXAMPLES[id]
		subjects.append(["doll:" + id, PaperDoll.compose(spec, true), PaperDoll.compose(spec, false), PaperDoll.glow_mask(spec)])
	for hero in HeroArt.ROSTER:
		var img := Image.load_from_file(ProjectSettings.globalize_path("res://art/heroes/%s_idle.png" % hero))
		var sheet_json := "res://art/sheets/%s_sheet.json" % hero
		if FileAccess.file_exists(sheet_json):
			# eroul are sheet (paletă limitată): se validează cadrul "idle" din sheet
			var meta: Dictionary = SheetLoader.meta(sheet_json)
			var full := Image.load_from_file(ProjectSettings.globalize_path(sheet_json.get_base_dir().path_join(meta["image"])))
			img = full.get_region(Rect2i(0, int(meta["animations"]["idle"]["row"]) * int(meta["cell"][1]), int(meta["cell"][0]), int(meta["cell"][1])))
		img.convert(Image.FORMAT_RGBA8)
		var empty := Image.create_empty(img.get_width(), img.get_height(), false, Image.FORMAT_RGBA8)
		empty.fill(Color(0, 0, 0, 0))
		subjects.append(["hero:" + hero, img, img, empty])

	var lines: Array[String] = ["Validare lizibilitate — %s" % Time.get_date_string_from_system(), ""]
	var failures: int = 0
	var cell_w: int = 0
	var cell_h: int = 0
	for s in subjects:
		cell_w = maxi(cell_w, (s[1] as Image).get_width() + 8)
		cell_h = maxi(cell_h, (s[1] as Image).get_height() + 8)
	var chapters: Array = Chapters.LIST
	# previzualizare: rânduri = subiecte × {glow, fără glow}; coloane = capitole
	var sheet := Image.create_empty(cell_w * chapters.size(), cell_h * subjects.size() * 2, false, Image.FORMAT_RGBA8)

	for si in subjects.size():
		var name: String = subjects[si][0]
		var with_glow: Image = subjects[si][1]
		var no_glow: Image = subjects[si][2]
		var mask: Image = subjects[si][3]
		var used := no_glow.get_used_rect()
		var colors := _color_count(with_glow)
		var solid := _solidity(no_glow, used)
		var worst_mean: float = 1.0
		var worst_accent: float = 1.0
		var dark_mean: float = 1.0
		for ci in chapters.size():
			var ch: Dictionary = chapters[ci]
			var dark := Pixel.c(ch["darkness"])
			var bg: Color = Pixel.c(ch["ground"][0]) * dark
			bg.a = 1.0
			for variant in 2:
				var src: Image = with_glow if variant == 0 else no_glow
				var cell := Image.create_empty(cell_w, cell_h, false, Image.FORMAT_RGBA8)
				cell.fill(bg)
				# rândul de sus: în lumina eroului, cu glow; rândul de jos: fără glow
				var light := Color(minf(dark.r + HERO_LIGHT, 1.0), minf(dark.g + HERO_LIGHT, 1.0), minf(dark.b + HERO_LIGHT * 0.85, 1.0))
				var lit := _apply_darkness(src, mask if variant == 0 else null, light)
				var bg_lit: Color = Pixel.c(ch["ground"][0]) * light
				bg_lit.a = 1.0
				cell.fill(bg_lit)
				cell.blend_rect(lit, Rect2i(Vector2i.ZERO, lit.get_size()), Vector2i(4, 4))
				sheet.blit_rect(cell, Rect2i(Vector2i.ZERO, cell.get_size()), Vector2i(ci * cell_w, (si * 2 + variant) * cell_h))
				if variant == 1:
					var m := _contrast(lit, bg_lit)
					worst_mean = minf(worst_mean, m.x)
					worst_accent = minf(worst_accent, m.y)
					var md := _contrast(_apply_darkness(src, null, dark), bg)
					dark_mean = minf(dark_mean, md.x)
		var ok_h := used.size.y >= MIN_H
		var ok := ok_h and worst_mean >= MIN_MEAN and worst_accent >= MIN_ACCENT and solid >= MIN_SOLID and colors <= MAX_COLORS
		if not ok:
			failures += 1
		var why: Array[String] = []
		if not ok_h: why.append("prea mic")
		if worst_mean < MIN_MEAN: why.append("contrast mic")
		if worst_accent < MIN_ACCENT: why.append("puține detalii vizibile")
		if solid < MIN_SOLID: why.append("siluetă rară")
		if colors > MAX_COLORS: why.append("prea multe culori (paletă)")
		lines.append("%s %s  înălțime=%d  contrast=%.2f  accent=%.0f%%  siluetă=%.2f  culori=%d  întuneric=%.2f%s%s" % [
			"OK  " if ok else "PICĂ", name, used.size.y, worst_mean, worst_accent * 100.0, solid, colors, dark_mean,
			"  ⚠ greu de văzut în întuneric" if dark_mean < MIN_MEAN else "", ("  → " + ", ".join(why)) if not why.is_empty() else ""])

	lines.append("")
	lines.append("Praguri (fără glow, în lumina eroului, cel mai rău capitol): înălțime>=%d, contrast>=%.2f, accent>=%.0f%%, siluetă>=%.2f, culori<=%d. \"întuneric\" = contrast fără lumină (doar avertisment)." % [
		MIN_H, MIN_MEAN, MIN_ACCENT * 100.0, MIN_SOLID, MAX_COLORS])
	lines.append("Previzualizare: docs/audit/readability.png (pe rânduri: cu glow / fără glow; pe coloane: capitolele)")
	sheet.resize(sheet.get_width() * PREVIEW_SCALE, sheet.get_height() * PREVIEW_SCALE, Image.INTERPOLATE_NEAREST)
	sheet.save_png(ProjectSettings.globalize_path("res://docs/audit/readability.png"))
	var f := FileAccess.open("res://docs/audit/readability.txt", FileAccess.WRITE)
	f.store_string("\n".join(lines) + "\n")
	f.close()
	for l in lines:
		print(l)
	quit(1 if failures > 0 else 0)


## Întunericul din luptă: culoarea * întuneric, în afară de pixelii de glow (neluminați).
func _apply_darkness(src: Image, glow_mask: Image, dark: Color) -> Image:
	var out: Image = src.duplicate()
	for y in out.get_height():
		for x in out.get_width():
			var c := out.get_pixel(x, y)
			if c.a < 0.5:
				continue
			if glow_mask != null and glow_mask.get_pixel(x, y).a > 0.5:
				continue
			out.set_pixel(x, y, Color(c.r * dark.r, c.g * dark.g, c.b * dark.b, c.a))
	return out


## x = diferența medie de luminanță; y = fracția de pixeli care diferă clar de fundal.
func _contrast(img: Image, bg: Color) -> Vector2:
	var lb: float = bg.get_luminance()
	var total: float = 0.0
	var accent: int = 0
	var n: int = 0
	for y in img.get_height():
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			if c.a < 0.5:
				continue
			var d: float = absf(c.get_luminance() - lb)
			total += d
			if d >= ACCENT_DELTA:
				accent += 1
			n += 1
	if n == 0:
		return Vector2.ZERO
	return Vector2(total / n, float(accent) / n)


func _solidity(img: Image, used: Rect2i) -> float:
	if used.size.x * used.size.y == 0:
		return 0.0
	var n: int = 0
	for y in range(used.position.y, used.end.y):
		for x in range(used.position.x, used.end.x):
			if img.get_pixel(x, y).a > 0.5:
				n += 1
	return float(n) / float(used.size.x * used.size.y)


func _color_count(img: Image) -> int:
	var seen: Dictionary = {}
	for y in img.get_height():
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			if c.a > 0.5:
				seen[c.to_rgba32()] = true
	return seen.size()
