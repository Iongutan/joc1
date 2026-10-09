class_name TouchStick
extends Control
## Joystick virtual: apare oriunde atingi ecranul (în afara butoanelor).

const RADIUS: float = 80.0

var output := Vector2.ZERO
## Butoanele peste care joystick-ul nu pornește (super, pauză).
var blocked: Array[Control] = []
var _index: int = -1
var _base := Vector2.ZERO
var _knob := Vector2.ZERO


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _input(event: InputEvent) -> void:
	var t := event as InputEventScreenTouch
	if t != null:
		if t.pressed and _index == -1 and t.position.y > 170.0 and not _is_blocked(t.position):
			_index = t.index
			_base = t.position
			_knob = _base
			output = Vector2.ZERO
			queue_redraw()
		elif not t.pressed and t.index == _index:
			release()
		return
	var d := event as InputEventScreenDrag
	if d != null and d.index == _index:
		var off: Vector2 = (d.position - _base).limit_length(RADIUS)
		_knob = _base + off
		output = off / RADIUS
		queue_redraw()


func _is_blocked(p: Vector2) -> bool:
	for c in blocked:
		if c.is_visible_in_tree() and c.get_global_rect().has_point(p):
			return true
	return false


func release() -> void:
	_index = -1
	output = Vector2.ZERO
	queue_redraw()


func _draw() -> void:
	if _index == -1:
		return
	draw_circle(_base, RADIUS, Color(0.1, 0.05, 0.15, 0.35))
	draw_arc(_base, RADIUS, 0.0, TAU, 48, Color(0.95, 0.8, 0.45, 0.5), 4.0)
	draw_circle(_knob, 32.0, Color(0.95, 0.85, 0.55, 0.55))
	draw_arc(_knob, 32.0, 0.0, TAU, 32, Color(0.3, 0.2, 0.1, 0.6), 3.0)
