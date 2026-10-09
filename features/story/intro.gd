extends Control
## Prologul: scene ilustrate cu text care apare literă cu literă.
## Atinge ecranul ca să continui; „Sari peste” duce direct în meniu.

const MENU := "res://features/menu/main_menu.tscn"

const PAGES := [
	{"scene": "battle", "text": "Câmpul de la Vadul Negru, în noaptea în care cerul a sângerat. Acolo a căzut Corvin, ultimul vânător de Sângerii.", "sfx": "", "vib": 0},
	{"scene": "morgrav", "text": "Din umbră s-a ridicat o voce mai veche decât moartea: «Vrei să trăiești, vânătorule? Spune doar da.»", "sfx": "boss", "vib": 300},
	{"scene": "pact", "text": "Corvin a spus da. Semnul Pactului i-a ars în palmă. Nu a întrebat care e prețul.", "sfx": "pact", "vib": 500},
	{"scene": "letter", "text": "Ani mai târziu, în Solgrad, a sosit o scrisoare pătată de sânge, cu sigiliul boierului din nord.", "sfx": "", "vib": 0},
	{"scene": "north", "text": "«Satele ard. Morții se ridică din morminte. Vino înainte de prima zăpadă.»", "sfx": "whoosh", "vib": 120},
	{"scene": "title", "text": "Corvin nu poate muri. Dar fiecare moarte a lui are un preț... și altcineva îl plătește.", "sfx": "", "vib": 0},
]

var _art: StoryArt
var _text: Label
var _hint: Label
var _title: Label
var _page: int = -1
var _shown: float = 0.0
var _typing: bool = false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = UiTheme.get_theme()
	Audio.play_music("menu")
	_art = StoryArt.new()
	add_child(PixelCanvas.wrap(_art, 3))

	_title = Label.new()
	_title.text = "PACTUL UMBREI"
	_title.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_title.offset_left = -360
	_title.offset_right = 360
	_title.offset_top = -200
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 72)
	_title.add_theme_color_override("font_color", UiTheme.GOLD_BRIGHT)
	_title.visible = false
	add_child(_title)

	var box := PanelContainer.new()
	box.add_theme_stylebox_override("panel", UiSkin.box("parchment", 26, 22))
	box.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	box.offset_left = 20
	box.offset_right = -20
	box.offset_top = -330
	box.offset_bottom = -40
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(box)
	var v := VBoxContainer.new()
	box.add_child(v)
	_text = Label.new()
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_text.add_theme_font_size_override("font_size", 36)
	_text.add_theme_color_override("font_color", Color(0.22, 0.12, 0.08))
	_text.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0))
	v.add_child(_text)
	_hint = Label.new()
	_hint.text = "Atinge pentru a continua"
	_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_hint.add_theme_font_size_override("font_size", 24)
	_hint.add_theme_color_override("font_color", Color(0.5, 0.3, 0.2))
	_hint.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0))
	v.add_child(_hint)

	var skip := Button.new()
	skip.text = "Sari peste >>"
	skip.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	skip.offset_left = -250
	skip.offset_top = 24
	skip.offset_right = -20
	skip.offset_bottom = 96
	skip.pressed.connect(_finish)
	add_child(skip)

	_next()
	DebugShot.maybe_capture(self)


func _process(delta: float) -> void:
	if not _typing:
		_hint.modulate.a = 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.005)
		return
	var before: int = _text.visible_characters
	_shown += delta * 40.0
	_text.visible_characters = int(_shown)
	if _text.visible_characters != before and _text.visible_characters % 2 == 0:
		Audio.play("type", -10.0, 0.2)
	if _text.visible_characters >= _text.text.length():
		_typing = false
		_hint.visible = true


func _gui_input(event: InputEvent) -> void:
	var st := event as InputEventScreenTouch
	var mb := event as InputEventMouseButton
	if (st != null and st.pressed) or (mb != null and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT):
		if _typing:
			_typing = false
			_text.visible_characters = -1
			_hint.visible = true
		else:
			_next()


func _next() -> void:
	_page += 1
	if _page >= PAGES.size():
		_finish()
		return
	var p: Dictionary = PAGES[_page]
	_art.show_scene(p["scene"])
	_title.visible = p["scene"] == "title"
	_text.text = p["text"]
	_text.visible_characters = 0
	_shown = 0.0
	_typing = true
	_hint.visible = false
	if p["sfx"] != "":
		Audio.play(p["sfx"])
	if int(p["vib"]) > 0:
		Audio.vibrate(int(p["vib"]))
	# tranziție: ecranul se luminează din negru
	modulate = Color(0, 0, 0)
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.5)


func _finish() -> void:
	Save.intro_seen = true
	Save.save_game()
	Audio.play("click")
	get_tree().change_scene_to_file(MENU)
