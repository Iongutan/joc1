class_name Effects
extends Node2D
## Efecte vizuale reutilizate (fără creare și ștergere în timpul luptei):
## cifre de damage, explozii la moartea monștrilor, bliț pe ecran.

const MAX_NUMBERS: int = 36
const MAX_BURSTS: int = 10

var _numbers: Array[Label] = []
var _num_life: PackedFloat32Array
var _num_vel: PackedVector2Array
var _num_next: int = 0
var _bursts: Array[CPUParticles2D] = []
var _burst_next: int = 0
var _was_drawing: bool = false
var _rings: Array = []  # [poziție, rază, culoare, timp rămas]


func _ready() -> void:
	z_index = 20
	material = UiTheme.glow_material()
	_num_life.resize(MAX_NUMBERS)
	_num_vel.resize(MAX_NUMBERS)
	var font := PixelFont.get_font_outlined()
	for i in MAX_NUMBERS:
		var l := Label.new()
		l.add_theme_font_override("font", font)
		l.add_theme_font_size_override("font_size", 12)
		l.material = UiTheme.glow_material()
		l.visible = false
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.size = Vector2(60, 16)
		l.pivot_offset = Vector2(30, 8)
		add_child(l)
		_numbers.append(l)
	for i in MAX_BURSTS:
		var p := CPUParticles2D.new()
		p.emitting = false
		p.one_shot = true
		p.explosiveness = 1.0
		p.amount = 14
		p.lifetime = 0.5
		p.spread = 180.0
		p.initial_velocity_min = 30.0
		p.initial_velocity_max = 90.0
		p.gravity = Vector2(0, 120)
		p.scale_amount_min = 1.0
		p.scale_amount_max = 2.0
		p.material = UiTheme.glow_material()
		add_child(p)
		_bursts.append(p)
	Events.enemy_hit.connect(_on_hit)


func _on_hit(at: Vector2, amount: float) -> void:
	var i: int = _num_next
	_num_next = (_num_next + 1) % MAX_NUMBERS
	var l: Label = _numbers[i]
	l.text = str(int(ceilf(amount)))
	var big: bool = amount >= 40.0
	l.modulate = Color(1.0, 0.85, 0.3) if big else Color(1, 1, 1)
	l.scale = Vector2.ONE * (1.5 if big else 1.0)
	l.position = at - Vector2(30, 26) + Vector2(randf_range(-4, 4), 0)
	l.visible = true
	_num_life[i] = 0.55
	_num_vel[i] = Vector2(randf_range(-10, 10), -46)


func burst(at: Vector2, col: Color, count: int = 14) -> void:
	var p: CPUParticles2D = _bursts[_burst_next]
	_burst_next = (_burst_next + 1) % MAX_BURSTS
	p.position = at
	p.amount = count
	p.color = col
	p.restart()
	p.emitting = true


## Inel de explozie care se extinde și dispare.
func ring(at: Vector2, radius: float, col: Color) -> void:
	_rings.append([at, radius, col, 0.3])


func _draw() -> void:
	for r in _rings:
		var k: float = 1.0 - r[3] / 0.3
		var c: Color = r[2]
		draw_circle(r[0], r[1] * (0.4 + k * 0.6), Color(c.r, c.g, c.b, 0.35 * (1.0 - k)))
		draw_arc(r[0], r[1] * (0.5 + k * 0.6), 0.0, TAU, 28, Color(c.r, c.g, c.b, 1.0 - k), 2.0)


func _process(delta: float) -> void:
	if not _rings.is_empty():
		for r in _rings:
			r[3] -= delta
		_rings = _rings.filter(func(r): return r[3] > 0.0)
		queue_redraw()
	elif _was_drawing:
		queue_redraw()
	_was_drawing = not _rings.is_empty()
	for i in MAX_NUMBERS:
		if _num_life[i] <= 0.0:
			continue
		_num_life[i] -= delta
		var l: Label = _numbers[i]
		l.position += _num_vel[i] * delta
		_num_vel[i].y += 90.0 * delta
		l.modulate.a = clampf(_num_life[i] * 4.0, 0.0, 1.0)
		if _num_life[i] <= 0.0:
			l.visible = false
