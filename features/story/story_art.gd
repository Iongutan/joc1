class_name StoryArt
extends Control
## Ilustrațiile poveștii. Se desenează la rezoluție mică (prin PixelCanvas), cu benzi de
## culoare cu dithering, ca în jocurile pixel art. Eroul apare animat prin HeroPortrait.

var scene_id: String = "battle"
var _t: float = 0.0
var _last_frame: int = -1
var _hero: HeroPortrait
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hero = HeroPortrait.new()
	_hero.setup("corvin")
	add_child(_hero)
	show_scene(scene_id)


func show_scene(id: String) -> void:
	scene_id = id
	_t = 0.0
	if _hero == null:
		return
	_hero.size = HeroArt.texture("corvin", "idle", true).get_size()
	_hero.pivot_offset = _hero.size * 0.5
	_hero.rotation = 0.0
	_hero.visible = true
	_hero.modulate = Color.WHITE
	match id:
		"battle":
			_hero.rotation = PI * 0.5
			_hero.position = Vector2(size.x * 0.5 - _hero.size.x * 0.5, size.y * 0.58 - _hero.size.y * 0.5)
			_hero.modulate = Color(0.75, 0.6, 0.6)
			_hero.play("hurt")
		"morgrav":
			_hero.position = Vector2(size.x * 0.5 - _hero.size.x * 0.5, size.y * 0.62 - _hero.size.y * 0.8)
			_hero.modulate = Color(0.7, 0.6, 0.95)
			_hero.play("hurt")
		"north":
			_hero.position = Vector2(size.x * 0.62, size.y * 0.66 - _hero.size.y * 0.8)
			_hero.play("run")
		_:
			_hero.visible = false
	queue_redraw()


func _process(delta: float) -> void:
	_t += delta
	_place_hero()
	# animație pixel art la 12 cadre/s: mult mai puțin de desenat
	var f: int = int(_t * 12.0)
	if f != _last_frame:
		_last_frame = f
		queue_redraw()


func _place_hero() -> void:
	if _hero == null or not _hero.visible:
		return
	match scene_id:
		"battle":
			_hero.position = Vector2(size.x * 0.5 - _hero.size.x * 0.5, size.y * 0.6 - _hero.size.y * 0.5)
		"morgrav":
			_hero.position = Vector2(size.x * 0.5 - _hero.size.x * 0.5, size.y * 0.7 - _hero.size.y * 0.85)
		"north":
			_hero.position = Vector2(size.x * 0.58, size.y * 0.74 - _hero.size.y * 0.85)


# --- ajutoare ------------------------------------------------------------

## Benzi de culoare cu tranziții în dithering (tipic pentru pixel art).
func _sky(cols: Array, top: float, bottom: float) -> void:
	var w: float = size.x
	var band: float = (bottom - top) / cols.size()
	for i in cols.size():
		var y0: float = top + i * band
		draw_rect(Rect2(0, y0, w, band + 1), cols[i])
		if i + 1 < cols.size():
			var y: float = floorf(y0 + band - 2)
			for x in range(0, int(w), 2):
				draw_rect(Rect2(x + (int(y) % 2), y, 1, 1), cols[i + 1])
				draw_rect(Rect2(x + ((int(y) + 1) % 2), y + 1, 1, 1), cols[i + 1])


func _stars(count: int, max_y: float) -> void:
	_rng.seed = 7
	for i in count:
		var p := Vector2(_rng.randf() * size.x, _rng.randf() * max_y)
		var tw: float = 0.5 + 0.5 * sin(_t * 2.0 + i)
		draw_rect(Rect2(p.floor(), Vector2.ONE), Color(1, 0.95, 0.85, 0.4 + tw * 0.6))


func _mountains(base_y: float, amp: float, col: Color, seed_v: int, snow: bool = false) -> void:
	_rng.seed = seed_v
	var pts := PackedVector2Array([Vector2(0, size.y)])
	var x: float = 0.0
	var peaks: Array = []
	while x <= size.x + 8:
		var y: float = base_y - _rng.randf() * amp
		pts.append(Vector2(x, y))
		peaks.append(Vector2(x, y))
		x += 10.0 + _rng.randf() * 18.0
	pts.append(Vector2(size.x, size.y))
	draw_colored_polygon(pts, col)
	if snow:
		for p in peaks:
			if (p as Vector2).y < base_y - amp * 0.55:
				draw_colored_polygon(PackedVector2Array([p + Vector2(-4, 5), p, p + Vector2(4, 5)]), Color(0.85, 0.88, 0.95))


