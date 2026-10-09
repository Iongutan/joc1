class_name PixelFont
extends RefCounted
## Font pixel desenat de mână (5x7), cu diacritice românești și contur închis la culoare.
## Mărimi recomandate (multipli de 12): 24, 36, 48, 60, 72.
## Literele care lipsesc (de exemplu chirilica) vin din fontul standard, ca rezervă.

const SIZE: int = 12
const ACCENT_ROWS: int = 2
const MAIN_ROWS: int = 7
const DESC_ROWS: int = 2
const PAD: int = 1
const CELL_H: int = PAD + ACCENT_ROWS + MAIN_ROWS + DESC_ROWS + PAD
const ASCENT: int = PAD + ACCENT_ROWS + MAIN_ROWS

const GLYPHS := {
	"A": ".###.|#...#|#...#|#####|#...#|#...#|#...#",
	"B": "####.|#...#|#...#|####.|#...#|#...#|####.",
	"C": ".###.|#...#|#....|#....|#....|#...#|.###.",
	"D": "####.|#...#|#...#|#...#|#...#|#...#|####.",
	"E": "#####|#....|#....|####.|#....|#....|#####",
	"F": "#####|#....|#....|####.|#....|#....|#....",
	"G": ".###.|#...#|#....|#.###|#...#|#...#|.###.",
	"H": "#...#|#...#|#...#|#####|#...#|#...#|#...#",
	"I": "###|.#.|.#.|.#.|.#.|.#.|###",
	"J": "..###|...#.|...#.|...#.|#..#.|#..#.|.##..",
	"K": "#...#|#..#.|#.#..|##...|#.#..|#..#.|#...#",
	"L": "#....|#....|#....|#....|#....|#....|#####",
	"M": "#...#|##.##|#.#.#|#.#.#|#...#|#...#|#...#",
	"N": "#...#|##..#|#.#.#|#..##|#...#|#...#|#...#",
	"O": ".###.|#...#|#...#|#...#|#...#|#...#|.###.",
	"P": "####.|#...#|#...#|####.|#....|#....|#....",
	"Q": ".###.|#...#|#...#|#...#|#.#.#|#..#.|.##.#",
	"R": "####.|#...#|#...#|####.|#.#..|#..#.|#...#",
	"S": ".####|#....|#....|.###.|....#|....#|####.",
	"T": "#####|..#..|..#..|..#..|..#..|..#..|..#..",
	"U": "#...#|#...#|#...#|#...#|#...#|#...#|.###.",
	"V": "#...#|#...#|#...#|#...#|#...#|.#.#.|..#..",
	"W": "#...#|#...#|#...#|#.#.#|#.#.#|#.#.#|.#.#.",
	"X": "#...#|#...#|.#.#.|..#..|.#.#.|#...#|#...#",
	"Y": "#...#|#...#|.#.#.|..#..|..#..|..#..|..#..",
	"Z": "#####|....#|...#.|..#..|.#...|#....|#####",
	"a": ".....|.....|.###.|....#|.####|#...#|.####",
	"b": "#....|#....|####.|#...#|#...#|#...#|####.",
	"c": ".....|.....|.###.|#....|#....|#...#|.###.",
	"d": "....#|....#|.####|#...#|#...#|#...#|.####",
	"e": ".....|.....|.###.|#...#|#####|#....|.###.",
	"f": "..##|.#..|####|.#..|.#..|.#..|.#..",
	"g": ".....|.....|.####|#...#|#...#|.####|....#|.###.",
	"h": "#....|#....|####.|#...#|#...#|#...#|#...#",
	"i": ".|#|.|#|#|#|#",
	"j": "..|.#|..|.#|.#|.#|.#|#.",
	"k": "#...|#...|#..#|#.#.|##..|#.#.|#..#",
	"l": "#.|#.|#.|#.|#.|#.|.#",
	"m": ".....|.....|##.#.|#.#.#|#.#.#|#.#.#|#.#.#",
	"n": ".....|.....|####.|#...#|#...#|#...#|#...#",
	"o": ".....|.....|.###.|#...#|#...#|#...#|.###.",
	"p": ".....|.....|####.|#...#|#...#|####.|#....|#....",
	"q": ".....|.....|.####|#...#|#...#|.####|....#|....#",
	"r": "....|....|#.##|##..|#...|#...|#...",
	"s": ".....|.....|.####|#....|.###.|....#|####.",
	"t": ".#..|.#..|####|.#..|.#..|.#..|..##",
	"u": ".....|.....|#...#|#...#|#...#|#...#|.####",
	"v": ".....|.....|#...#|#...#|#...#|.#.#.|..#..",
	"w": ".....|.....|#...#|#.#.#|#.#.#|#.#.#|.#.#.",
	"x": ".....|.....|#...#|.#.#.|..#..|.#.#.|#...#",
	"y": ".....|.....|#...#|#...#|#...#|.####|....#|.###.",
	"z": ".....|.....|#####|...#.|..#..|.#...|#####",
	"0": ".###.|#...#|#..##|#.#.#|##..#|#...#|.###.",
	"1": ".#.|##.|.#.|.#.|.#.|.#.|###",
	"2": ".###.|#...#|....#|...#.|..#..|.#...|#####",
	"3": "####.|....#|....#|.###.|....#|....#|####.",
	"4": "...#.|..##.|.#.#.|#..#.|#####|...#.|...#.",
	"5": "#####|#....|####.|....#|....#|#...#|.###.",
	"6": ".###.|#....|#....|####.|#...#|#...#|.###.",
	"7": "#####|....#|...#.|..#..|..#..|..#..|..#..",
	"8": ".###.|#...#|#...#|.###.|#...#|#...#|.###.",
	"9": ".###.|#...#|#...#|.####|....#|....#|.###.",
	".": ".|.|.|.|.|.|#",
	",": ".|.|.|.|.|.|#|#",
	":": ".|.|#|.|.|#|.",
	";": ".|.|#|.|.|#|#",
	"!": "#|#|#|#|#|.|#",
	"?": ".###.|#...#|....#|...#.|..#..|.....|..#..",
	"-": "....|....|....|####|....|....|....",
	"+": ".....|..#..|..#..|#####|..#..|..#..|.....",
	"%": "##..#|##.#.|...#.|..#..|.#...|.#.##|#..##",
	"/": "....#|...#.|...#.|..#..|.#...|.#...|#....",
	"(": ".#|#.|#.|#.|#.|#.|.#",
	")": "#.|.#|.#|.#|.#|.#|#.",
	"[": "##|#.|#.|#.|#.|#.|##",
	"]": "##|.#|.#|.#|.#|.#|##",
	"'": "#|#|.|.|.|.|.",
	"\"": "#.#|#.#|...|...|...|...|...",
	"«": "......|......|..#..#|.#..#.|#..#..|.#..#.|..#..#",
	"»": "......|......|#..#..|.#..#.|..#..#|.#..#.|#..#..",
	"·": ".|.|.|#|.|.|.",
	"—": "......|......|......|######|......|......|......",
	"×": ".....|.....|#...#|.#.#.|..#..|.#.#.|#...#",
	"*": ".....|#.#.#|.###.|#####|.###.|#.#.#|.....",
	"#": ".#.#.|#####|.#.#.|.#.#.|#####|.#.#.|.....",
}

