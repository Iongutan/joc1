extends Weapon
## Meteorii (Mira): meteori cad pe monștri; întâi apare umbra, apoi impactul și focul rămas.

var cooldown: float = 3.0
var meteors: int = 1
var radius: float = 30.0
var damage: float = 40.0
var burn: float = 8.0
var _timer: float = 1.5


func _init() -> void:
	weapon_name = "Meteorii"


func update_weapon(delta: float, player: Player, enemies: EnemyManager, _projectiles: ProjectileManager) -> void:
	_timer -= delta
	if _timer > 0.0:
		return
	_timer = cooldown
	var any: bool = false
	for k in meteors:
		var t: int = Weapon.random_target(enemies, player.position, 220.0)
		if t < 0:
			continue
		any = true
		var at: Vector2 = enemies.pos[t]
		zones.add(at, radius, 0.01, 0.0, ZoneManager.Kind.METEOR, 0.8 + k * 0.15, damage * player.damage_mult)
		# focul rămas după impact
		zones.add(at, radius * 0.8, 1.6, 0.0, ZoneManager.Kind.FIRE, 0.8 + k * 0.15)
		zones.zones.back()["dps"] = burn * player.damage_mult
	if any:
		player.shoot_towards(player.position + Vector2(1, 0))


func _apply_level(lvl: int) -> void:
	match lvl:
		2: meteors += 1
		3: damage *= 1.4
		4: radius *= 1.2
		5: meteors += 1
		6: cooldown *= 0.75
		7: damage *= 1.4
		8: meteors += 3


func next_desc() -> String:
	match level + 1:
		2: return "+1 meteor"
		3: return "+40% damage"
		4: return "Impact mai mare"
		5: return "+1 meteor"
		6: return "Meteori mai des"
		7: return "+40% damage"
		8: return "+3 meteori"
	return ""