func _fire(p: Vector2, s: float) -> void:
	var f: float = 0.75 + 0.25 * sin(_t * 9.0 + p.x)
	draw_circle(p, 10.0 * s, Color(1.0, 0.5, 0.15, 0.12))
	draw_colored_polygon(PackedVector2Array([p + Vector2(-3, 0) * s, p + Vector2(0, -9 * f) * s, p + Vector2(3, 0) * s]), Color(1.0, 0.45, 0.1))
	draw_colored_polygon(PackedVector2Array([p + Vector2(-1.5, 0) * s, p + Vector2(0, -5 * f) * s, p + Vector2(1.5, 0) * s]), Color(1.0, 0.85, 0.35))


func _embers(col: Color, n: int) -> void:
	for i in n:
		var x: float = fmod(float(i * 37) + sin(_t + i) * 6.0, size.x)
		var y: float = size.y - fmod(_t * (12.0 + float(i % 5) * 4.0) + float(i * 53), size.y)
		draw_rect(Rect2(Vector2(x, y).floor(), Vector2.ONE), col)


# --- scenele -------------------------------------------------------------

func _draw() -> void:
	match scene_id:
		"battle":
			_battle()
		"morgrav":
			_morgrav()
		"pact":
			_pact()
		"letter":
			_letter()
		"north":
			_north()
		_:
			_title()


func _battle() -> void:
	var w: float = size.x
	var h: float = size.y
	_sky([Color(0.22, 0.04, 0.08), Color(0.36, 0.07, 0.1), Color(0.55, 0.14, 0.12), Color(0.75, 0.3, 0.14), Color(0.9, 0.5, 0.2), Color(0.98, 0.7, 0.32)], 0, h * 0.5)
	var sun := Vector2(w * 0.5, h * 0.46)
	draw_circle(sun, 30, Color(1.0, 0.85, 0.5))
	for k in 3:
		draw_circle(sun, 34.0 + k * 6.0, Color(1, 0.7, 0.4, 0.12))
	_mountains(h * 0.48, 18, Color(0.3, 0.08, 0.1), 3)
	_mountains(h * 0.52, 10, Color(0.18, 0.05, 0.07), 9)
	draw_rect(Rect2(0, h * 0.52, w, h * 0.48), Color(0.1, 0.04, 0.05))
	# ruine în flăcări în depărtare
	for i in 3:
		var p := Vector2(30.0 + i * 85.0, h * 0.53)
		draw_rect(Rect2(p + Vector2(-8, -12), Vector2(16, 12)), Color(0.08, 0.03, 0.04))
		_fire(p + Vector2(0, -12), 1.0)
	# sulițe, steaguri, căști căzute
	_rng.seed = 11
	for i in 14:
		var x: float = _rng.randf() * w
		var base_y: float = h * (0.6 + _rng.randf() * 0.25)
		var top := Vector2(x + (_rng.randf() - 0.5) * 16.0, base_y - 25.0 - _rng.randf() * 25.0)
		draw_line(Vector2(x, base_y), top, Color(0.05, 0.02, 0.03), 1.0)
		if i % 3 == 0:
			var wave: float = sin(_t * 3.0 + i) * 2.0
			draw_colored_polygon(PackedVector2Array([top, top + Vector2(14, 3 + wave), top + Vector2(10, 8), top + Vector2(0, 10)]), Color(0.5, 0.07, 0.09))
		if i % 4 == 1:
			draw_circle(Vector2(x + 6, base_y - 1), 3.0, Color(0.32, 0.3, 0.34))
	# corbi
	for i in 6:
		var cx: float = fmod(_t * (10.0 + i * 3.0) + i * 50.0, w + 30.0) - 15.0
		var cy: float = h * 0.12 + i * 14.0 + sin(_t * 2.0 + i) * 3.0
		var flap: float = 3.0 * sin(_t * 10.0 + i)
		draw_line(Vector2(cx - 5, cy - flap), Vector2(cx, cy), Color(0.05, 0.02, 0.03), 1.0)
		draw_line(Vector2(cx, cy), Vector2(cx + 5, cy - flap), Color(0.05, 0.02, 0.03), 1.0)
	_embers(Color(1.0, 0.6, 0.25), 30)


