class_name HeroesScreen
extends Control
## Ecranul eroilor (stil Guardian Tales): eroul mare la mijloc, 6 locuri de echipament
## în jurul lui, statistici și inventarul dedesubt.

signal closed

var _showcase: HeroShowcase
var _name: Label
var _title: Label
var _stats: Label
var _slots: Dictionary = {}
var _grid: GridContainer
var _hero_buttons: Dictionary = {}


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = UiTheme.get_theme()

	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.09)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var root := VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 8)
	add_child(root)

	# antet
	var head := PanelContainer.new()
	head.add_theme_stylebox_override("panel", UiSkin.box("wood", 14, 8))
	var hrow := HBoxContainer.new()
	head.add_child(hrow)
	var back := Button.new()
	back.text = "< Înapoi"
	back.custom_minimum_size = Vector2(170, 68)
	back.pressed.connect(close)
	hrow.add_child(back)
	var t := Label.new()
	t.text = "EROII"
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 48)
	t.add_theme_color_override("font_color", UiTheme.GOLD_BRIGHT)
	hrow.add_child(t)
	var pad := Control.new()
	pad.custom_minimum_size = Vector2(170, 0)
	hrow.add_child(pad)
	root.add_child(head)

	# alegerea eroului
	var picks := HBoxContainer.new()
	picks.alignment = BoxContainer.ALIGNMENT_CENTER
	picks.add_theme_constant_override("separation", 14)
	for id in HeroArt.ROSTER:
		var b := Button.new()
		b.custom_minimum_size = Vector2(120, 110)
		var face := HeroPortrait.new()
		face.setup(id, "face")
		face.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		face.offset_left = 10
		face.offset_top = 8
		face.offset_right = -10
		face.offset_bottom = -8
		b.add_child(face)
		b.pressed.connect(_pick_hero.bind(id))
		picks.add_child(b)
		_hero_buttons[id] = b
	root.add_child(picks)

	# eroul + echipamentul în jur
	var mid := HBoxContainer.new()
	mid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mid.add_theme_constant_override("separation", 0)
	root.add_child(mid)
	var left := VBoxContainer.new()
	left.alignment = BoxContainer.ALIGNMENT_CENTER
	left.add_theme_constant_override("separation", 18)
	mid.add_child(left)
	var center := VBoxContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mid.add_child(center)
	var right := VBoxContainer.new()
	right.alignment = BoxContainer.ALIGNMENT_CENTER
	right.add_theme_constant_override("separation", 18)
	mid.add_child(right)
	for i in Items.SLOTS.size():
		var slot: String = Items.SLOTS[i]
		var b := Button.new()
		b.custom_minimum_size = Vector2(120, 120)
		b.expand_icon = false
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.add_theme_stylebox_override("normal", UiSkin.box("slot", 8, 8))
		b.add_theme_stylebox_override("hover", UiSkin.box("slot", 8, 8))
		b.add_theme_stylebox_override("pressed", UiSkin.box("stone", 8, 8))
		b.pressed.connect(_unequip.bind(slot))
		(left if i < 3 else right).add_child(_margin(b, 14))
		_slots[slot] = b

	_name = Label.new()
	_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_name.add_theme_font_size_override("font_size", 48)
	center.add_child(_name)
	_title = Label.new()
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 24)
	_title.add_theme_color_override("font_color", Color(0.8, 0.7, 1.0))
	center.add_child(_title)
	_showcase = HeroShowcase.new()
	_showcase.hero_scale = 2.0
	_showcase.show_torches = false
	_showcase.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.add_child(_showcase)

	# statistici
	var stats_box := PanelContainer.new()
	stats_box.add_theme_stylebox_override("panel", UiSkin.box("parchment", 18, 10))
	_stats = Label.new()
	_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stats.add_theme_font_size_override("font_size", 24)
	_stats.add_theme_color_override("font_color", Color(0.25, 0.15, 0.1))
	_stats.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0))
	stats_box.add_child(_stats)
	root.add_child(_margin(stats_box, 16))

	# inventarul
	var inv_panel := PanelContainer.new()
	inv_panel.add_theme_stylebox_override("panel", UiSkin.box("stone", 14, 12))
	inv_panel.custom_minimum_size = Vector2(0, 300)
	var inv_box := VBoxContainer.new()
	inv_panel.add_child(inv_box)
	var inv_title := Label.new()
	inv_title.text = "Inventar — atinge un obiect ca să-l echipezi"
	inv_title.add_theme_font_size_override("font_size", 24)
	inv_title.add_theme_color_override("font_color", UiTheme.INK_DIM)
	inv_box.add_child(inv_title)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inv_box.add_child(scroll)
	_grid = GridContainer.new()
	_grid.columns = 5
	_grid.add_theme_constant_override("h_separation", 10)
	_grid.add_theme_constant_override("v_separation", 10)
	scroll.add_child(_grid)
	root.add_child(_margin(inv_panel, 12))


