class_name Weapon
extends Node2D
## Baza tuturor armelor. Fiecare armă își suprascrie logica și nivelurile.

const MAX_LEVEL: int = 8

var weapon_name: String = ""
var level: int = 1
## Zonele de pe pământ (bălți, lovituri întârziate), setate de scena de luptă.
var zones: ZoneManager


func _enter_tree() -> void:
	# Efectele armelor strălucesc în întuneric.
	material = UiTheme.glow_material()


func update_weapon(_delta: float, _player: Player, _enemies: EnemyManager, _projectiles: ProjectileManager) -> void:
	pass


func upgrade() -> void:
	if level >= MAX_LEVEL:
		return
	level += 1
	_apply_level(level)


func _apply_level(_lvl: int) -> void:
	pass


## Textul pentru următorul nivel, afișat la alegerea puterii.
func next_desc() -> String:
	return ""


## Un inamic viu la întâmplare, în raza dată (pentru meteori, țepi, sticle).
static func random_target(enemies: EnemyManager, from: Vector2, max_dist: float) -> int:
	if enemies.n == 0:
		return -1
	var r2: float = max_dist * max_dist
	for attempt in 8:
		var i: int = randi() % enemies.n
		if enemies.hp[i] > 0.0 and from.distance_squared_to(enemies.pos[i]) < r2:
			return i
	return enemies.nearest(from, max_dist)
