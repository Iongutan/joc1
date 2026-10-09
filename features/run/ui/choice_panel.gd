class_name ChoicePanel
extends CanvasLayer
## Panou cu titlu, text și butoane, afișat peste joc cât timp e pe pauză.
## Folosit pentru nivel nou și pentru ecranul de moarte.

var _title: Label
var _body: Label
var _box: VBoxContainer


func _ready() -> void:
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.0, 0.05, 0.72)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.theme = UiTheme.get_theme()
	add_child(center)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(660, 0)
	center.add_child(card)

	var margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	card.add_child(margin)

	_box = VBoxContainer.new()
	_box.add_theme_constant_override("separation", 16)
	margin.add_child(_box)

	_title = Label.new()
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 48)
	_title.add_theme_color_override("font_color", UiTheme.GOLD_BRIGHT)
	_title.add_theme_constant_override("outline_size", 10)
	_box.add_child(_title)

	_body = Label.new()
	_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_body.custom_minimum_size = Vector2(580, 0)
	_body.add_theme_font_size_override("font_size", 36)
	_body.add_theme_color_override("font_color", UiTheme.INK_DIM)
	_box.add_child(_body)


## options: listă de { "text": String, "disabled": bool (opțional) }.
## on_pick primește indexul butonului apăsat.
func open(title: String, body: String, options: Array, on_pick: Callable) -> void:
	for child in _box.get_children():
		if child is Button:
			child.queue_free()
	_title.text = title
	_body.text = body
	_body.visible = body != ""
	for idx in options.size():
		var opt: Dictionary = options[idx]
		var b := Button.new()
		b.text = opt["text"]
		b.disabled = opt.get("disabled", false)
		b.custom_minimum_size = Vector2(600, 110)
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.add_theme_font_size_override("font_size", 36)
		b.pressed.connect(_on_button.bind(idx, on_pick))
		_box.add_child(b)
	visible = true


func _on_button(idx: int, on_pick: Callable) -> void:
	visible = false
	on_pick.call(idx)
