class_name PactSigil
extends Control
## Semnul Pactului: cerc de rune care se rotește încet și pulsează în violet.

var _t: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	_t += delta
	queue_redraw()


func _draw() -> void:
	var c: Vector2 = size * 0.5
	var r: float = minf(size.x, size.y) * 0.45
	var pulse: float = 0.6 + 0.4 * sin(_t * 1.6)
	var glow := Color(0.6, 0.35, 1.0)
	for k in 4:
		draw_circle(c, r * (1.15 - k * 0.08), Color(glow.r, glow.g, glow.b, 0.04 * pulse))
	draw_arc(c, r, 0.0, TAU, 64, Color(glow, 0.8 * pulse), 3.0)
	draw_arc(c, r * 0.78, 0.0, TAU, 64, Color(glow, 0.5 * pulse), 2.0)
	# rune pe cerc
	for i in 12:
		var a: float = _t * 0.25 + TAU * float(i) / 12.0
		var p: Vector2 = c + Vector2.from_angle(a) * r * 0.89
		var d: Vector2 = Vector2.from_angle(a + PI * 0.5) * 6.0
		draw_line(p - d, p + d, Color(1.0, 0.85, 0.5, 0.9 * pulse), 2.0)
		draw_line(p, p + Vector2.from_angle(a) * 6.0, Color(1.0, 0.85, 0.5, 0.9 * pulse), 2.0)
	# steaua interioară
	var pts := PackedVector2Array()
	for i in 6:
		pts.append(c + Vector2.from_angle(-_t * 0.4 + TAU * float(i) / 5.0 * 2.0) * r * 0.7)
	draw_polyline(pts, Color(0.85, 0.5, 1.0, 0.7 * pulse), 2.0)
	# ochiul din centru
	draw_circle(c, r * 0.14, Color(0.9, 0.2, 0.25, 0.9))
	draw_circle(c, r * 0.06, Color(1.0, 0.9, 0.7))
