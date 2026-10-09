class_name Player
extends Node2D
## Eroul controlat de jucător: animații pixel art, viață pe inimi, super-putere.

signal died

## Apropierea camerei: pe telefon vertical, pixel art-ul trebuie să fie mare și clar.
const ZOOM: float = 2.2
const INVULN_TIME: float = 1.0
const BASE_HEARTS: int = 6

var hero_id: String = "corvin"
var max_hearts: int = BASE_HEARTS
var hearts: int = BASE_HEARTS
var speed: float = 78.0
var magnet: float = 46.0
var damage_mult: float = 1.0
var alive: bool = true
var super_charge: float = 0.0

var view: HeroView
var camera: Camera2D
var _invuln: float = 0.0
var _shoot_lock: float = 0.0
var _shake: float = 0.0
var _moving: bool = false


func setup(id: String, gear: Dictionary) -> void:
	hero_id = id
	max_hearts = BASE_HEARTS + int(gear.get("hearts", 0))
	hearts = max_hearts
	damage_mult = 1.0 + float(gear.get("atk", 0.0))
	speed *= 1.0 + float(gear.get("speed", 0.0))
	magnet *= 1.0 + float(gear.get("magnet", 0.0))


func _ready() -> void:
	# umbra sub erou
	var shadow := Sprite2D.new()
	shadow.texture = UiTheme.radial_texture(32, Color(0, 0, 0, 0.55), Color(0, 0, 0, 0))
	shadow.scale = Vector2(1.1, 0.35)
	shadow.position = Vector2(0, 30)
	add_child(shadow)

	view = HeroView.new()
	view.position = Vector2(0, 30)
	add_child(view)
	view.setup(hero_id)

	camera = Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.0
	camera.zoom = Vector2(ZOOM, ZOOM)
	add_child(camera)

	# Lumina caldă din jurul eroului: restul lumii rămâne în întuneric.
	var light := PointLight2D.new()
	light.texture = UiTheme.radial_texture(256, Color(1, 1, 1, 1), Color(1, 1, 1, 0))
	light.texture_scale = 1.3
	light.color = Color(1.0, 0.86, 0.66)
	light.energy = 1.15
	add_child(light)

	Events.shake.connect(func(s: float) -> void: _shake = maxf(_shake, s))
	_emit_hearts(0)


func move(dir: Vector2, delta: float) -> void:
	if not alive:
		return
	position += dir * speed * delta
	_moving = dir != Vector2.ZERO
	if absf(dir.x) > 0.1:
		view.set_facing(-1.0 if dir.x < 0.0 else 1.0)
	if _shoot_lock > 0.0:
		_shoot_lock -= delta
	else:
		view.play("run" if _moving else "idle")
	if _invuln > 0.0:
		_invuln -= delta
		view.visible = int(_invuln * 14.0) % 2 == 0
	else:
		view.visible = true
	# tremurul camerei
	if _shake > 0.0:
		camera.offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * _shake
		_shake = maxf(_shake - delta * 18.0, 0.0)
	else:
		camera.offset = Vector2.ZERO


## Animația de tragere, orientată spre țintă.
func shoot_towards(target: Vector2) -> void:
	view.set_facing(-1.0 if target.x < position.x else 1.0)
	_shoot_lock = 0.2
	view.play("attack")


func play_super() -> void:
	_shoot_lock = 0.7
	view.play("super")


## O lovitură ia una sau mai multe inimi. După lovitură eroul clipește și nu mai poate fi lovit o secundă.
func hit(heart_damage: int) -> void:
	if not alive or _invuln > 0.0 or heart_damage <= 0:
		return
	var lost: int = mini(heart_damage, hearts)
	hearts -= lost
	_invuln = INVULN_TIME
	_shoot_lock = 0.25
	view.play("hurt")
	_shake = 4.0 + heart_damage * 2.0
	Audio.play("hurt")
	Audio.play("heart_break", -2.0)
	Audio.vibrate(60 + heart_damage * 40)
	_emit_hearts(lost)
	if hearts <= 0:
		alive = false
		died.emit()


func heal(amount: int) -> void:
	hearts = mini(hearts + amount, max_hearts)
	_emit_hearts(0)


func add_max_hearts(amount: int) -> void:
	max_hearts += amount
	hearts += amount
	_emit_hearts(0)


func revive() -> void:
	alive = true
	hearts = max_hearts
	_invuln = 2.0
	_emit_hearts(0)


func add_charge(amount: float) -> void:
	super_charge = minf(super_charge + amount, 100.0)
	Events.super_changed.emit(super_charge)


func _emit_hearts(lost: int) -> void:
	Events.hearts_changed.emit(hearts, max_hearts, lost)
