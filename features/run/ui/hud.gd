class_name Hud
extends CanvasLayer
## Interfața din luptă (vertical): portretul eroului, inimile, experiența, timpul,
## bara boss-ului și butonul de super-putere.

signal super_pressed
signal pause_pressed

const HEART_SCALE: int = 3

var super_button: Control
var _super_face: HeroPortrait
var pause_button: Button

var _hearts: Control
var _xp_bar: ProgressBar
var _level_label: Label
var _time_label: Label
var _kills_label: Label
var _villagers_label: Label
var _debug_label: Label
var _boss_box: Control
var _boss_bar: ProgressBar
var _boss_name: Label
var _hero_id: String = "corvin"
var _hearts_now: int = 0
var _hearts_max: int = 0
var _charge: float = 0.0
var _t: float = 0.0


func setup(hero_id: String) -> void:
	_hero_id = hero_id


func _ready() -> void:
	layer = 5
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = UiTheme.get_theme()
	add_child(root)

	# --- panoul de sus ---
	var top := PanelContainer.new()
	top.add_theme_stylebox_override("panel", UiSkin.box("dark", 14, 10))
	top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top.offset_left = 8
	top.offset_right = -8
	top.offset_top = 8
	top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(top)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top.add_child(row)

	var face_slot := PanelContainer.new()
	face_slot.add_theme_stylebox_override("panel", UiSkin.box("slot", 6, 6))
	var face := HeroPortrait.new()
	face.setup(_hero_id, "face")
	face.custom_minimum_size = Vector2(76, 72)
	face_slot.add_child(face)
	row.add_child(face_slot)

	var mid := VBoxContainer.new()
	mid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mid.add_theme_constant_override("separation", 6)
	row.add_child(mid)
	_hearts = Control.new()
	_hearts.custom_minimum_size = Vector2(0, 30)
	_hearts.draw.connect(_draw_hearts)
	mid.add_child(_hearts)
	var xp_row := HBoxContainer.new()
	xp_row.add_theme_constant_override("separation", 8)
	mid.add_child(xp_row)
	_level_label = _label(36, UiTheme.GOLD_BRIGHT)
	xp_row.add_child(_level_label)
	_xp_bar = ProgressBar.new()
	_xp_bar.show_percentage = false
	_xp_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_xp_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_xp_bar.custom_minimum_size = Vector2(0, 18)
	_xp_bar.add_theme_stylebox_override("background", UiSkin.box("slot", 0, 0))
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(0.45, 0.7, 1.0)
	fill.border_color = Color(0.75, 0.9, 1.0)
	fill.border_width_top = 3
	fill.content_margin_top = 0
	fill.expand_margin_left = -6
	fill.expand_margin_right = -6
	fill.expand_margin_top = -6
	fill.expand_margin_bottom = -6
	_xp_bar.add_theme_stylebox_override("fill", fill)
	xp_row.add_child(_xp_bar)

	var right := VBoxContainer.new()
	right.add_theme_constant_override("separation", 2)
	row.add_child(right)
	_time_label = _label(48, UiTheme.INK)
	_time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	right.add_child(_time_label)
	var kill_row := HBoxContainer.new()
	kill_row.alignment = BoxContainer.ALIGNMENT_END
	var skull := TextureRect.new()
	skull.texture = Icons.get_icon("skull", 3)
	skull.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	kill_row.add_child(skull)
	_kills_label = _label(36, UiTheme.INK)
	kill_row.add_child(_kills_label)
	right.add_child(kill_row)

	pause_button = Button.new()
	pause_button.icon = Icons.get_icon("gear", 3)
	pause_button.custom_minimum_size = Vector2(64, 64)
	pause_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	pause_button.pressed.connect(func() -> void: pause_pressed.emit())
	row.add_child(pause_button)

	_villagers_label = _label(36, Color(0.95, 0.6, 0.6))
	_villagers_label.position = Vector2(20, 132)
	root.add_child(_villagers_label)

	# --- bara boss-ului ---
	_boss_box = VBoxContainer.new()
	_boss_box.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_boss_box.offset_top = 150
	_boss_box.offset_left = 60
	_boss_box.offset_right = -60
	_boss_box.visible = false
	root.add_child(_boss_box)
	_boss_name = _label(36, Color(1, 0.6, 0.55))
	_boss_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_boss_box.add_child(_boss_name)
	_boss_bar = ProgressBar.new()
	_boss_bar.show_percentage = false
	_boss_bar.custom_minimum_size = Vector2(0, 26)
	_boss_bar.add_theme_stylebox_override("background", UiSkin.box("slot", 0, 0))
	var bfill := StyleBoxFlat.new()
	bfill.bg_color = Color(0.8, 0.12, 0.18)
	bfill.border_color = Color(1, 0.45, 0.4)
	bfill.border_width_top = 4
	bfill.expand_margin_left = -6
	bfill.expand_margin_right = -6
	bfill.expand_margin_top = -6
	bfill.expand_margin_bottom = -6
	_boss_bar.add_theme_stylebox_override("fill", bfill)
	_boss_box.add_child(_boss_bar)

	# --- butonul de super-putere ---
	super_button = Control.new()
	super_button.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	super_button.offset_left = -190
	super_button.offset_top = -230
	super_button.offset_right = -30
	super_button.offset_bottom = -70
	super_button.draw.connect(_draw_super)
	super_button.gui_input.connect(_on_super_input)
	root.add_child(super_button)
	_super_face = HeroPortrait.new()
	_super_face.setup(_hero_id, "face")
	_super_face.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_super_face.offset_left = 34
	_super_face.offset_top = 30
	_super_face.offset_right = -34
	_super_face.offset_bottom = -38
	super_button.add_child(_super_face)

	_debug_label = _label(12, Color(0.6, 0.8, 0.6, 0.7))
	_debug_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	_debug_label.offset_top = -30
	_debug_label.offset_left = 10
	root.add_child(_debug_label)

	Events.hearts_changed.connect(_on_hearts)
	Events.xp_changed.connect(set_xp)
	Events.villager_lost.connect(set_villagers)
	Events.super_changed.connect(_on_super_changed)
	set_villagers(0)


