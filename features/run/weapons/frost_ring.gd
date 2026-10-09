extends Weapon
## Cercul de ger (Ilva): aură de gheață care rănește și încetinește inamicii din jur.

var radius: float = 42.0
var damage: float = 4.0
var interval: float = 0.5
var slow_time: float = 0.8
var _tick: float = 0.0
var _pulse: float = 0.0
var _t: float = 0.0


func _init() -> void:
	weapon_name = "Cercul de ger"


func _ready() -> void:
	z_index = -1


func update_weapon(delta: float, player: Player, enemies: EnemyManager, _projectiles: ProjectileManager) -> void:
	position = player.position + Vector2(0, 14)
	_t += delta
	_pulse = maxf(_pulse - delta * 3.0, 0.0)
	queue_redraw()
	_tick -= delta
	if _tick > 0.0:
		return
	_tick = interval
	_pulse = 1.0
	enemies.damage_in_radius(position, radius, damage * player.damage_mult)
	enemies.slow_in_radius(position, radius, slow_time)


func _apply_level(lvl: int) -> void:
	match lvl:
		2: radius *= 1.2
		3: damage *= 1.5
		4: slow_time += 0.6
		5: radius *= 1.2
		6: interval *= 0.75
		7: damage *= 1.5
		8:
			radius *= 1.25
			slow_time += 0.8


func next_desc() -> String:
	match level + 1:
		2: return "+20% rază"
		3: return "+50% damage"
		4: return "Încetinește mai mult timp"
		5: return "+20% rază"
		6: return "Lovește mai des"
		7: return "+50% damage"
		8: return "Rază uriașă, îngheț lung"
	return ""


func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.55))
	draw_circle(Vector2.ZERO, radius, Color(0.6, 0.9, 1.0, 0.07 + _pulse * 0.08))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 40, Color(0.75, 0.95, 1.0, 0.35 + _pulse * 0.4), 2.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# fulgi care se rotesc pe margine
	for k in 8:
		var a: float = _t * 0.8 + TAU * float(k) / 8.0
		var p := Vector2(cos(a) * radius, sin(a) * radius * 0.55)
		draw_rect(Rect2(p.floor() - Vector2(1, 1), Vector2(3, 1)), Color(1, 1, 1, 0.8))
		draw_rect(Rect2(p.floor() - Vector2(0, 2), Vector2(1, 3)), Color(1, 1, 1, 0.8))