func _morgrav() -> void:
	var w: float = size.x
	var h: float = size.y
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.04, 0.01, 0.06))
	# coloane de piatră
	for x in [w * 0.08, w * 0.92]:
		draw_rect(Rect2(x - 12, 0, 24, h), Color(0.09, 0.05, 0.12))
		draw_rect(Rect2(x - 12, 0, 4, h), Color(0.13, 0.08, 0.17))
		for k in 8:
			draw_rect(Rect2(x - 12, k * 56.0, 24, 2), Color(0.05, 0.02, 0.07))
	var cx: float = w * 0.5
	var pulse: float = 0.6 + 0.4 * sin(_t * 2.5)
	for k in 4:
		draw_circle(Vector2(cx, h * 0.3), 110.0 - k * 22.0, Color(0.45, 0.12, 0.7, 0.06 * pulse))
	# Morgrav: mantie, umeri cu cranii, coroană, ochi
	var dark := Color(0.02, 0.0, 0.03)
	draw_colored_polygon(PackedVector2Array([Vector2(cx - 95, h * 0.9), Vector2(cx - 55, h * 0.38), Vector2(cx - 18, h * 0.2), Vector2(cx + 18, h * 0.2), Vector2(cx + 55, h * 0.38), Vector2(cx + 95, h * 0.9)]), dark)
	for side in [-1, 1]:
		var sp := Vector2(cx + side * 46.0, h * 0.37)
		draw_circle(sp, 9, Color(0.75, 0.72, 0.65))
		draw_rect(Rect2(sp + Vector2(-5, -2), Vector2(3, 3)), dark)
		draw_rect(Rect2(sp + Vector2(2, -2), Vector2(3, 3)), dark)
	for i in 5:
		var x: float = cx - 16.0 + i * 8.0
		draw_colored_polygon(PackedVector2Array([Vector2(x - 3, h * 0.21), Vector2(x, h * 0.17 - float(i % 2) * 6.0), Vector2(x + 3, h * 0.21)]), Color(0.55, 0.45, 0.2))
	for side in [-1, 1]:
		var e := Vector2(cx + side * 8.0, h * 0.27)
		draw_circle(e, 6.0, Color(1.0, 0.1, 0.15, 0.3 * pulse))
		draw_rect(Rect2(e + Vector2(-3, -1), Vector2(6, 3)), Color(1.0, 0.25, 0.2))
		draw_rect(Rect2(e + Vector2(-1, 0), Vector2(2, 1)), Color(1, 0.9, 0.7))
	# fum și flăcări violet
	for i in 16:
		var x: float = float(i) * w / 15.0
		var fh: float = 18.0 + 10.0 * sin(_t * 6.0 + i * 1.7)
		draw_colored_polygon(PackedVector2Array([Vector2(x - 8, h), Vector2(x, h - fh), Vector2(x + 8, h)]), Color(0.55, 0.2, 0.9, 0.85))
		draw_colored_polygon(PackedVector2Array([Vector2(x - 4, h), Vector2(x, h - fh * 0.6), Vector2(x + 4, h)]), Color(0.9, 0.65, 1.0))
	_embers(Color(0.8, 0.5, 1.0), 26)


