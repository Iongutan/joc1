extends Weapon
## Mingea de foc (Mira): proiectil care explodează în zonă când lovește.

var cooldown: float = 1.1
var damage: float = 16.0
var balls: int = 1
var blast: float = 22.0
var _timer: float = 0.0


func _init() -> void:
	weapon_name = "Mingea de foc"


func update_weapon(delta: float, player: Player, enemies: EnemyManager, projectiles: ProjectileManager) -> void:
	_timer -= delta
	if _timer > 0.0:
		return
	var target: int = enemies.nearest(player.position, 260.0)
	if target < 0:
		_timer = 0.1
		return
	_timer = cooldown
	player.shoot_towards(enemies.pos[target])
	Audio.play("fire", -6.0)
	var dir: Vector2 = (enemies.pos[target] - player.position).normalized()
	for k in balls:
		var off: float = (float(k) - float(balls - 1) * 0.5) * 0.35
		projectiles.spawn(player.position + Vector2(0, -8), dir.rotated(off) * 190.0, damage * player.damage_mult, 1, 1.8,
			ProjectileArt.Kind.FIREBALL, blast)


func _apply_level(lvl: int) -> void:
	match lvl:
		2: blast *= 1.25
		3: damage *= 1.35
		4: balls += 1
		5: cooldown *= 0.8
		6: blast *= 1.25
		7: damage *= 1.35
		8:
			balls += 2
			blast *= 1.2


func next_desc() -> String:
	match level + 1:
		2: return "Explozie mai mare"
		3: return "+35% damage"
		4: return "+1 minge de foc"
		5: return "Aruncă cu 20% mai repede"
		6: return "Explozie mai mare"
		7: return "+35% damage"
		8: return "+2 mingi, explozii uriașe"
	return ""
