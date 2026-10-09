extends Weapon
## Apa sfințită (Corvin): aruncă sticle în arc; unde cad lasă o baltă care arde monștrii.

var cooldown: float = 2.6
var flasks: int = 1
var radius: float = 26.0
var dps: float = 10.0
var duration: float = 2.6
var _timer: float = 1.0
var _pending: Array = []  # [timp rămas, poziție]


func _init() -> void:
	weapon_name = "Apa sfințită"


func update_weapon(delta: float, player: Player, enemies: EnemyManager, projectiles: ProjectileManager) -> void:
	for p in _pending:
		p[0] -= delta
	while not _pending.is_empty() and _pending[0][0] <= 0.0:
		var land: Vector2 = _pending.pop_front()[1]
		zones.add(land, radius, duration, dps * player.damage_mult, ZoneManager.Kind.HOLY)
		Audio.play("splash", -6.0)
	_timer -= delta
	if _timer > 0.0:
		return
	_timer = cooldown
	for k in flasks:
		var t: int = Weapon.random_target(enemies, player.position, 170.0)
		var dest: Vector2 = enemies.pos[t] if t >= 0 else player.position + Vector2.from_angle(randf() * TAU) * 80.0
		var flight: float = 0.55
		projectiles.spawn(player.position + Vector2(0, -10), (dest - player.position) / flight, 0.0, 0, flight,
			ProjectileArt.Kind.FLASK, 0.0, false, true)
		_pending.append([flight, dest])
	_pending.sort_custom(func(a, b): return a[0] < b[0])
	if flasks > 0:
		player.shoot_towards(player.position + Vector2(1, 0))


func _apply_level(lvl: int) -> void:
	match lvl:
		2: flasks += 1
		3: dps *= 1.4
		4: radius *= 1.25
		5: flasks += 1
		6: duration += 1.2
		7: dps *= 1.4
		8:
			flasks += 2
			radius *= 1.2


func next_desc() -> String:
	match level + 1:
		2: return "+1 sticlă"
		3: return "+40% damage"
		4: return "Bălți mai mari"
		5: return "+1 sticlă"
		6: return "Bălțile durează mai mult"
		7: return "+40% damage"
		8: return "+2 sticle, bălți uriașe"
	return ""
