class_name Pixel
extends RefCounted
## Unelte pentru pixel art desenat ca text: fiecare caracter e un pixel, iar paleta
## spune ce culoare are. Contururile se adaugă automat, ca sprite-urile să arate „desenate".


## Transformă o hartă de caractere într-o imagine. '.' și ' ' = transparent.
static func from_map(rows: Array, palette: Dictionary) -> Image:
	var h: int = rows.size()
	var w: int = 0
	for r in rows:
		w = maxi(w, (r as String).length())
	var img := Image.create_empty(maxi(w, 1), maxi(h, 1), false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for y in h:
		var row: String = rows[y]
		for x in row.length():
			var ch: String = row[x]
			if ch == "." or ch == " ":
				continue
			if palette.has(ch):
				img.set_pixel(x, y, palette[ch])
	return img


## Lipește src în dst la poziția dată (pixelii transparenți sunt ignorați).
static func blit(dst: Image, src: Image, at: Vector2i) -> void:
	for y in src.get_height():
		for x in src.get_width():
			var c: Color = src.get_pixel(x, y)
			if c.a <= 0.01:
				continue
			var px: int = at.x + x
			var py: int = at.y + y
			if px >= 0 and py >= 0 and px < dst.get_width() and py < dst.get_height():
				dst.set_pixel(px, py, c)


## Contur de 1 pixel în jurul formei (doar pe pixelii transparenți vecini).
static func outline(img: Image, col: Color) -> Image:
	var w: int = img.get_width()
	var h: int = img.get_height()
	var out: Image = img.duplicate()
	for y in h:
		for x in w:
			if img.get_pixel(x, y).a > 0.01:
				continue
			var near: bool = false
			for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
				var nx: int = x + d.x
				var ny: int = y + d.y
				if nx >= 0 and ny >= 0 and nx < w and ny < h and img.get_pixel(nx, ny).a > 0.5:
					near = true
					break
			if near:
				out.set_pixel(x, y, col)
	return out


## Umbre și lumini automate: marginile de sus/stânga primesc lumină, cele de jos/dreapta umbră.
## Transformă culorile plate în volume, ca în pixel art-ul desenat de mână.
static func shade(img: Image, light: float = 0.16, dark: float = 0.22) -> Image:
	var w: int = img.get_width()
	var h: int = img.get_height()
	var out: Image = img.duplicate()
	for y in h:
		for x in w:
			var c: Color = img.get_pixel(x, y)
			if c.a <= 0.01:
				continue
			var up: Color = img.get_pixel(x, y - 1) if y > 0 else Color(0, 0, 0, 0)
			var left: Color = img.get_pixel(x - 1, y) if x > 0 else Color(0, 0, 0, 0)
			var down: Color = img.get_pixel(x, y + 1) if y < h - 1 else Color(0, 0, 0, 0)
			var right: Color = img.get_pixel(x + 1, y) if x < w - 1 else Color(0, 0, 0, 0)
			if up.a < 0.5 or (left.a < 0.5 and up.a < 0.5):
				out.set_pixel(x, y, c.lightened(light))
			elif down.a < 0.5 or right.a < 0.5:
				out.set_pixel(x, y, c.darkened(dark))
			elif not up.is_equal_approx(c) and up.get_luminance() < c.get_luminance():
				# sub o margine mai închisă (de ex. sub glugă) apare o umbră
				out.set_pixel(x, y, c.darkened(dark * 0.6))
	return out


## Contur colorat: fiecare pixel de contur ia culoarea vecinului, mult mai închisă
## (mai elegant decât negrul pur).
static func selective_outline(img: Image, strength: float = 0.62) -> Image:
	var w: int = img.get_width()
	var h: int = img.get_height()
	var out: Image = img.duplicate()
	for y in h:
		for x in w:
			if img.get_pixel(x, y).a > 0.01:
				continue
			for d in [Vector2i(0, 1), Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, -1)]:
				var nx: int = x + d.x
				var ny: int = y + d.y
				if nx >= 0 and ny >= 0 and nx < w and ny < h:
					var n: Color = img.get_pixel(nx, ny)
					if n.a > 0.5:
						var o: Color = n.darkened(strength)
						o.a = 1.0
						out.set_pixel(x, y, o)
						break
	return out


static func flip_h(img: Image) -> Image:
	var out: Image = img.duplicate()
	out.flip_x()
	return out


## Mărire fără netezire (pixelii rămân pătrați).
static func upscale(img: Image, factor: int) -> Image:
	var out: Image = img.duplicate()
	out.resize(img.get_width() * factor, img.get_height() * factor, Image.INTERPOLATE_NEAREST)
	return out


static func tex(img: Image) -> ImageTexture:
	return ImageTexture.create_from_image(img)


## Culoare din hex scurt, ca paletele să fie lizibile.
static func c(hex: String) -> Color:
	return Color.html(hex)
