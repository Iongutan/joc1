class_name Ground
extends Node2D
## Pământul nesfârșit al capitolului: desenează doar ce e vizibil în jurul camerei.
## Fiecare capitol are alte culori și alte decoruri; cele care strălucesc sunt pe un strat
## separat, neafectat de întuneric.

const TILE: float = 32.0

var chapter: Dictionary = Chapters.get_chapter(0)
var _ground: Array[Color] = []
var _glow_cols: Array[Color] = []
var _glow: Node2D
var _t: float = 0.0
var _last_rect := Rect2i()


func setup(ch: Dictionary) -> void:
	chapter = ch


func _ready() -> void:
	z_index = -10
	for h in chapter["ground"]:
		_ground.append(Pixel.c(h))
	for h in chapter["glow"]:
		_glow_cols.append(Pixel.c(h))
	_glow = Node2D.new()
	_glow.z_as_relative = false
	_glow.z_index = -9
	_glow.material = UiTheme.glow_material()
	_glow.draw.connect(_draw_glow)
	add_child(_glow)


func _process(delta: float) -> void:
	_t += delta
	# redesenăm doar când camera intră în dale noi; strălucirea pulsează prin culoare
	var r := _visible_tiles()
	if r != _last_rect:
		_last_rect = r
		queue_redraw()
		_glow.queue_redraw()
	_glow.modulate.a = 0.8 + 0.2 * sin(_t * 2.0)


static func _h(x: int, y: int) -> int:
	return absi((x * 374761393 + y * 668265263) ^ (x * y * 2147483647)) % 1000


func _visible_tiles() -> Rect2i:
	var cam := get_viewport().get_camera_2d()
	if cam == null:
		return Rect2i()
	var center: Vector2 = cam.get_screen_center_position()
	var half: Vector2 = get_viewport_rect().size * 0.5 / cam.zoom + Vector2(TILE * 2, TILE * 2)
	var x0: int = floori((center.x - half.x) / TILE)
	var y0: int = floori((center.y - half.y) / TILE)
	var x1: int = floori((center.x + half.x) / TILE)
	var y1: int = floori((center.y + half.y) / TILE)
	return Rect2i(x0, y0, x1 - x0 + 1, y1 - y0 + 1)


func _draw() -> void:
	var r := _visible_tiles()
	var props: Array = chapter["props"]
	for ty in range(r.position.y, r.end.y):
		for tx in range(r.position.x, r.end.x):
			var h: int = _h(tx, ty)
			var o := Vector2(tx * TILE, ty * TILE)
			draw_rect(Rect2(o, Vector2(TILE, TILE)), _ground[0] if h % 3 != 0 else _ground[2])
			# pete mai deschise, ca pământul să nu pară o tablă de șah
			if h % 5 == 0:
				draw_rect(Rect2(o + Vector2(float(h % 13), float(h % 11)), Vector2(14, 8)), _ground[1])
			if h < 150:
				_prop(props[h % props.size()], o + Vector2(float(h % 22) + 5.0, float(h % 19) + 8.0), h)


