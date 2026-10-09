class_name HeroShowcase
extends Control
## Eroul mare, animat, pe un piedestal de piatră între două torțe aprinse.

var _hero: HeroPortrait
var _t: float = 0.0
var _last_frame: int = -1
var hero_scale: float = 3.0
var show_torches: bool = true


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hero = HeroPortrait.new()
	add_child(_hero)
	_hero.setup(Save.hero)
	resized.connect(_layout)
	_layout()


func set_hero(id: String) -> void:
	_hero.set_hero(id)
	_hero.play("idle")
	_layout()


func play_anim(anim: String) -> void:
	_hero.play(anim)
	await get_tree().create_timer(1.2).timeout
	_hero.play("idle")


func _layout() -> void:
	# picioarele eroului stau pe treapta de sus a piedestalului
	var s: Vector2 = HeroArt.texture(_hero.hero_id, "idle", true).get_size() * hero_scale
	_hero.size = s
	_hero.position = Vector2(size.x * 0.5 - s.x * 0.5, size.y - 40.0 - 66.0 - s.y + 6.0)


func _process(delta: float) -> void:
	_t += delta
	var f: int = int(_t * 12.0)
	if f != _last_frame:
		_last_frame = f
		queue_redraw()


func _draw() -> void:
	var cx: float = size.x * 0.5
	var base_y: float = size.y - 40.0
	# lumina de jos
	for k in 5:
		draw_circle(Vector2(cx, base_y - 40), 230.0 - k * 30.0, Color(1.0, 0.7, 0.35, 0.035))
	# piedestalul: trepte de piatră pixelate
	var steps := [[300.0, 26.0, Color(0.24, 0.22, 0.27)], [240.0, 22.0, Color(0.3, 0.28, 0.33)], [190.0, 18.0, Color(0.36, 0.34, 0.4)]]
	var y: float = base_y
	for s in steps:
		var w: float = s[0]
		var h: float = s[1]
		y -= h
		draw_rect(Rect2(cx - w * 0.5, y, w, h), s[2])
		draw_rect(Rect2(cx - w * 0.5, y, w, 4), (s[2] as Color).lightened(0.25))
		draw_rect(Rect2(cx - w * 0.5, y + h - 4, w, 4), (s[2] as Color).darkened(0.35))
		var bx: float = cx - w * 0.5 + 30.0
		while bx < cx + w * 0.5 - 10.0:
			draw_rect(Rect2(bx, y + 4, 3, h - 8), (s[2] as Color).darkened(0.3))
			bx += 54.0
	# umbra eroului
	draw_set_transform(Vector2(cx, y + 2), 0.0, Vector2(1.0, 0.25))
	draw_circle(Vector2.ZERO, 70.0, Color(0, 0, 0, 0.45))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if show_torches:
		_torch(Vector2(cx - 210.0, base_y - 60.0))
		_torch(Vector2(cx + 210.0, base_y - 60.0))


func _torch(p: Vector2) -> void:
	draw_rect(Rect2(p.x - 6, p.y - 120, 12, 120), Color(0.3, 0.2, 0.14))
	draw_rect(Rect2(p.x - 6, p.y - 120, 4, 120), Color(0.42, 0.3, 0.2))
	draw_rect(Rect2(p.x - 16, p.y - 132, 32, 14), Color(0.35, 0.33, 0.38))
	draw_rect(Rect2(p.x - 16, p.y - 132, 32, 4), Color(0.55, 0.52, 0.58))
	var f: float = sin(_t * 9.0 + p.x) * 3.0
	for k in 6:
		draw_circle(p + Vector2(0, -150), 60.0 - k * 9.0, Color(1.0, 0.6, 0.2, 0.05))
	var flame := [
		[Vector2(-14, -134), Vector2(0, -186 + f), Vector2(14, -134), Color(0.95, 0.35, 0.1)],
		[Vector2(-9, -134), Vector2(0 + f * 0.5, -172), Vector2(9, -134), Color(1.0, 0.65, 0.15)],
		[Vector2(-5, -134), Vector2(0, -158 - f * 0.5), Vector2(5, -134), Color(1.0, 0.95, 0.6)],
	]
	for fl in flame:
		draw_colored_polygon(PackedVector2Array([p + fl[0], p + fl[1], p + fl[2]]), fl[3])