func _on_super_changed(c: float) -> void:
	_charge = c
	super_button.queue_redraw()


func _label(font_size: int, col: Color) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", col)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_theme_font_override("font", PixelFont.get_font_outlined())
	return l


func _process(delta: float) -> void:
	_t += delta
	if _charge >= 100.0:
		super_button.queue_redraw()


# --- Inimile ---

func _on_hearts(now: int, max_h: int, lost: int) -> void:
	var before: int = _hearts_now
	_hearts_now = now
	_hearts_max = max_h
	_hearts.custom_minimum_size.y = 28 * (1 + (maxi(_hearts_max, 1) - 1) / 8)
	_hearts.queue_redraw()
	if lost > 0:
		for k in lost:
			_shatter(before - 1 - k)


func _heart_pos(i: int) -> Vector2:
	var per_row: int = 8
	return Vector2((i % per_row) * 32, (i / per_row) * 28)


func _draw_hearts() -> void:
	var full := Icons.get_icon("heart", HEART_SCALE)
	var empty := Icons.get_icon("heart_empty", HEART_SCALE)
	for i in _hearts_max:
		_hearts.draw_texture(full if i < _hearts_now else empty, _heart_pos(i))


## Inima pierdută se rupe în două bucăți care cad.
func _shatter(i: int) -> void:
	if i < 0:
		return
	var base: Vector2 = _hearts.global_position + _heart_pos(i)
	for side in [-1, 1]:
		var piece := TextureRect.new()
		piece.texture = Icons.get_icon("heart_left" if side < 0 else "heart_right", HEART_SCALE)
		piece.position = base + Vector2(0 if side < 0 else 12, 0)
		piece.mouse_filter = Control.MOUSE_FILTER_IGNORE
		get_child(0).add_child(piece)
		var tw := piece.create_tween().set_parallel(true)
		tw.tween_property(piece, "position", piece.position + Vector2(side * 26, 60), 0.55).set_ease(Tween.EASE_IN)
		tw.tween_property(piece, "rotation", side * 0.9, 0.55)
		tw.tween_property(piece, "modulate:a", 0.0, 0.55)
		tw.chain().tween_callback(piece.queue_free)


# --- Restul ---

func set_xp(xp: int, needed: int, level: int) -> void:
	_xp_bar.max_value = needed
	_xp_bar.value = xp
	_level_label.text = "Nv.%d" % level


func set_villagers(total: int) -> void:
	_villagers_label.text = "Săteni pierduți: %d" % total
	_villagers_label.visible = total > 0


func set_stats(seconds: float, kills: int) -> void:
	var s: int = int(seconds)
	_time_label.text = "%02d:%02d" % [s / 60, s % 60]
	_kills_label.text = str(kills)


func set_boss(boss_name: String, hp: float, max_hp: float) -> void:
	_boss_box.visible = max_hp > 0.0
	_boss_name.text = boss_name
	_boss_bar.max_value = max_hp
	_boss_bar.value = hp


func set_debug(enemies: int) -> void:
	_debug_label.text = "FPS %d · inamici %d · [T] test" % [Engine.get_frames_per_second(), enemies]


func _on_super_input(event: InputEvent) -> void:
	var st := event as InputEventScreenTouch
	var mb := event as InputEventMouseButton
	var pressed: bool = (st != null and st.pressed) or (mb != null and mb.pressed)
	if pressed and _charge >= 100.0:
		super_pressed.emit()


func _draw_super() -> void:
	var c: Vector2 = super_button.size * 0.5
	var r: float = minf(c.x, c.y) - 6.0
	var is_full: bool = _charge >= 100.0
	var pulse: float = 0.5 + 0.5 * sin(_t * 6.0)
	if is_full:
		super_button.draw_circle(c, r + 12.0 + pulse * 6.0, Color(1.0, 0.8, 0.3, 0.25))
	super_button.draw_circle(c, r, Color(0.08, 0.06, 0.12, 0.92))
	super_button.draw_arc(c, r, 0.0, TAU, 48, Color(0.3, 0.25, 0.4), 6.0)
	super_button.draw_arc(c, r, -PI * 0.5, -PI * 0.5 + TAU * _charge / 100.0, 48,
		Color(1.0, 0.82, 0.3) if is_full else Color(0.6, 0.45, 1.0), 8.0)
	_super_face.modulate = Color(1, 1, 1) if is_full else Color(0.5, 0.5, 0.58)
	var font := PixelFont.get_font()
	var txt: String = "SUPER" if is_full else "%d%%" % int(_charge)
	var w: float = font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 24).x
	super_button.draw_string(font, Vector2(c.x - w * 0.5, c.y + r + 2.0), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 24,
		UiTheme.GOLD_BRIGHT if is_full else UiTheme.INK_DIM)
