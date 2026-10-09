extends Weapon
## Lamele Lunii: lame care se rotesc în jurul eroului.

var count: int = 2
var orbit: float = 40.0
var spin: float = 3.2
var damage: float = 8.0
var blade_radius: float = 9.0
var _angle: float = 0.0
var _tick: float = 0.0


func _init() -> void:
	weapon_name = "Lamele Lunii"


func update_weapon(delta: float, player: Player, enemies: EnemyManager, _projectiles: ProjectileManager) -> void:
	position = player.position
	_angle = fmod(_angle + spin * delta, TAU)
	queue_redraw()
	_tick -= delta
	if _tick > 0.0:
		return
	_tick = 0.18
	for k in count:
		var bp: Vector2 = player.position + Vector2.from_angle(_angle + TAU * float(k) / float(count)) * orbit
		for i in enemies.grid.query(bp, blade_radius + 20.0):
			if enemies.hp[i] <= 0.0:
				continue
			var r: float = blade_radius + enemies.radius[i]
			if bp.distance_squared_to(enemies.pos[i]) < r * r:
				enemies.damage(i, damage * player.damage_mult)


func _apply_level(lvl: int) -> void:
	match lvl:
		2: count += 1
		3: damage *= 1.35
		4: orbit += 10.0
		5: count += 1
		6: spin *= 1.3
		7: damage *= 1.35
		8:
			count += 2
			blade_radius += 4.0


func next_desc() -> String:
	match level + 1:
		2: return "+1 lamă"
		3: return "+35% damage"
		4: return "Lamele se rotesc mai departe"
		5: return "+1 lamă"
		6: return "Se rotesc cu 30% mai repede"
		7: return "+35% damage"
		8: return "+2 lame, mai mari"
	return ""


func _draw() -> void:
	for k in count:
		var a: float = _angle + TAU * float(k) / float(count)
		var c: Vector2 = Vector2.from_angle(a) * orbit
		draw_circle(c, blade_radius * 0.55, Color(0.75, 0.85, 1.0, 0.9))
		draw_arc(c, blade_radius, a + 0.6, a + PI + 0.6, 10, Color(0.9, 0.95, 1.0), 3.0)