func _pact() -> void:
	var w: float = size.x
	var h: float = size.y
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.07, 0.02, 0.07))
	var c := Vector2(w * 0.5, h * 0.4)
	var pulse: float = 0.5 + 0.5 * sin(_t * 4.0)
	# vârtej în fundal
	for i in 40:
		var a: float = float(i) * 0.6 + _t * 0.8
		var r: float = 20.0 + float(i) * 3.0
		draw_rect(Rect2((c + Vector2.from_angle(a) * r).floor(), Vector2(2, 2)), Color(0.5, 0.2, 0.7, 0.5))
	var hand := [
		"..##.##.##....",
		"..##.##.##.##.",
		"..##.##.##.##.",
		"..##.##.##.##.",
		"..##########.#",
		".###########.#",
		"#############.",
		"#############.",
		".###########..",
		"..#########...",
		"...#######....",
		"...#######....",
		"...#######....",
		"...#######....",
	]
	var px: float = 6.0
	var origin := c - Vector2(7 * px, 5 * px)
	for y in hand.size():
		var row: String = hand[y]
		for x in row.length():
			if row[x] == "#":
				var col := Color(0.86, 0.67, 0.53)
				if x == 0 or row[x - 1] != "#" or y == 0:
					col = Color(0.96, 0.8, 0.66)
				elif x + 1 >= row.length() or row[x + 1] != "#":
					col = Color(0.66, 0.46, 0.38)
				draw_rect(Rect2(origin + Vector2(x * px, y * px), Vector2(px, px)), col)
	var sc := c + Vector2(0, 14)
	draw_arc(sc, 22.0, 0.0, TAU, 24, Color(0.1, 0.0, 0.1), 4.0)
	draw_arc(sc, 22.0, 0.0, TAU, 24, Color(0.75, 0.3, 1.0, 0.6 + 0.4 * pulse), 2.0)
	for i in 5:
		var a: float = -PI * 0.5 + TAU * float(i) * 2.0 / 5.0
		var b: float = -PI * 0.5 + TAU * float(i + 1) * 2.0 / 5.0
		draw_line(sc + Vector2.from_angle(a) * 18.0, sc + Vector2.from_angle(b) * 18.0, Color(0.85, 0.5, 1.0), 1.0)
	for i in 30:
		var a: float = float(i) * 1.7 + _t * 2.0
		var r: float = fmod(_t * 40.0 + i * 13.0, 90.0)
		draw_rect(Rect2((sc + Vector2.from_angle(a) * r).floor(), Vector2(2, 2)), Color(0.9, 0.6, 1.0, 1.0 - r / 90.0))


func _letter() -> void:
	var w: float = size.x
	var h: float = size.y
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.15, 0.09, 0.06))
	# fereastra cu lună și zăpadă
	var win := Rect2(w * 0.08, h * 0.05, w * 0.36, h * 0.2)
	draw_rect(win.grow(3), Color(0.3, 0.18, 0.1))
	draw_rect(win, Color(0.06, 0.08, 0.16))
	draw_circle(win.position + Vector2(win.size.x * 0.7, 14), 7, Color(0.95, 0.92, 0.8))
	for i in 12:
		var sx: float = win.position.x + fmod(float(i * 13) + _t * 5.0, win.size.x)
		var sy: float = win.position.y + fmod(float(i * 7) + _t * 12.0, win.size.y)
		draw_rect(Rect2(sx, sy, 1, 1), Color.WHITE)
	draw_rect(Rect2(win.position.x + win.size.x * 0.5 - 1, win.position.y, 2, win.size.y), Color(0.3, 0.18, 0.1))
	draw_rect(Rect2(win.position.x, win.position.y + win.size.y * 0.5 - 1, win.size.x, 2), Color(0.3, 0.18, 0.1))
	# masa
	draw_rect(Rect2(0, h * 0.32, w, h * 0.68), Color(0.32, 0.19, 0.1))
	for i in 7:
		draw_rect(Rect2(0, h * 0.32 + i * 40.0, w, 1), Color(0.24, 0.14, 0.07))
	var flick: float = 0.8 + 0.2 * sin(_t * 11.0) * sin(_t * 7.0)
	var cp := Vector2(w * 0.82, h * 0.3)
	draw_circle(cp, 50.0, Color(1.0, 0.7, 0.3, 0.1 * flick))
	draw_rect(Rect2(cp.x - 4, cp.y, 8, 30), Color(0.92, 0.88, 0.78))
	draw_colored_polygon(PackedVector2Array([cp + Vector2(-3, 0), cp + Vector2(0, -12 * flick), cp + Vector2(3, 0)]), Color(1.0, 0.8, 0.3))
	# călimara și pana
	draw_rect(Rect2(w * 0.1, h * 0.36, 14, 12), Color(0.1, 0.1, 0.15))
	draw_line(Vector2(w * 0.1 + 7, h * 0.36), Vector2(w * 0.1 + 20, h * 0.27), Color(0.95, 0.95, 0.9), 2.0)
	# scrisoarea
	var r := Rect2(w * 0.15, h * 0.38, w * 0.62, h * 0.36)
	draw_rect(r.grow(2), Color(0.45, 0.3, 0.16))
	draw_rect(r, Color(0.93, 0.85, 0.66))
	for i in 10:
		var ly: float = r.position.y + 12.0 + i * 12.0
		var lw: float = r.size.x - 22.0 - float((i * 53) % 40)
		for x in range(0, int(lw), 3):
			if (x * 7 + i) % 11 != 0:
				draw_rect(Rect2(r.position.x + 10 + x, ly, 2, 1), Color(0.3, 0.18, 0.12))
	draw_rect(Rect2(r.position.x + 20, r.end.y - 40, 26, 6), Color(0.6, 0.08, 0.1, 0.6))
	var s := Vector2(r.end.x - 20, r.end.y - 16)
	draw_circle(s, 11.0, Color(0.65, 0.08, 0.1))
	draw_circle(s, 7.0, Color(0.8, 0.15, 0.15))
	draw_rect(Rect2(s.x - 1, s.y - 5, 2, 10), Color(0.5, 0.05, 0.08))
	draw_rect(Rect2(s.x - 5, s.y - 1, 10, 2), Color(0.5, 0.05, 0.08))


