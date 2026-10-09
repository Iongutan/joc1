extends Weapon
## Ace de gheață (Ilva): cioburi care urmăresc ținta și încetinesc ce ating.

var cooldown: float = 0.75
var damage: float = 10.0
var shards: int = 2
var pierce: int = 1
var _timer: float = 0.0


func _init() -> void:
	weapon_name = "Ace de gheață"


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
	Audio.play("ice", -8.0)
	var dir: Vector2 = (enemies.pos[target] - player.position).normalized()
	for k in shards:
		var off: float = (float(k) - float(shards - 1) * 0.5) * 0.6
		projectiles.spawn(player.position + Vector2(0, -8), dir.rotated(off) * 210.0, damage * player.damage_mult, pierce, 1.8,
			ProjectileArt.Kind.SHARD, 0.0, true)


func _apply_level(lvl: int) -> void:
	match lvl:
		2: shards += 1
		3: damage *= 1.35
		4: cooldown *= 0.8
		5: pierce += 1
		6: shards += 1
		7: damage *= 1.35
		8:
			shards += 2
			pierce += 1


func next_desc() -> String:
	match level + 1:
		2: return "+1 ac de gheață"
		3: return "+35% damage"
		4: return "Lansează cu 20% mai repede"
		5: return "Acele străpung un inamic în plus"
		6: return "+1 ac de gheață"
		7: return "+35% damage"
		8: return "+2 ace, străpung mai mult"
	return ""
