class_name SuperCutIn
extends CanvasLayer
## Scena scurtă la activarea super-puterii: bandă diagonală, portretul eroului
## care intră în cadru și numele puterii (stil anime, ca în jocurile de gen).

var _band: Control
var _portrait: HeroPortrait
var _title: Label
var _t: float = 0.0


func _ready() -> void:
	layer = 8
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = UiTheme.get_theme()
	add_child(root)
	_band = Control.new()
	_band.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_band.draw.connect(_draw_band)
	root.add_child(_band)
	_portrait = HeroPortrait.new()
	_portrait.setup(Save.hero)
	_portrait.size = HeroArt.texture(Save.hero, "attack", true).get_size() * 4.0
	root.add_child(_portrait)
	_title = Label.new()
	_title.add_theme_font_size_override("font_size", 48)
	_title.add_theme_color_override("font_color", UiTheme.GOLD_BRIGHT)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_title.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_title.offset_left = -340
	_title.offset_right = 320
	_title.offset_top = 150
	root.add_child(_title)


func play(hero_id: String, power_name: String) -> void:
	visible = true
	_t = 0.0
	_portrait.set_hero(hero_id)
	_portrait.play("super")
	_portrait.size = HeroArt.texture(hero_id, "attack", true).get_size() * 4.0
	_title.text = power_name
	var y: float = 640.0 - _portrait.size.y * 0.55
	_portrait.position = Vector2(-_portrait.size.x, y)
	_title.modulate.a = 0.0
	var tw := create_tween()
	tw.set_ignore_time_scale(true)
	tw.tween_property(_portrait, "position:x", 30.0, 0.18).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.parallel().tween_property(_title, "modulate:a", 1.0, 0.15)
	tw.tween_interval(0.55)
	tw.tween_property(_portrait, "position:x", 760.0, 0.16).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(_title, "modulate:a", 0.0, 0.16)
	tw.tween_callback(func() -> void: visible = false)


func _process(delta: float) -> void:
	if visible:
		_t += delta
		_band.queue_redraw()


func _draw_band() -> void:
	var w: float = _band.size.x
	var cy: float = 640.0
	var grow: float = minf(_t * 8.0, 1.0)
	var h: float = 260.0 * grow
	var pts := PackedVector2Array([Vector2(0, cy - h * 0.5 + 60), Vector2(w, cy - h * 0.5 - 60), Vector2(w, cy + h * 0.5 - 60), Vector2(0, cy + h * 0.5 + 60)])
	_band.draw_rect(Rect2(Vector2.ZERO, _band.size), Color(0, 0, 0, 0.45 * grow))
	_band.draw_colored_polygon(pts, Color(0.12, 0.04, 0.18, 0.95))
	# linii de viteză
	for i in 14:
		var y: float = cy - 110.0 + float(i) * 17.0
		var x: float = fmod(_t * 2200.0 + float(i * 97), w + 300.0) - 150.0
		_band.draw_line(Vector2(w - x, y - 40), Vector2(w - x + 140, y - 46), Color(1.0, 0.85, 0.5, 0.5), 3.0)
	_band.draw_line(pts[0], pts[1], Color(1.0, 0.8, 0.35), 5.0)
	_band.draw_line(pts[3], pts[2], Color(1.0, 0.8, 0.35), 5.0)
