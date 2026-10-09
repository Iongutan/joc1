extends Weapon
## Arbaleta de argint: trage spre cel mai apropiat inamic.

var cooldown: float = 0.9
var damage: float = 12.0
var bolts: int = 1
var pierce: int = 1
var _timer: float = 0.0


func _init() -> void:
	weapon_name = "Arbaleta de argint"


func update_weapon(delta: float, player: Player, enemies: EnemyManager, projectiles: ProjectileManager) -> void:
	_timer -= delta
	if _timer > 0.0:
		return
	var target: int = enemies.nearest(player.position, 300.0)
	if target < 0:
		_timer = 0.1
		return
	_timer = cooldown
	player.shoot_towards(enemies.pos[target])
	Audio.play("shoot", -6.0)
	var dir: Vector2 = (enemies.pos[target] - player.position).normalized()
	for b in bolts:
		var off: float = (float(b) - float(bolts - 1) * 0.5) * 0.18
		projectiles.spawn(player.position + Vector2(0, -8), dir.rotated(off) * 260.0, damage * player.damage_mult, pierce, 1.6, ProjectileArt.Kind.BOLT)


func _apply_level(lvl: int) -> void:
	match lvl:
		2: bolts += 1
		3: damage *= 1.3
		4: cooldown *= 0.8
		5: pierce += 1
		6: bolts += 1
		7: damage *= 1.3
		8:
			bolts += 2
			cooldown *= 0.8


func next_desc() -> String:
	match level + 1:
		2: return "+1 săgeată"
		3: return "+30% damage"
		4: return "Trage cu 20% mai repede"
		5: return "Săgețile străpung încă un inamic"
		6: return "+1 săgeată"
		7: return "+30% damage"
		8: return "+2 săgeți și mai rapid"
	return ""
