extends Weapon
## Inelul de flăcări (Mira): sfere de foc care se rotesc în jurul ei, cu dâră de scântei.

var count: int = 2
var orbit: float = 40.0
var spin: float = 3.0
var damage: float = 9.0
var orb_radius: float = 8.0
var _angle: float = 0.0
var _tick: float = 0.0
var _t: float = 0.0


func _init() -> void:
	weapon_name = "Inelul de flăcări"


func update_weapon(delta: float, player: Player, enemies: EnemyManager, _projectiles: ProjectileManager) -> void:
	position = player.position
	_t += delta
	_angle = fmod(_angle + spin * delta, TAU)
	queue_redraw()
	_tick -= delta
	if _tick > 0.0:
		return
	_tick = 0.2
	for k in count:
		var bp: Vector2 = player.position + Vector2.from_angle(_angle + TAU * float(k) / float(count)) * orbit
		enemies.damage_in_radius(bp, orb_radius + 8.0, damage * player.damage_mult)


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
			orb_radius += 3.0


func next_desc() -> String:
	match level + 1:
		2: return "+1 sferă de foc"
		3: return "+35% damage"
		4: return "Sferele se rotesc mai departe"
		5: return "+1 sferă de foc"
		6: return "Se rotesc cu 30% mai repede"
		7: return "+35% damage"
		8: return "+2 sfere, mai mari"
	return ""


func _draw() -> void:
	for k in count:
		var a: float = _angle + TAU * float(k) / float(count)
		var c: Vector2 = Vector2.from_angle(a) * orbit
		# dâra de scântei în urmă
		for s in 4:
			var ta: float = a - float(s + 1) * 0.18
			draw_circle(Vector2.from_angle(ta) * orbit, orb_radius * (0.7 - s * 0.15), Color(1.0, 0.45, 0.1, 0.35 - s * 0.08))
		draw_circle(c, orb_radius + 3.0, Color(1.0, 0.4, 0.1, 0.3))
		draw_circle(c, orb_radius, Color(1.0, 0.55, 0.15))
		draw_circle(c, orb_radius * 0.55, Color(1.0, 0.9, 0.5))
		draw_rect(Rect2((c + Vector2(-2, -3)).floor(), Vector2(2, 2)), Color.WHITE)
