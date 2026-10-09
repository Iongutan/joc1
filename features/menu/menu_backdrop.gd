class_name MenuBackdrop
extends Control
## Fundalul meniului: cer de noapte cu dithering, lună, nori, lilieci, munți,
## castelul lui Vlaskar, satul cu ferestre aprinse, pădure și ceață.
## Se desenează într-un PixelCanvas (rezoluție mică), ca totul să fie pixel art.

var _t: float = 0.0
var _last_frame: int = -1
## Mărimea virtuală (720 de unități lățime); desenul e scalat la rezoluția mică.
var _vs := Vector2(720, 1280)


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	_t += delta
	var f: int = int(_t * 12.0)
	if f != _last_frame:
		_last_frame = f
		queue_redraw()


func _draw() -> void:
	var k: float = size.x / 720.0
	if k <= 0.0:
		return
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(k, k))
	_vs = size / k
	var w: float = _vs.x
	var h: float = _vs.y

	# cer în benzi, cu tranziții în dithering
	var sky := [Color(0.03, 0.05, 0.11), Color(0.05, 0.08, 0.16), Color(0.08, 0.11, 0.2), Color(0.12, 0.14, 0.24), Color(0.2, 0.17, 0.26)]
	var band: float = h * 0.55 / sky.size()
	for i in sky.size():
		draw_rect(Rect2(0, i * band, w, band + 1), sky[i])
		if i + 1 < sky.size():
			var y: float = (i + 1) * band - 6.0
			for x in range(0, int(w), 6):
				draw_rect(Rect2(x + (3 if int(x / 6.0) % 2 == 0 else 0), y, 3, 3), sky[i + 1])
	draw_rect(Rect2(0, h * 0.55, w, h * 0.45), Color(0.03, 0.04, 0.06))

	# stele
	for i in 80:
		var sx: float = fmod(float(i * 137) * 7.3, w)
		var sy: float = fmod(float(i * 89) * 3.1, h * 0.45)
		var tw: float = 0.5 + 0.5 * sin(_t * 2.0 + float(i))
		draw_rect(Rect2(sx, sy, 3, 3), Color(1, 0.95, 0.85, 0.3 + tw * 0.6))

	# luna, cu halou
	var moon := Vector2(w * 0.72, h * 0.17)
	for r in 5:
		draw_circle(moon, 70.0 + r * 22.0, Color(0.95, 0.9, 0.7, 0.05))
	draw_circle(moon, 62.0, Color(0.97, 0.94, 0.8))
	draw_circle(moon + Vector2(-14, -10), 12.0, Color(0.86, 0.83, 0.7))
	draw_circle(moon + Vector2(18, 16), 8.0, Color(0.86, 0.83, 0.7))
	draw_circle(moon + Vector2(20, -22), 6.0, Color(0.86, 0.83, 0.7))

	# nori care trec prin fața lunii
	for c in 3:
		var cx: float = fmod(_t * (8.0 + c * 5.0) + c * 260.0, w + 300.0) - 150.0
		var cy: float = h * (0.12 + c * 0.05)
		draw_rect(Rect2(cx - 90, cy, 180, 12), Color(0.1, 0.12, 0.2, 0.9))
		draw_rect(Rect2(cx - 60, cy - 10, 110, 12), Color(0.13, 0.15, 0.24, 0.9))
		draw_rect(Rect2(cx - 60, cy + 12, 150, 4), Color(0.06, 0.07, 0.12, 0.9))

	_bats()
	_ridge(h * 0.5, 90.0, 0.011, Color(0.08, 0.1, 0.17), 1.0)
	_castle(Vector2(w * 0.3, h * 0.47))
	_ridge(h * 0.56, 60.0, 0.018, Color(0.05, 0.07, 0.11), 2.0)
	_village(h * 0.64)
	_forest(h * 0.64, Color(0.02, 0.04, 0.05))

	# ceață care se mișcă
	for c in 4:
		var fy: float = h * (0.55 + 0.04 * c)
		var fx: float = fmod(_t * (12.0 + c * 6.0), w + 400.0) - 200.0
		draw_circle(Vector2(fx, fy), 160.0, Color(0.6, 0.65, 0.75, 0.05))
		draw_circle(Vector2(fx - w * 0.6, fy + 20.0), 200.0, Color(0.6, 0.65, 0.75, 0.04))


func _ridge(base_y: float, amp: float, freq: float, col: Color, seed_off: float) -> void:
	var pts := PackedVector2Array()
	var w: float = _vs.x
	pts.append(Vector2(0, _vs.y))
	var x: float = 0.0
	while x <= w + 16.0:
		var y: float = base_y - amp * (0.5 + 0.5 * sin(x * freq + seed_off) * cos(x * freq * 0.37 + seed_off * 2.0))
		pts.append(Vector2(x, floorf(y / 6.0) * 6.0))
		x += 18.0
	pts.append(Vector2(w, _vs.y))
	draw_colored_polygon(pts, col)