func _north() -> void:
	var w: float = size.x
	var h: float = size.y
	_sky([Color(0.02, 0.03, 0.08), Color(0.04, 0.06, 0.13), Color(0.08, 0.1, 0.18), Color(0.14, 0.12, 0.2), Color(0.22, 0.14, 0.2)], 0, h * 0.55)
	_stars(50, h * 0.35)
	_mountains(h * 0.45, 50, Color(0.1, 0.11, 0.18), 21, true)
	_mountains(h * 0.55, 22, Color(0.07, 0.08, 0.12), 5, true)
	# castelul boierului
	var cp := Vector2(w * 0.3, h * 0.43)
	var dark := Color(0.04, 0.04, 0.07)
	draw_rect(Rect2(cp + Vector2(-20, -20), Vector2(40, 22)), dark)
	draw_rect(Rect2(cp + Vector2(-26, -36), Vector2(9, 38)), dark)
	draw_rect(Rect2(cp + Vector2(16, -42), Vector2(10, 44)), dark)
	draw_colored_polygon(PackedVector2Array([cp + Vector2(-28, -36), cp + Vector2(-21, -48), cp + Vector2(-15, -36)]), dark)
	draw_colored_polygon(PackedVector2Array([cp + Vector2(14, -42), cp + Vector2(21, -56), cp + Vector2(28, -42)]), dark)
	draw_rect(Rect2(cp + Vector2(19, -32), Vector2(2, 3)), Color(1.0, 0.5, 0.2))
	draw_rect(Rect2(0, h * 0.58, w, h * 0.42), Color(0.08, 0.08, 0.12))
	# drumul
	draw_colored_polygon(PackedVector2Array([Vector2(w * 0.45, h * 0.58), Vector2(w * 0.55, h * 0.58), Vector2(w * 0.95, h), Vector2(w * 0.55, h)]), Color(0.16, 0.15, 0.2))
	# sate în flăcări
	for i in 4:
		var p := Vector2(20.0 + i * 60.0, h * 0.62 + float((i * 29) % 30))
		draw_rect(Rect2(p + Vector2(-8, -6), Vector2(16, 8)), dark)
		draw_colored_polygon(PackedVector2Array([p + Vector2(-10, -6), p + Vector2(0, -14), p + Vector2(10, -6)]), dark)
		_fire(p + Vector2(-2, -8), 1.2)
	for i in 70:
		var x: float = fmod(float(i * 97) + _t * 8.0 * float(1 + i % 3), w)
		var y: float = fmod(float(i * 53) + _t * 20.0 * float(1 + i % 2), h)
		draw_rect(Rect2(Vector2(x, y).floor(), Vector2.ONE), Color(0.9, 0.92, 1.0, 0.8))


func _title() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.01, 0.03))
	var c: Vector2 = size * 0.5
	var pulse: float = 0.5 + 0.5 * sin(_t * 2.0)
	for k in 5:
		draw_circle(c, 100.0 - k * 16.0, Color(0.6, 0.15, 0.2, 0.06 * pulse))
	_embers(Color(1.0, 0.4, 0.3), 30)
