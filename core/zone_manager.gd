class_name ZoneManager
extends Node2D
## Zone pe pământ: bălți de apă sfințită, foc rămas după meteori, și lovituri întârziate
## (țepi de gheață, meteori) care întâi arată un semn de avertizare, apoi lovesc.

signal impact(at: Vector2, radius: float, kind: int)

enum Kind { HOLY, FIRE, ICE_SPIKES, METEOR }

const MAX: int = 64
const TICK: float = 0.3

var zones: Array[Dictionary] = []
var _tick: float = 0.0
var _t: float = 0.0


func _ready() -> void:
	material = UiTheme.glow_material()
	z_index = -5


## delay > 0 = lovitură întârziată (semn pe pământ, apoi impact cu impact_dmg).
func add(at: Vector2, radius: float, life: float, dps: float, kind: int, delay: float = 0.0, impact_dmg: float = 0.0, slow: float = 0.0) -> void:
	if zones.size() >= MAX:
		zones.pop_front()
	zones.append({"pos": at, "r": radius, "life": life, "max": life, "dps": dps, "kind": kind,
		"delay": delay, "impact": impact_dmg, "slow": slow, "struck": delay <= 0.0})


func update_zones(delta: float, enemies: EnemyManager) -> void:
	_t += delta
	_tick -= delta
	var do_tick: bool = _tick <= 0.0
	if do_tick:
		_tick = TICK
	var i: int = 0
	while i < zones.size():
		var z: Dictionary = zones[i]
		if z["delay"] > 0.0:
			z["delay"] -= delta
			if z["delay"] <= 0.0:
				z["struck"] = true
				if z["impact"] > 0.0:
					enemies.damage_in_radius(z["pos"], z["r"], z["impact"])
					impact.emit(z["pos"], z["r"], z["kind"])
			i += 1
			continue
		z["life"] -= delta
		if z["life"] <= 0.0:
			zones.remove_at(i)
			continue
		if do_tick and z["dps"] > 0.0:
			enemies.damage_in_radius(z["pos"], z["r"], z["dps"] * TICK)
		if z["slow"] > 0.0:
			enemies.slow_in_radius(z["pos"], z["r"], z["slow"])
		i += 1
	queue_redraw()


func _draw() -> void:
	for z in zones:
		var p: Vector2 = z["pos"]
		var r: float = z["r"]
		var k: int = z["kind"]
		if z["delay"] > 0.0:
			# semn de avertizare care se strânge
			var col := Color(0.6, 0.9, 1.0) if k == Kind.ICE_SPIKES else Color(1.0, 0.45, 0.2)
			draw_circle(p, r, Color(col.r, col.g, col.b, 0.12))
			draw_arc(p, r, 0.0, TAU, 24, Color(col, 0.8), 1.0)
			draw_arc(p, r * clampf(z["delay"] / 0.8, 0.0, 1.0), 0.0, TAU, 24, Color(col, 0.5), 1.0)
			if k == Kind.METEOR:
				# meteorul care cade, din stânga-sus
				var h: float = z["delay"] * 160.0
				var m := p + Vector2(-h * 0.5, -h)
				draw_circle(m, 5.0, Color(1.0, 0.55, 0.15))
				draw_circle(m, 3.0, Color(1.0, 0.95, 0.6))
				draw_line(m, m + Vector2(-10, -20), Color(1.0, 0.5, 0.1, 0.6), 3.0)
			continue
		var fade: float = clampf(z["life"] / maxf(z["max"], 0.01), 0.0, 1.0)
		match k:
			Kind.HOLY:
				draw_circle(p, r, Color(0.45, 0.75, 1.0, 0.28 * fade))
				draw_arc(p, r, 0.0, TAU, 24, Color(0.75, 0.9, 1.0, 0.7 * fade), 1.0)
				for s in 5:
					var a: float = _t * 2.0 + s * 1.3
					var q := p + Vector2(cos(a), sin(a * 1.3)) * r * 0.6
					draw_rect(Rect2(q.floor(), Vector2(2, 2)), Color(0.9, 0.97, 1.0, fade))
			Kind.FIRE:
				draw_circle(p, r, Color(1.0, 0.4, 0.1, 0.22 * fade))
				for s in 6:
					var fx: float = p.x + (float(s) - 2.5) * r * 0.32
					var fh: float = (5.0 + 3.0 * sin(_t * 9.0 + s)) * fade
					draw_colored_polygon(PackedVector2Array([Vector2(fx - 3, p.y + 2), Vector2(fx, p.y - fh), Vector2(fx + 3, p.y + 2)]), Color(1.0, 0.6, 0.15, fade))
			Kind.ICE_SPIKES:
				for s in 7:
					var a: float = TAU * float(s) / 7.0
					var q := p + Vector2.from_angle(a) * r * 0.55
					var hgt: float = 12.0 * fade
					draw_colored_polygon(PackedVector2Array([q + Vector2(-3, 2), q + Vector2(0, -hgt), q + Vector2(3, 2)]), Color(0.7, 0.95, 1.0, fade))
					draw_line(q + Vector2(0, -hgt), q + Vector2(-1, 0), Color(1, 1, 1, fade), 1.0)
			Kind.METEOR:
				draw_circle(p, r, Color(0.2, 0.1, 0.05, 0.4 * fade))