func _prop(kind: String, p: Vector2, h: int) -> void:
	p = p.floor()
	match kind:
		"grass":
			var g := _ground[1].lightened(0.25)
			draw_rect(Rect2(p, Vector2(1, 4)), g)
			draw_rect(Rect2(p + Vector2(2, -2), Vector2(1, 6)), g.lightened(0.1))
			draw_rect(Rect2(p + Vector2(4, 0), Vector2(1, 4)), g)
		"stone":
			draw_rect(Rect2(p, Vector2(6, 4)), Color(0.36, 0.35, 0.38))
			draw_rect(Rect2(p + Vector2(1, 0), Vector2(4, 1)), Color(0.48, 0.47, 0.5))
			draw_rect(Rect2(p + Vector2(0, 4), Vector2(6, 1)), Color(0.15, 0.14, 0.17))
		"grave":
			if h % 3 != 0:
				return
			draw_rect(Rect2(p + Vector2(-1, 9), Vector2(10, 2)), Color(0.1, 0.1, 0.12))
			draw_rect(Rect2(p, Vector2(8, 10)), Color(0.42, 0.42, 0.46))
			draw_rect(Rect2(p + Vector2(1, -2), Vector2(6, 2)), Color(0.42, 0.42, 0.46))
			draw_rect(Rect2(p + Vector2(3, 2), Vector2(2, 5)), Color(0.25, 0.25, 0.28))
			draw_rect(Rect2(p + Vector2(2, 3), Vector2(4, 1)), Color(0.25, 0.25, 0.28))
			draw_rect(Rect2(p + Vector2(7, 0), Vector2(1, 10)), Color(0.3, 0.3, 0.34))
		"flower":
			draw_rect(Rect2(p + Vector2(1, 2), Vector2(1, 3)), Color(0.3, 0.5, 0.25))
			draw_rect(Rect2(p, Vector2(3, 2)), Color(0.85, 0.3, 0.4) if h % 2 == 0 else Color(0.9, 0.85, 0.4))
		"tree":
			if h % 4 != 0:
				return
			var trunk := Color(0.22, 0.15, 0.12)
			draw_rect(Rect2(p + Vector2(4, 8), Vector2(4, 10)), trunk)
			var leaf := _ground[1].darkened(0.15)
			draw_colored_polygon(PackedVector2Array([p + Vector2(-4, 10), p + Vector2(6, -14), p + Vector2(16, 10)]), leaf)
			draw_colored_polygon(PackedVector2Array([p + Vector2(-2, 2), p + Vector2(6, -20), p + Vector2(14, 2)]), leaf.lightened(0.08))
			draw_rect(Rect2(p + Vector2(-4, 18), Vector2(20, 2)), Color(0, 0, 0, 0.3))
		"root":
			var rc := Color(0.25, 0.18, 0.13)
			draw_line(p, p + Vector2(8, 3), rc, 2.0)
			draw_line(p + Vector2(8, 3), p + Vector2(13, 1), rc, 2.0)
		"crack":
			var cc := _ground[2].darkened(0.4)
			draw_line(p, p + Vector2(5, 3), cc, 1.0)
			draw_line(p + Vector2(5, 3), p + Vector2(7, 8), cc, 1.0)
		"reed":
			var rd := Color(0.45, 0.5, 0.3)
			draw_rect(Rect2(p, Vector2(1, 8)), rd)
			draw_rect(Rect2(p + Vector2(2, -2), Vector2(1, 10)), rd)
			draw_rect(Rect2(p + Vector2(2, -4), Vector2(1, 3)), Color(0.4, 0.28, 0.18))
		"puddle":
			draw_rect(Rect2(p, Vector2(12, 5)), Color(0.12, 0.16, 0.18))
			draw_rect(Rect2(p + Vector2(2, 1), Vector2(4, 1)), Color(0.3, 0.38, 0.42))


func _draw_glow() -> void:
	var r := _visible_tiles()
	var props: Array = chapter["props"]
	for ty in range(r.position.y, r.end.y):
		for tx in range(r.position.x, r.end.x):
			var h: int = _h(tx * 3 + 7, ty * 5 + 11)
			if h >= 30:
				continue
			var o := (Vector2(tx * TILE, ty * TILE) + Vector2(float(h % 20) + 6.0, float(h % 18) + 7.0)).floor()
			var col: Color = _glow_cols[h % _glow_cols.size()]
			var pulse: float = 0.75 + 0.25 * float(h % 4) / 3.0
			_glow.draw_circle(o, 9.0, Color(col.r, col.g, col.b, 0.12 * pulse))
			if props.has("crystal") and h % 2 == 0:
				_glow.draw_colored_polygon(PackedVector2Array([o + Vector2(-2, 3), o + Vector2(0, -6), o + Vector2(2, 3)]), col)
				_glow.draw_colored_polygon(PackedVector2Array([o + Vector2(2, 3), o + Vector2(4, -2), o + Vector2(5, 3)]), col.lightened(0.3))
				_glow.draw_rect(Rect2(o + Vector2(-1, -4), Vector2(1, 4)), Color(1, 1, 1, 0.8))
			elif props.has("mushroom") and h % 2 == 1:
				_glow.draw_rect(Rect2(o + Vector2(-1, 0), Vector2(2, 4)), Color(0.85, 0.8, 0.7))
				_glow.draw_rect(Rect2(o + Vector2(-3, -2), Vector2(6, 2)), col)
				_glow.draw_rect(Rect2(o + Vector2(-2, -3), Vector2(4, 1)), col.lightened(0.3))
			else:
				# licurici așezat / floare luminoasă
				_glow.draw_rect(Rect2(o, Vector2(2, 2)), Color(col.r, col.g, col.b, pulse))
