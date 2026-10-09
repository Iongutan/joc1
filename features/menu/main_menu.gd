extends Control
## Meniul principal (vertical): resurse sus, eroul pe piedestal, capitolul ales,
## buton mare „Luptă” și navigare jos — după modelul jocurilor de succes din gen.

const RUN_SCENE := "res://features/run/run.tscn"
const INTRO_SCENE := "res://features/story/intro.tscn"
const NAV := [["Piața", "bag"], ["Eroii", "helmet"], ["Luptă", "swords"], ["Satul", "house"], ["Altarul", "altar"]]

var _toast: Label
var _toast_tween: Tween
var _showcase: HeroShowcase
var _power_label: Label
var _gold_label: Label
var _tears_label: Label
var _face: HeroPortrait
var _hero_name: Label
var _ch_act: Label
var _ch_name: Label
var _ch_story: Label
var _ch_boss: Label
var _play: Button
var _heroes: HeroesScreen
var _panel: ChoicePanel


func _ready() -> void:
	if not Save.intro_seen and not OS.get_cmdline_user_args().has("--skip-intro"):
		get_tree().change_scene_to_file.call_deferred(INTRO_SCENE)
		return
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = UiTheme.get_theme()
	Audio.play_music("menu")

	add_child(PixelCanvas.wrap(MenuBackdrop.new(), 3))
	_add_embers()

	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 0)
	add_child(root)

	root.add_child(_top_bar())
	root.add_child(_title_block())

	_showcase = HeroShowcase.new()
	_showcase.hero_scale = 2.0
	_showcase.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_showcase.custom_minimum_size = Vector2(0, 380)
	root.add_child(_showcase)

	root.add_child(_chapter_card())
	root.add_child(_spacer(14))
	root.add_child(_play_button())
	root.add_child(_spacer(18))
	root.add_child(_nav_bar())

	_toast = Label.new()
	_toast.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_toast.offset_top = -200.0
	_toast.offset_left = -320.0
	_toast.offset_right = 320.0
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.add_theme_font_size_override("font_size", 36)
	_toast.add_theme_color_override("font_color", UiTheme.GOLD_BRIGHT)
	_toast.modulate.a = 0.0
	add_child(_toast)

	_heroes = HeroesScreen.new()
	_heroes.visible = false
	_heroes.closed.connect(_refresh)
	add_child(_heroes)
	_panel = ChoicePanel.new()
	add_child(_panel)

	_refresh()
	if OS.get_cmdline_user_args().has("--open-heroes"):
		_heroes.open()
	DebugShot.maybe_capture(self)


func _refresh() -> void:
	_showcase.set_hero(Save.hero)
	_face.set_hero(Save.hero)
	_hero_name.text = HeroArt.HEROES[Save.hero]["name"]
	_power_label.text = "Putere %d" % Save.power()
	_gold_label.text = str(Save.gold)
	_tears_label.text = str(Save.tears)
	var ch: Dictionary = Chapters.get_chapter(Save.chapter)
	_ch_act.text = ch["act"]
	_ch_name.text = ch["name"]
	_ch_story.text = ch["story"]
	_ch_boss.text = "Boss: %s" % ch["boss"]
	var locked: bool = Save.chapter > Save.unlocked_chapter
	_play.disabled = locked
	_play.text = "  BLOCAT" if locked else "  LUPTĂ"


func _spacer(height: float) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, height)
	return c


func _margin(child: Control, h: int, v: int) -> MarginContainer:
	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_left", h)
	m.add_theme_constant_override("margin_right", h)
	m.add_theme_constant_override("margin_top", v)
	m.add_theme_constant_override("margin_bottom", v)
	m.add_child(child)
	return m


func _label(text: String, font_size: int, col: Color = UiTheme.INK) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", col)
	return l


