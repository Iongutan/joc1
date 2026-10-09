extends Weapon
## Lavina (Ilva): țepi de gheață ies din pământ sub monștri, după un scurt semn de avertizare.

var cooldown: float = 2.4
var strikes: int = 2
var radius: float = 22.0
var damage: float = 26.0
var _timer: float = 1.2


func _init() -> void:
	weapon_name = "Lavina"


func update_weapon(delta: float, player: Player, enemies: EnemyManager, _projectiles: ProjectileManager) -> void:
	_timer -= delta
	if _timer > 0.0:
		return
	_timer = cooldown
	var any: bool = false
	for k in strikes:
		var t: int = Weapon.random_target(enemies, player.position, 200.0)
		if t < 0:
			continue
		any = true
		zones.add(enemies.pos[t], radius, 0.45, 0.0, ZoneManager.Kind.ICE_SPIKES, 0.5 + k * 0.08, damage * player.damage_mult, 1.0)
	if any:
		player.shoot_towards(player.position + Vector2(1, 0))


func _apply_level(lvl: int) -> void:
	match lvl:
		2: strikes += 1
		3: damage *= 1.4
		4: radius *= 1.25
		5: strikes += 1
		6: cooldown *= 0.75
		7: damage *= 1.4
		8: strikes += 3


func next_desc() -> String:
	match level + 1:
		2: return "+1 țeapă de gheață"
		3: return "+40% damage"
		4: return "Țepi mai mari"
		5: return "+1 țeapă de gheață"
		6: return "Lavina vine mai des"
		7: return "+40% damage"
		8: return "+3 țepi"
	return ""
