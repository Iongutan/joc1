extends Weapon
## Floarea Albă: aură care rănește inamicii din jurul eroului.

var radius: float = 40.0
var damage: float = 5.0
var interval: float = 0.5
var _tick: float = 0.0
var _pulse: float = 0.0


func _init() -> void:
	weapon_name = "Floarea Albă"


func _ready() -> void:
	z_index = -1


func update_weapon(delta: float, player: Player, enemies: EnemyManager, _projectiles: ProjectileManager) -> void:
	position = player.position
	_pulse = maxf(_pulse - delta * 3.0, 0.0)
	queue_redraw()
	_tick -= delta
	if _tick > 0.0:
		return
	_tick = interval
	_pulse = 1.0
	for i in enemies.grid.query(player.position, radius + 24.0):
		if enemies.hp[i] <= 0.0:
			continue
		var r: float = radius + enemies.radius[i]
		if player.position.distance_squared_to(enemies.pos[i]) < r * r:
			enemies.damage(i, damage * player.damage_mult)


func _apply_level(lvl: int) -> void:
	match lvl:
		2: radius *= 1.2
		3: damage *= 1.4
		4: interval *= 0.8
		5: radius *= 1.2
		6: damage *= 1.4
		7: interval *= 0.8
		8:
			radius *= 1.25
			damage *= 1.3


func next_desc() -> String:
	match level + 1:
		2: return "+20% rază"
		3: return "+40% damage"
		4: return "Lovește cu 20% mai des"
		5: return "+20% rază"
		6: return "+40% damage"
		7: return "Lovește cu 20% mai des"
		8: return "Rază și damage mult mai mari"
	return ""


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color(0.85, 1.0, 0.85, 0.06 + _pulse * 0.08))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 48, Color(0.9, 1.0, 0.9, 0.25 + _pulse * 0.3), 2.0)