func _castle(base: Vector2) -> void:
	var c := Color(0.04, 0.05, 0.09)
	draw_rect(Rect2(base + Vector2(-70, -70), Vector2(140, 80)), c)
	draw_rect(Rect2(base + Vector2(-90, -130), Vector2(34, 140)), c)
	draw_rect(Rect2(base + Vector2(50, -150), Vector2(36, 160)), c)
	draw_rect(Rect2(base + Vector2(-20, -190), Vector2(40, 130)), c)
	draw_colored_polygon(PackedVector2Array([base + Vector2(-94, -130), base + Vector2(-73, -170), base + Vector2(-52, -130)]), c)
	draw_colored_polygon(PackedVector2Array([base + Vector2(46, -150), base + Vector2(68, -196), base + Vector2(90, -150)]), c)
	draw_colored_polygon(PackedVector2Array([base + Vector2(-24, -190), base + Vector2(0, -250), base + Vector2(24, -190)]), c)
	# creneluri
	for i in 7:
		draw_rect(Rect2(base + Vector2(-70 + i * 21, -82), Vector2(12, 12)), c)
	# steag pe turnul principal
	var wave: float = sin(_t * 4.0) * 4.0
	draw_rect(Rect2(base + Vector2(-2, -290), Vector2(4, 42)), c)
	draw_colored_polygon(PackedVector2Array([base + Vector2(2, -290), base + Vector2(40, -282 + wave), base + Vector2(2, -270)]), Color(0.5, 0.08, 0.12))
	var flicker: float = 0.75 + 0.25 * sin(_t * 5.0)
	var win := Color(1.0, 0.55, 0.2, flicker)
	for p in [Vector2(-78, -100), Vector2(62, -120), Vector2(-6, -160), Vector2(-6, -120), Vector2(-40, -40), Vector2(30, -40)]:
		draw_rect(Rect2(base + p, Vector2(9, 12)), win)


## Satul de la marginea pădurii: case cu ferestre aprinse și fum din hornuri.
func _village(base_y: float) -> void:
	var dark := Color(0.04, 0.03, 0.05)
	for i in 4:
		var x: float = 380.0 + i * 82.0
		var hh: float = 46.0 + float((i * 17) % 20)
		draw_rect(Rect2(x, base_y - hh, 64, hh + 10), dark)
		draw_colored_polygon(PackedVector2Array([Vector2(x - 8, base_y - hh), Vector2(x + 32, base_y - hh - 34), Vector2(x + 72, base_y - hh)]), Color(0.08, 0.05, 0.06))
		draw_rect(Rect2(x + 46, base_y - hh - 30, 10, 22), dark)
		var fl: float = 0.7 + 0.3 * sin(_t * 6.0 + i)
		draw_circle(Vector2(x + 19, base_y - hh + 21), 26.0, Color(1.0, 0.6, 0.2, 0.08 * fl))
		draw_rect(Rect2(x + 12, base_y - hh + 14, 15, 15), Color(1.0, 0.65, 0.25, fl))
		draw_rect(Rect2(x + 18, base_y - hh + 14, 3, 15), dark)
		draw_rect(Rect2(x + 12, base_y - hh + 20, 15, 3), dark)
		for s in 4:
			var sy: float = base_y - hh - 40.0 - fmod(_t * 16.0 + s * 20.0 + i * 9.0, 80.0)
			var sx: float = x + 51.0 + sin(_t + s + i) * 8.0
			draw_circle(Vector2(sx, sy), 7.0 + s, Color(0.5, 0.5, 0.6, 0.12))


## Lilieci care zboară pe cer.
func _bats() -> void:
	for i in 5:
		var bx: float = fmod(_t * (40.0 + i * 9.0) + i * 160.0, _vs.x + 100.0) - 50.0
		var by: float = _vs.y * (0.1 + i * 0.045) + sin(_t * 3.0 + i) * 20.0
		var flap: float = 10.0 * sin(_t * 14.0 + i)
		var c := Color(0.02, 0.02, 0.04)
		draw_colored_polygon(PackedVector2Array([Vector2(bx, by), Vector2(bx - 18, by - flap), Vector2(bx - 8, by + 4)]), c)
		draw_colored_polygon(PackedVector2Array([Vector2(bx, by), Vector2(bx + 18, by - flap), Vector2(bx + 8, by + 4)]), c)
		draw_circle(Vector2(bx, by + 2), 4.0, c)


func _forest(base_y: float, col: Color) -> void:
	var w: float = _vs.x
	draw_rect(Rect2(0, base_y, w, _vs.y - base_y), col)
	var x: float = -20.0
	var i: int = 0
	while x < w + 40.0:
		var th: float = 90.0 + float((i * 53) % 70)
		var tw: float = 40.0 + float((i * 31) % 24)
		draw_colored_polygon(PackedVector2Array([
			Vector2(x - tw * 0.5, base_y + 10), Vector2(x, base_y - th), Vector2(x + tw * 0.5, base_y + 10)]), col)
		# licurici printre copaci
		if i % 3 == 0:
			var a: float = 0.5 + 0.5 * sin(_t * 3.0 + i)
			draw_rect(Rect2(x + 10, base_y - 30.0 + sin(_t + i) * 10.0, 4, 4), Color(0.8, 1.0, 0.5, a))
		x += 34.0 + float((i * 17) % 20)
		i += 1