func _resource(icon: String) -> Array:
	var box := PanelContainer.new()
	box.add_theme_stylebox_override("panel", UiSkin.box("dark", 12, 6))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	box.add_child(row)
	var tr := TextureRect.new()
	tr.texture = Icons.get_icon(icon, 4)
	tr.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	row.add_child(tr)
	var l := _label("0", 36, UiTheme.GOLD_BRIGHT if icon == "coin" else Color(0.8, 0.7, 1.0))
	row.add_child(l)
	return [box, l]


func _top_bar() -> Control:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiSkin.box("wood", 14, 10))
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 10)
	panel.add_child(bar)
	var slot := PanelContainer.new()
	slot.add_theme_stylebox_override("panel", UiSkin.box("slot", 6, 6))
	_face = HeroPortrait.new()
	_face.setup(Save.hero, "face")
	_face.custom_minimum_size = Vector2(72, 68)
	slot.add_child(_face)
	bar.add_child(slot)
	var who := VBoxContainer.new()
	who.add_theme_constant_override("separation", -4)
	_hero_name = _label("Corvin", 36)
	who.add_child(_hero_name)
	_power_label = _label("Putere 0", 24, UiTheme.GOLD_BRIGHT)
	who.add_child(_power_label)
	bar.add_child(who)
	var gap := Control.new()
	gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(gap)
	var g := _resource("coin")
	bar.add_child(g[0])
	_gold_label = g[1]
	var t := _resource("tear")
	bar.add_child(t[0])
	_tears_label = t[1]
	var gear := Button.new()
	gear.icon = Icons.get_icon("gear", 4)
	gear.custom_minimum_size = Vector2(72, 72)
	gear.pressed.connect(_open_settings)
	bar.add_child(gear)
	return _margin(panel, 8, 8)


func _title_block() -> Control:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 0)
	var title := _label("PACTUL UMBREI", 72, UiTheme.GOLD_BRIGHT)
	title.add_theme_font_override("font", PixelFont.get_font_outlined())
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_shadow_color", Color(0.5, 0.1, 0.12, 0.9))
	title.add_theme_constant_override("shadow_offset_y", 6)
	box.add_child(title)
	var sub := _label("Fiecare moarte are un preț.", 36, Color(0.9, 0.8, 0.7))
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(sub)
	var story := Button.new()
	story.text = "Povestea"
	story.icon = Icons.get_icon("skull", 3)
	story.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	story.custom_minimum_size = Vector2(220, 60)
	story.pressed.connect(func() -> void: get_tree().change_scene_to_file(INTRO_SCENE))
	box.add_child(_spacer(6))
	box.add_child(story)
	return _margin(box, 16, 8)


func _chapter_card() -> Control:
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", UiSkin.box("parchment", 18, 12))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	card.add_child(row)
	var prev := Button.new()
	prev.text = "<"
	prev.custom_minimum_size = Vector2(64, 120)
	prev.pressed.connect(_change_chapter.bind(-1))
	row.add_child(prev)
	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 2)
	row.add_child(box)
	var dark := Color(0.25, 0.15, 0.1)
	_ch_act = _label("", 24, Color(0.55, 0.25, 0.2))
	_ch_act.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ch_name = _label("", 36, dark)
	_ch_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ch_story = _label("", 36, Color(0.35, 0.25, 0.18))
	_ch_story.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ch_story.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_ch_boss = _label("", 36, Color(0.6, 0.15, 0.15))
	_ch_boss.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for l in [_ch_act, _ch_name, _ch_story, _ch_boss]:
		l.remove_theme_color_override("font_shadow_color")
		l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0))
		box.add_child(l)
	var next := Button.new()
	next.text = ">"
	next.custom_minimum_size = Vector2(64, 120)
	next.pressed.connect(_change_chapter.bind(1))
	row.add_child(next)
	return _margin(card, 20, 0)


func _change_chapter(d: int) -> void:
	Audio.play("click")
	Save.chapter = clampi(Save.chapter + d, 0, Chapters.LIST.size() - 1)
	Save.save_game()
	_refresh()