## Diacritice: litera de bază + accent (sus) sau virgulă (jos).
const ACCENTED := {
	"ă": ["a", "breve"], "Ă": ["A", "breve"],
	"â": ["a", "circ"], "Â": ["A", "circ"],
	"î": ["ı", "circ"], "Î": ["I", "circ"],
	"ș": ["s", "comma"], "Ș": ["S", "comma"],
	"ț": ["t", "comma"], "Ț": ["T", "comma"],
	"ş": ["s", "comma"], "Ş": ["S", "comma"],
	"ţ": ["t", "comma"], "Ţ": ["T", "comma"],
}

const MARKS := {
	"breve": "#..#|.##.",
	"circ": ".#.|#.#",
}

static var _font: FontFile
static var _font_outlined: FontFile


## Fontul simplu (pentru panouri) — cel mai lizibil.
static func get_font() -> FontFile:
	if _font == null:
		_font = _build(false)
	return _font


## Fontul cu contur închis (pentru text peste joc: cifre de damage, titluri peste imagini).
static func get_font_outlined() -> FontFile:
	if _font_outlined == null:
		_font_outlined = _build(true)
	return _font_outlined


static func _build(outlined: bool) -> FontFile:
	var glyphs: Dictionary = {}
	for ch in GLYPHS:
		glyphs[ch] = _parse(GLYPHS[ch])
	glyphs["ı"] = _parse(".|.|#|#|#|#|#")
	for ch in ACCENTED:
		var base: String = ACCENTED[ch][0]
		glyphs[ch] = _with_mark(glyphs[base], ACCENTED[ch][1], base == base.to_upper() and base != "ı")
	glyphs.erase("ı")

	# atlas: toate literele pe un singur rând, fiecare cu contur de 1 pixel
	var total_w: int = 0
	for ch in glyphs:
		total_w += ((glyphs[ch] as Array).back() as String).length() + PAD * 2 + 1
	var img := Image.create_empty(total_w, CELL_H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	var f := FontFile.new()
	f.fixed_size = SIZE
	f.fixed_size_scale_mode = TextServer.FIXED_SIZE_SCALE_INTEGER_ONLY
	f.set_cache_ascent(0, SIZE, ASCENT)
	f.set_cache_descent(0, SIZE, CELL_H - ASCENT)
	var key := Vector2i(SIZE, 0)
	var x: int = 0
	for ch in glyphs:
		var rows: Array = glyphs[ch]
		var w: int = (rows.back() as String).length()
		_draw_glyph(img, rows, x, outlined)
		var code: int = (ch as String).unicode_at(0)
		var gw: int = w + PAD * 2
		f.set_glyph_advance(0, SIZE, code, Vector2(w + 1, 0))
		f.set_glyph_offset(0, key, code, Vector2(-PAD, -ASCENT))
		f.set_glyph_size(0, key, code, Vector2(gw, CELL_H))
		f.set_glyph_uv_rect(0, key, code, Rect2(x, 0, gw, CELL_H))
		f.set_glyph_texture_idx(0, key, code, 0)
		x += gw + 1
	# spațiul
	f.set_glyph_advance(0, SIZE, 32, Vector2(3, 0))
	f.set_glyph_offset(0, key, 32, Vector2.ZERO)
	f.set_glyph_size(0, key, 32, Vector2.ZERO)
	f.set_glyph_uv_rect(0, key, 32, Rect2())
	f.set_glyph_texture_idx(0, key, 32, 0)
	f.set_texture_image(0, key, 0, img)
	f.fallbacks = [ThemeDB.fallback_font]
	return f


## Rânduri de lățime egală, 7 sau 9 rânduri (cu codiță jos).
static func _parse(s: String) -> Array:
	var rows: Array = Array(s.split("|"))
	var w: int = 0
	for r in rows:
		w = maxi(w, (r as String).length())
	for i in rows.size():
		rows[i] = (rows[i] as String).rpad(w, ".")
	return rows


static func _with_mark(base: Array, mark: String, upper: bool) -> Array:
	var rows: Array = base.duplicate()
	var w: int = (rows[0] as String).length()
	var m: Array = _parse(MARKS.get(mark, "#"))
	var out: Array = rows
	if mark == "comma":
		while out.size() < MAIN_ROWS:
			out.append(".".repeat(w))
		while out.size() < MAIN_ROWS + 2:
			out.append(".".repeat(w))
		var cx: int = w / 2
		out[MAIN_ROWS] = (".".repeat(cx) + "#").rpad(w, ".")
		out[MAIN_ROWS + 1] = (".".repeat(maxi(cx - 1, 0)) + "#").rpad(w, ".")
		return out
	# accent: centrat deasupra literei; la majuscule urcă în rândurile de accent
	var mw: int = (m[0] as String).length()
	var width: int = maxi(w, mw)
	var base_pad: int = (width - w) / 2
	var mark_pad: int = (width - mw) / 2
	var lines: Array = []
	for r in m:
		lines.append((".".repeat(mark_pad) + (r as String)).rpad(width, "."))
	for i in out.size():
		out[i] = (".".repeat(base_pad) + (out[i] as String)).rpad(width, ".")
	if upper:
		# rândurile -2 și -1, marcate cu prefixul "^"
		return ["^" + lines[0], "^" + lines[1]] + out
	out[0] = lines[0]
	out[1] = lines[1]
	return out


static func _draw_glyph(img: Image, rows: Array, x0: int, outlined: bool) -> void:
	var ink := Color(1, 1, 1)
	var line := Color(0.05, 0.03, 0.07)
	var pts: Array[Vector2i] = []
	var main_row: int = 0
	var accent_row: int = 0
	for r in rows:
		var s: String = r
		var y: int
		if s.begins_with("^"):
			s = s.substr(1)
			y = PAD + accent_row
			accent_row += 1
		else:
			y = PAD + ACCENT_ROWS + main_row
			main_row += 1
		for x in s.length():
			if s[x] == "#":
				pts.append(Vector2i(x0 + PAD + x, y))
	for p in pts:
		if not outlined:
			break
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var q: Vector2i = p + d
			if q.x >= 0 and q.y >= 0 and q.x < img.get_width() and q.y < img.get_height() and img.get_pixelv(q).a < 0.5:
				img.set_pixelv(q, line)
	for p in pts:
		img.set_pixelv(p, ink)