func _margin(child: Control, m: int) -> MarginContainer:
	var mc := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		mc.add_theme_constant_override("margin_" + side, m)
	mc.add_child(child)
	return mc


func open() -> void:
	visible = true
	_refresh()


func close() -> void:
	Audio.play("click")
	visible = false
	closed.emit()


func _pick_hero(id: String) -> void:
	Audio.play("click")
	Save.hero = id
	Save.save_game()
	_refresh()
	_showcase.play_anim("super")


func _equip(id: String) -> void:
	var item: Dictionary = Items.get_item(id)
	if item.is_empty():
		return
	Save.equipment[item["slot"]] = id
	Save.save_game()
	Audio.play("chest")
	Audio.vibrate(30)
	_refresh()


func _unequip(slot: String) -> void:
	if Save.equipment.has(slot):
		Save.equipment.erase(slot)
		Save.save_game()
		Audio.play("click")
		_refresh()


func _refresh() -> void:
	var hero: Dictionary = HeroArt.HEROES[Save.hero]
	_name.text = hero["name"]
	_title.text = hero["title"]
	_showcase.set_hero(Save.hero)
	for id in _hero_buttons:
		var b: Button = _hero_buttons[id]
		b.modulate = Color(1, 1, 1) if id == Save.hero else Color(0.55, 0.55, 0.6)
	for slot in Items.SLOTS:
		var b: Button = _slots[slot]
		var id: String = Save.equipment.get(slot, "")
		var item: Dictionary = Items.get_item(id)
		b.icon = Icons.get_icon(Items.SLOT_ICONS[slot], 5)
		if item.is_empty():
			b.modulate = Color(0.45, 0.45, 0.5)
			b.tooltip_text = Items.SLOT_NAMES[slot] + " (gol)"
		else:
			b.modulate = Items.RARITY_COLORS[item["rarity"]].lightened(0.2)
			b.tooltip_text = "%s\n%s" % [item["name"], Items.describe(item)]
	var s := Save.gear_stats()
	_stats.text = "Putere %d   ·   Inimi %d   ·   Atac +%d%%   ·   Viteză %+d%%" % [
		Save.power(), Player.BASE_HEARTS + int(s["hearts"]), int(s["atk"] * 100.0), int(s["speed"] * 100.0)]
	for c in _grid.get_children():
		c.queue_free()
	for id in Save.inventory:
		var item: Dictionary = Items.get_item(id)
		if item.is_empty():
			continue
		var b := Button.new()
		b.icon = Icons.get_icon(Items.SLOT_ICONS[item["slot"]], 4)
		b.custom_minimum_size = Vector2(118, 118)
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.add_theme_stylebox_override("normal", UiSkin.box("slot", 6, 6))
		b.modulate = Items.RARITY_COLORS[item["rarity"]].lightened(0.2)
		b.tooltip_text = "%s (%s)\n%s" % [item["name"], Items.RARITY_NAMES[item["rarity"]], Items.describe(item)]
		if Save.equipment.get(item["slot"], "") == id:
			b.text = "E"
		b.pressed.connect(_equip.bind(id))
		_grid.add_child(b)