func _play_button() -> Control:
	_play = Button.new()
	_play.icon = Icons.get_icon("swords", 5)
	_play.custom_minimum_size = Vector2(0, 124)
	_play.add_theme_font_size_override("font_size", 60)
	_play.add_theme_stylebox_override("normal", UiSkin.box("red"))
	_play.add_theme_stylebox_override("hover", UiSkin.box("red"))
	_play.add_theme_stylebox_override("pressed", UiSkin.box("red_pressed"))
	_play.add_theme_color_override("font_color", Color(1, 0.95, 0.85))
	_play.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	_play.pressed.connect(_start_run)
	return _margin(_play, 80, 0)


func _nav_bar() -> Control:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiSkin.box("dark", 8, 8))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	panel.add_child(row)
	for i in NAV.size():
		var b := Button.new()
		b.text = NAV[i][0]
		b.icon = Icons.get_icon(NAV[i][1], 4)
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size = Vector2(0, 124 if i == 2 else 112)
		b.add_theme_font_size_override("font_size", 24)
		if i == 2:
			b.add_theme_stylebox_override("normal", UiSkin.box("red"))
			b.add_theme_stylebox_override("hover", UiSkin.box("red"))
			b.add_theme_stylebox_override("pressed", UiSkin.box("red_pressed"))
			b.pressed.connect(_start_run)
		elif i == 1:
			b.pressed.connect(_open_heroes)
		else:
			b.pressed.connect(_show_toast.bind("%s — în curând" % NAV[i][0]))
		row.add_child(b)
	return panel


func _add_embers() -> void:
	var p := CPUParticles2D.new()
	p.amount = 46
	p.lifetime = 8.0
	p.preprocess = 8.0
	p.position = Vector2(360, 1320)
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(400, 20)
	p.direction = Vector2(0, -1)
	p.spread = 25.0
	p.gravity = Vector2(0, 0)
	p.initial_velocity_min = 40.0
	p.initial_velocity_max = 110.0
	p.scale_amount_min = 3.0
	p.scale_amount_max = 6.0
	var ramp := Gradient.new()
	ramp.set_color(0, Color(1.0, 0.5, 0.15, 0.0))
	ramp.set_color(1, Color(1.0, 0.8, 0.4, 0.0))
	ramp.add_point(0.2, Color(1.0, 0.55, 0.2, 0.9))
	ramp.add_point(0.7, Color(1.0, 0.8, 0.4, 0.6))
	p.color_ramp = ramp
	p.material = UiTheme.glow_material(true)
	add_child(p)


func _show_toast(text: String) -> void:
	Audio.play("click")
	_toast.text = text
	if _toast_tween != null:
		_toast_tween.kill()
	_toast_tween = create_tween()
	_toast_tween.tween_property(_toast, "modulate:a", 1.0, 0.15)
	_toast_tween.tween_interval(1.2)
	_toast_tween.tween_property(_toast, "modulate:a", 0.0, 0.4)


func _open_heroes() -> void:
	Audio.play("click")
	_heroes.open()


func _open_settings() -> void:
	Audio.play("click")
	_panel.open("SETĂRI", "", [
		{"text": "Sunet și muzică: %s" % ("pornite" if Save.sound_on else "oprite")},
		{"text": "Vibrații: %s" % ("pornite" if Save.vibration_on else "oprite")},
		{"text": "Închide"},
	], _on_settings)


func _on_settings(idx: int) -> void:
	match idx:
		0:
			Save.sound_on = not Save.sound_on
			Save.music_on = Save.sound_on
			if Save.music_on:
				Audio.play_music("menu")
			else:
				Audio.stop_music()
			Save.save_game()
			_open_settings()
		1:
			Save.vibration_on = not Save.vibration_on
			Save.save_game()
			Audio.vibrate(80)
			_open_settings()


func _start_run() -> void:
	if Save.chapter > Save.unlocked_chapter:
		_show_toast("Termină capitolul anterior")
		return
	Audio.play("whoosh")
	Audio.vibrate(40)
	get_tree().change_scene_to_file(RUN_SCENE)
