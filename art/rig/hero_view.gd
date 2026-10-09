class_name HeroView
extends Node2D
## Eroul în luptă: sprite-ul pixel art (poză de stat + poză de atac), animat din cod:
## respiră, sare la mers, se înclină, reculează la atac, plutește la super, clipește la lovitură.

const ANIM_FPS: float = 12.0

var hero_id: String = "corvin"
var anim: String = "idle"
var facing: float = 1.0
var sprite: Sprite2D
## Dacă eroul are un sprite sheet (art/sheets/<id>_sheet.json), se folosesc cadrele desenate.
var animated: AnimatedSprite2D

var _t: float = 0.0
var _anim_t: float = 0.0
var _flash: float = 0.0


func setup(id: String) -> void:
	hero_id = HeroArt.valid(id)
	var sheet := "res://art/sheets/%s_sheet.json" % hero_id
	if SheetLoader.has_sheet(sheet):
		animated = AnimatedSprite2D.new()
		animated.sprite_frames = SheetLoader.frames(sheet)
		animated.offset = SheetLoader.pivot_offset(sheet)
		animated.animation_finished.connect(func() -> void: play("idle"))
		add_child(animated)
		animated.play("idle")
		return
	sprite = Sprite2D.new()
	sprite.centered = false
	add_child(sprite)
	_set_pose("idle")


func _set_pose(pose: String) -> void:
	var tex := HeroArt.texture(hero_id, pose)
	if sprite.texture != tex:
		sprite.texture = tex
		var s: Vector2 = tex.get_size()
		# picioarele pe originea nodului
		sprite.offset = Vector2(-s.x * 0.5, -s.y + 2)


func play(a: String) -> void:
	if a == anim and a != "attack":
		return
	anim = a
	_anim_t = 0.0
	if animated != null:
		animated.play(a if animated.sprite_frames.has_animation(a) else "idle")
		return
	if a == "hurt":
		_flash = 0.12


func set_facing(f: float) -> void:
	facing = f
	if animated != null:
		animated.flip_h = f < 0.0


func _process(delta: float) -> void:
	if animated != null:
		return
	_t += delta
	_anim_t += delta
	# pozițiile se schimbă în pași (12 cadre/s), ca la animația pixel art clasică
	var t: float = floorf(_t * ANIM_FPS) / ANIM_FPS
	var at: float = floorf(_anim_t * ANIM_FPS) / ANIM_FPS
	var pos := Vector2.ZERO
	var rot: float = 0.0
	var sc := Vector2(1, 1)
	var pose := "idle"
	match anim:
		"idle":
			sc.y = 1.0 + sin(t * 3.0) * 0.025
			sc.x = 1.0 - sin(t * 3.0) * 0.012
		"run":
			pos.y = -absf(sin(at * 11.0)) * 4.0
			rot = sin(at * 11.0) * 0.07
			sc.y = 1.0 - absf(cos(at * 11.0)) * 0.04
		"attack":
			pose = "attack"
			pos.x = -2.0 if at < 0.08 else 0.0
			if _anim_t > 0.28:
				anim = "idle"
		"super":
			pose = "attack"
			pos.y = -6.0 - sin(t * 6.0) * 2.0
			sc = Vector2(1.08, 1.08)
			if _anim_t > 0.9:
				anim = "idle"
		"hurt":
			rot = -0.18
			pos.x = -3.0
			if _anim_t > 0.25:
				anim = "idle"
		"victory":
			pose = "attack"
			pos.y = -absf(sin(at * 6.0)) * 12.0
	_set_pose(pose)
	sprite.position = pos
	sprite.rotation = rot * facing
	sprite.scale = Vector2(sc.x * facing, sc.y)
	if _flash > 0.0:
		_flash -= delta
		sprite.modulate = Color(3, 3, 3)
	else:
		sprite.modulate = Color.WHITE
