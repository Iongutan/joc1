extends Weapon
## Pistolul cu cremene (Corvin): foc în evantai, scurt și puternic, împinge inamicii.

var cooldown: float = 1.4
var damage: float = 9.0
var pellets: int = 5
var spread: float = 0.55
var push: float = 10.0
var _timer: float = 0.6
var _flash: float = 0.0
var _dir := Vector2.RIGHT


func _init() -> void:
	weapon_name = "Pistolul cu cremene"


func update_weapon(delta: float, player: Player, enemies: EnemyManager, projectiles: ProjectileManager) -> void:
	position = player.position
	if _flash > 0.0:
		_flash -= delta
		queue_redraw()
	_timer -= delta
	if _timer > 0.0:
		return
	var target: int = enemies.nearest(player.position, 150.0)
	if target < 0:
		_timer = 0.15
		return
	_timer = cooldown
	_dir = (enemies.pos[target] - player.position).normalized()
	player.shoot_towards(enemies.pos[target])
	Audio.play("pistol", -4.0)
	Events.shake.emit(2.5)
	_flash = 0.1
	for k in pellets:
		var a: float = (float(k) / float(maxi(pellets - 1, 1)) - 0.5) * spread
		projectiles.spawn(player.position, _dir.rotated(a) * 300.0, damage * player.damage_mult, 1, 0.45, ProjectileArt.Kind.PELLET)
	# reculul împinge inamicii din fața țevii
	for i in enemies.grid.query(player.position + _dir * 30.0, 40.0):
		enemies.push_enemy(i, _dir * push)


func _draw() -> void:
	if _flash <= 0.0:
		return
	var m := _dir * 16.0
	draw_circle(m, 7.0, Color(1.0, 0.7, 0.2, 0.8))
	draw_circle(m, 4.0, Color(1.0, 1.0, 0.8))
	draw_circle(m + _dir * 8.0 + Vector2(0, -4), 5.0, Color(0.7, 0.7, 0.75, 0.5))


func _apply_level(lvl: int) -> void:
	match lvl:
		2: pellets += 2
		3: damage *= 1.35
		4: cooldown *= 0.8
		5: push += 8.0
		6: pellets += 2
		7: damage *= 1.35
		8:
			cooldown *= 0.7
			spread += 0.25


func next_desc() -> String:
	match level + 1:
		2: return "+2 alice"
		3: return "+35% damage"
		4: return "Reîncarcă cu 20% mai repede"
		5: return "Împinge inamicii mai tare"
		6: return "+2 alice"
		7: return "+35% damage"
		8: return "Foc rapid, evantai mai larg"
	return ""
