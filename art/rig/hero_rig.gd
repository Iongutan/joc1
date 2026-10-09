class_name HeroRig
extends Node2D
## Eroul ca „păpușă”: părți separate (păr, pălărie, brațe, picioare, haine, armă) desenate
## la rezoluție mică și animate independent. HeroView le mărește și adaugă contur pixel.
## Unitate = 1 pixel. Originea (0,0) = între picioare, pe sol; y negativ = în sus.

const HEROES := {
	"corvin": {
		"name": "Corvin", "title": "Vânătorul", "female": false,
		"skin": "f2c9a0", "hair": "2a2e48", "hair_hi": "5a6490", "eye": "e0a030",
		"top": "2a2c3a", "top_hi": "454a60", "trim": "c9d3e6", "accent": "c8283a",
		"bottom": "3b3f55", "boots": "5a3a26", "hat": "3a2a22", "hat_band": "c8283a", "weapon": "crossbow",
	},
	"bran": {
		"name": "Bran", "title": "Străjerul", "female": false,
		"skin": "eab48c", "hair": "6a4026", "hair_hi": "9a6a40", "eye": "4a7ad0",
		"top": "2f5fa8", "top_hi": "4f80c8", "trim": "e8b84a", "accent": "e0e4ec",
		"bottom": "565e70", "boots": "7d8699", "hat": "a8b0c0", "hat_band": "2f5fa8", "weapon": "sword",
	},
	"ilva": {
		"name": "Ilva", "title": "Vrăjitoarea de gheață", "female": true,
		"skin": "fbe0cc", "hair": "e4ecf8", "hair_hi": "ffffff", "eye": "3fb6e8",
		"top": "26467e", "top_hi": "3d64a8", "trim": "ffffff", "accent": "7fd6f0",
		"bottom": "6fa8dc", "boots": "e8f0ff", "hat": "c4d4f0", "hat_band": "2a8aa8", "weapon": "staff",
	},
	"mira": {
		"name": "Mira", "title": "Fiica Focului", "female": true,
		"skin": "f7d2b6", "hair": "e0502a", "hair_hi": "ffa050", "eye": "36b060",
		"top": "8a1a2a", "top_hi": "b8303e", "trim": "f2c14e", "accent": "ff8a3a",
		"bottom": "2a1a2a", "boots": "5a2a1e", "hat": "f2c14e", "hat_band": "ff6a3a", "weapon": "orb",
	},
}

const LINE_DARK: float = 0.5

var hero_id: String = "corvin"
var anim: String = "idle"
var t: float = 0.0
var anim_t: float = 0.0
var facing: float = 1.0

var _c: Dictionary = {}


func set_hero(id: String) -> void:
	hero_id = id if HEROES.has(id) else "corvin"
	_c.clear()
	var h: Dictionary = HEROES[hero_id]
	for k in h:
		if h[k] is String and (h[k] as String).length() == 6 and (h[k] as String).is_valid_hex_number():
			_c[k] = Color.html(h[k])
	queue_redraw()


func play(a: String) -> void:
	if anim != a:
		anim = a
		anim_t = 0.0


func _ready() -> void:
	if _c.is_empty():
		set_hero(hero_id)


## Pixel art-ul se animă tradițional la ~12 cadre pe secundă; redesenăm doar când se schimbă cadrul.
const ANIM_FPS: float = 12.0
var _last_frame: int = -1


func _process(delta: float) -> void:
	t += delta
	anim_t += delta
	var f: int = int(t * ANIM_FPS)
	if f != _last_frame:
		_last_frame = f
		queue_redraw()
		# viewport-ul păpușii se randează doar când se schimbă cadrul
		var vp := get_viewport() as SubViewport
		if vp != null:
			vp.render_target_update_mode = SubViewport.UPDATE_ONCE


# --- ajutoare de desen ---------------------------------------------------

func _poly(pts: PackedVector2Array, col: Color, line: bool = true) -> void:
	if pts.size() < 3:
		return
	# când animația răsucește o formă până se auto-intersectează, folosim conturul ei convex
	var fill := pts
	if Geometry2D.triangulate_polygon(fill).is_empty():
		fill = Geometry2D.convex_hull(pts)
		if fill.size() > 1 and fill[0] == fill[fill.size() - 1]:
			fill.remove_at(fill.size() - 1)
		if fill.size() < 3 or Geometry2D.triangulate_polygon(fill).is_empty():
			return
	draw_colored_polygon(fill, col)
	if line:
		var closed := pts.duplicate()
		closed.append(pts[0])
		draw_polyline(closed, col.darkened(LINE_DARK), 1.0)


func _rot(pts: Array, pivot: Vector2, ang: float, off: Vector2 = Vector2.ZERO) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in pts:
		out.append(pivot + off + (p as Vector2).rotated(ang))
	return out


## Membru (braț/picior) ca patrulater de la încheietură în direcția unghiului.
func _limb(from: Vector2, ang: float, length: float, w0: float, w1: float, col: Color) -> Vector2:
	var dir := Vector2.from_angle(ang)
	var n := dir.orthogonal()
	var to: Vector2 = from + dir * length
	_poly(PackedVector2Array([from + n * w0, to + n * w1, to - n * w1, from - n * w0]), col)
	return to


func _ellipse(c: Vector2, rx: float, ry: float, col: Color, seg: int = 16, line: bool = true) -> void:
	var pts := PackedVector2Array()
	for i in seg:
		var a: float = TAU * float(i) / float(seg)
		pts.append(c + Vector2(cos(a) * rx, sin(a) * ry))
	_poly(pts, col, line)


func _px(p: Vector2, col: Color, w: float = 1.0, h: float = 1.0) -> void:
	draw_rect(Rect2(p.floor(), Vector2(w, h)), col)


# --- pozele animației ----------------------------------------------------

func _pose() -> Dictionary:
	var p := {
		"bob": 0.0, "lift": 0.0, "lean": 0.0, "leg_f": 0.0, "leg_b": 0.0,
		"arm_f": 0.35, "arm_b": -0.35, "sway": sin(t * 2.2) * 0.12, "blink": fmod(t, 3.3) < 0.12,
		"hurt": false, "glow": 0.0, "flash": false,
	}
	match anim:
		"idle":
			p["bob"] = round(sin(t * 2.6) * 0.6 + 0.4)
			p["arm_f"] = 0.3 + sin(t * 2.6) * 0.05
		"run":
			var s: float = sin(anim_t * 13.0)
			p["leg_f"] = s * 0.75
			p["leg_b"] = -s * 0.75
			p["arm_f"] = -s * 0.8 + 0.2
			p["arm_b"] = s * 0.8 - 0.2
			p["bob"] = -round(absf(cos(anim_t * 13.0)) * 1.5)
			p["lean"] = 0.08
			p["sway"] = -0.35 + sin(anim_t * 13.0) * 0.08
		"attack":
			var k: float = clampf(anim_t / 0.12, 0.0, 1.0)
			p["arm_f"] = lerpf(0.3, -1.45, k)
			p["lean"] = 0.06
			p["flash"] = anim_t < 0.1
		"super":
			var k: float = clampf(anim_t / 0.3, 0.0, 1.0)
			p["lift"] = -round(k * 5.0 + sin(t * 6.0))
			p["arm_f"] = lerpf(0.3, -2.6, k)
			p["arm_b"] = lerpf(-0.35, 2.6, k)
			p["leg_f"] = 0.25
			p["leg_b"] = -0.35
			p["sway"] = -0.6 + sin(t * 9.0) * 0.15
			p["glow"] = k
		"hurt":
			p["lean"] = -0.2
			p["arm_f"] = 0.9
			p["arm_b"] = -0.9
			p["hurt"] = true
		"victory":
			p["lift"] = -round(absf(sin(anim_t * 5.0)) * 6.0)
			p["arm_f"] = -2.7
			p["arm_b"] = -0.4
	return p


# --- desenul -------------------------------------------------------------

func _draw() -> void:
	if _c.is_empty():
		return
	var h: Dictionary = HEROES[hero_id]
	var p := _pose()
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1.0))
	var base := Vector2(0, p["lift"])
	var hip := base + Vector2(0, -12 + p["bob"])
	var chest := hip + Vector2(p["lean"] * 14.0, -12)
	var head := chest + Vector2(p["lean"] * 6.0, -11)

	if p["glow"] > 0.0:
		var g: float = p["glow"]
		draw_circle(base + Vector2(0, -22), 20.0 * g, Color(_c["accent"], 0.18))
		draw_arc(base + Vector2(0, 1), 14.0 * g, 0.0, TAU, 20, Color(_c["accent"], 0.8), 1.0)

	_hair_back(head, p, h)
	_cape(chest, hip, p, h)
	# piciorul și brațul din spate
	_leg(hip + Vector2(-2.5, 0), p["leg_b"], h, true)
	var hand_b := _arm(chest + Vector2(-5.5, 1), p["arm_b"] + PI * 0.5, h, true)
	if h["weapon"] == "sword":
		_shield(hand_b)
	_leg(hip + Vector2(2.5, 0), p["leg_f"], h, false)
	_torso(chest, hip, h)
	_head(head, p, h)
	var hand_f := _arm(chest + Vector2(5.5, 1), p["arm_f"] + PI * 0.5, h, false)
	_weapon(hand_f, p["arm_f"] + PI * 0.5, p, h)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _leg(top: Vector2, ang: float, h: Dictionary, back: bool) -> void:
	var col: Color = _c["bottom"].darkened(0.25 if back else 0.0)
	if h["female"]:
		col = Color(0.16, 0.12, 0.2).darkened(0.2 if back else 0.0)
	var knee := _limb(top, PI * 0.5 + ang, 6.0, 2.2, 2.0, col)
	var boot: Color = _c["boots"].darkened(0.25 if back else 0.0)
	var foot := _limb(knee, PI * 0.5 + ang * 0.6, 5.0, 2.2, 2.4, boot)
	_poly(PackedVector2Array([foot + Vector2(-2.4, -1), foot + Vector2(3.6, -1), foot + Vector2(3.6, 1), foot + Vector2(-2.4, 1)]), boot)
	if not back:
		_px(knee + Vector2(-2, 1), _c["trim"], 4, 1)


func _arm(shoulder: Vector2, ang: float, h: Dictionary, back: bool) -> Vector2:
	var sleeve: Color = _c["top"].darkened(0.3 if back else 0.0)
	var elbow := _limb(shoulder, ang, 5.0, 2.2, 1.9, sleeve)
	var hand := _limb(elbow, ang - 0.15, 4.0, 1.8, 1.6, sleeve.lightened(0.05))
	_px(elbow - Vector2(1.5, 0.5), _c["trim"], 3, 1)
	draw_circle(hand, 1.7, _c["skin"].darkened(0.2 if back else 0.0))
	return hand


func _torso(chest: Vector2, hip: Vector2, h: Dictionary) -> void:
	var top: Color = _c["top"]
	var hi: Color = _c["top_hi"]
	var trim: Color = _c["trim"]
	var sh_l := chest + Vector2(-6.5, 0)
	var sh_r := chest + Vector2(6.5, 0)
	if h["female"]:
		# fustă în straturi, cu volănaș
		var skirt: Color = _c["bottom"]
		_poly(PackedVector2Array([hip + Vector2(-5, -2), hip + Vector2(5, -2), hip + Vector2(9, 5), hip + Vector2(-9, 5)]), skirt)
		_poly(PackedVector2Array([hip + Vector2(-9, 4), hip + Vector2(9, 4), hip + Vector2(10, 6), hip + Vector2(-10, 6)]), trim)
		for i in 4:
			_px(hip + Vector2(-6 + i * 4, 0), skirt.darkened(0.25), 1, 4)
		_poly(PackedVector2Array([sh_l, sh_r, hip + Vector2(4.5, -2), hip + Vector2(-4.5, -2)]), top)
		_poly(PackedVector2Array([sh_l + Vector2(1, 0), chest + Vector2(0, 5), sh_r + Vector2(-1, 0), chest + Vector2(0, -1)]), trim)
		draw_circle(chest + Vector2(0, 3), 1.6, _c["accent"])
		_px(chest + Vector2(0, 2.5), Color.WHITE)
		_poly(PackedVector2Array([hip + Vector2(-5, -4), hip + Vector2(5, -4), hip + Vector2(5, -2), hip + Vector2(-5, -2)]), _c["hat_band"])
	else:
		# haină lungă / tunică
		_poly(PackedVector2Array([hip + Vector2(-5.5, -2), hip + Vector2(5.5, -2), hip + Vector2(7, 4), hip + Vector2(-7, 4)]), top.darkened(0.15))
		_poly(PackedVector2Array([sh_l, sh_r, hip + Vector2(5.5, -1), hip + Vector2(-5.5, -1)]), top)
		_poly(PackedVector2Array([chest + Vector2(-1, 0), chest + Vector2(2, 0), hip + Vector2(2, -1), hip + Vector2(-1, -1)]), hi, false)
		for i in 3:
			_px(chest + Vector2(0, 2 + i * 3), trim)
		_poly(PackedVector2Array([hip + Vector2(-5.5, -4), hip + Vector2(5.5, -4), hip + Vector2(5.5, -2), hip + Vector2(-5.5, -2)]), Color(0.3, 0.2, 0.12))
		_px(hip + Vector2(-1, -4), _c["trim"], 3, 2)
		if h["weapon"] == "sword":
			# pauldroane și emblemă
			_ellipse(sh_l + Vector2(0, 1), 3.2, 2.6, _c["hat"], 10)
			_ellipse(sh_r + Vector2(0, 1), 3.2, 2.6, _c["hat"], 10)
			_poly(PackedVector2Array([chest + Vector2(-2, 3), chest + Vector2(2, 3), chest + Vector2(0, 7)]), trim)
		else:
			# eșarfa roșie la gât
			_poly(PackedVector2Array([chest + Vector2(-5, -1), chest + Vector2(5, -1), chest + Vector2(4, 2), chest + Vector2(-4, 2)]), _c["accent"])


func _cape(chest: Vector2, hip: Vector2, p: Dictionary, h: Dictionary) -> void:
	var sway: float = p["sway"]
	if h["weapon"] == "crossbow":
		# capătul eșarfei flutură în spate
		var a := chest + Vector2(-3, 0)
		var w1 := a + Vector2(-6, 3).rotated(sway * 0.8) + Vector2(sin(t * 7.0), 0)
		var w2 := a + Vector2(-12, 6).rotated(sway) + Vector2(sin(t * 7.0 + 1.0) * 1.5, 0)
		_poly(PackedVector2Array([a, a + Vector2(0, 3), w1 + Vector2(0, 3), w2 + Vector2(0, 2), w2, w1]), _c["accent"].darkened(0.1))
	elif h["weapon"] == "sword" or h["weapon"] == "orb":
		var col: Color = _c["accent"].darkened(0.35) if h["weapon"] == "sword" else _c["top"].darkened(0.3)
		var tip := hip + Vector2(-7, 7).rotated(sway * 0.5)
		_poly(PackedVector2Array([chest + Vector2(-6, 0), chest + Vector2(5, 0), hip + Vector2(6, 6), tip + Vector2(sin(t * 4.0), 0)]), col)


func _head(c: Vector2, p: Dictionary, h: Dictionary) -> void:
	var skin: Color = _c["skin"]
	_ellipse(c, 9.0, 8.5, skin, 18)
	# umbra de sub păr
	_poly(PackedVector2Array([c + Vector2(-8, -3), c + Vector2(8, -3), c + Vector2(7, -1), c + Vector2(-7, -1)]), skin.darkened(0.12), false)
	_hair_front(c, p, h)
	# ochii mari, stil anime
	var eye: Color = _c["eye"]
	for ex in [-3.0, 3.5]:
		var e := c + Vector2(ex, 0)
		if p["hurt"]:
			draw_line(e + Vector2(-1.5, -1), e + Vector2(1.5, 1), Color(0.1, 0.05, 0.1), 1.0)
			draw_line(e + Vector2(-1.5, 1), e + Vector2(1.5, -1), Color(0.1, 0.05, 0.1), 1.0)
		elif p["blink"]:
			_px(e + Vector2(-1.5, 1), Color(0.1, 0.05, 0.1), 3, 1)
		else:
			_px(e + Vector2(-1.5, -2), Color(0.1, 0.06, 0.12), 3, 1)
			_px(e + Vector2(-1.5, -1), Color(0.1, 0.06, 0.12), 3, 4)
			_px(e + Vector2(-0.5, 0), eye, 2, 3)
			_px(e + Vector2(-1.5, -1), Color.WHITE)
			_px(e + Vector2(0.5, 2), eye.lightened(0.4))
			if h["female"]:
				_px(e + Vector2(1.5, -2), Color(0.1, 0.06, 0.12))
	# obraji și gura
	_px(c + Vector2(-6, 3), Color(1.0, 0.55, 0.6, 0.8), 2, 1)
	_px(c + Vector2(5, 3), Color(1.0, 0.55, 0.6, 0.8), 2, 1)
	_px(c + Vector2(0, 5), Color(0.6, 0.25, 0.3) if not p["hurt"] else Color(0.3, 0.1, 0.1), 2, 1)
	_hat(c, p, h)


func _hair_back(c: Vector2, p: Dictionary, h: Dictionary) -> void:
	var hair: Color = _c["hair"]
	var sway: float = p["sway"]
	if h["female"]:
		# păr lung care curge pe spate și flutură
		var pts := PackedVector2Array()
		pts.append(c + Vector2(-10, -3))
		pts.append(c + Vector2(10, -3))
		pts.append(c + Vector2(10, 10))
		var tip_r := c + Vector2(8, 22).rotated(sway * 0.6)
		var tip_l := c + Vector2(-13, 20).rotated(sway)
		pts.append(tip_r + Vector2(sin(t * 3.0), 0))
		pts.append(c + Vector2(0, 16))
		pts.append(tip_l + Vector2(sin(t * 3.0 + 1.0) * 1.5, 0))
		pts.append(c + Vector2(-11, 6))
		_poly(pts, hair.darkened(0.18))
		if hero_id == "mira":
			# coadă de cal legată sus
			var base := c + Vector2(-8, -6)
			var tail := PackedVector2Array([base, base + Vector2(-3, -2), base + Vector2(-10, 6).rotated(sway), base + Vector2(-12, 16).rotated(sway * 1.3), base + Vector2(-6, 10).rotated(sway)])
			_poly(tail, hair)
			_px(base + Vector2(-1, -1), _c["hat"], 3, 2)
		# șuvițe
		for i in 3:
			var s := c + Vector2(-8 + i * 7, 8)
			draw_line(s, s + Vector2(-1, 8).rotated(sway), hair.darkened(0.35), 1.0)
	else:
		_ellipse(c + Vector2(-0.5, -1), 10.0, 9.5, hair.darkened(0.2), 14)


func _hair_front(c: Vector2, p: Dictionary, h: Dictionary) -> void:
	var hair: Color = _c["hair"]
	var hi: Color = _c["hair_hi"]
	var sway: float = p["sway"] * 4.0
	# bretonul în zig-zag
	var bangs := PackedVector2Array([
		c + Vector2(-9.5, -1), c + Vector2(-9, -7), c + Vector2(-4, -10), c + Vector2(3, -10), c + Vector2(9, -7),
		c + Vector2(9.5, 0), c + Vector2(7, -3), c + Vector2(5 + sway * 0.3, 0), c + Vector2(3, -4),
		c + Vector2(0, -1), c + Vector2(-2, -4), c + Vector2(-5 + sway * 0.3, 0), c + Vector2(-7, -3),
	])
	_poly(bangs, hair)
	draw_line(c + Vector2(-5, -8), c + Vector2(1, -9), hi, 1.0)
	_px(c + Vector2(4, -8), hi, 2, 1)
	if h["female"]:
		# șuvițe lungi în fața urechilor
		_poly(PackedVector2Array([c + Vector2(-9.5, -2), c + Vector2(-8, -2), c + Vector2(-8 + sway * 0.2, 9), c + Vector2(-10.5 + sway * 0.2, 8)]), hair)
		_poly(PackedVector2Array([c + Vector2(8, -2), c + Vector2(9.5, -2), c + Vector2(10.5 + sway * 0.2, 8), c + Vector2(8 + sway * 0.2, 9)]), hair)


func _hat(c: Vector2, p: Dictionary, h: Dictionary) -> void:
	var col: Color = _c["hat"]
	var band: Color = _c["hat_band"]
	match hero_id:
		"corvin":
			# pălărie de vânător cu bor lat și pană
			_poly(PackedVector2Array([c + Vector2(-13, -7), c + Vector2(13, -8), c + Vector2(11, -5), c + Vector2(-11, -5)]), col)
			_poly(PackedVector2Array([c + Vector2(-7, -8), c + Vector2(-6, -15), c + Vector2(6, -16), c + Vector2(7, -8)]), col.lightened(0.08))
			_poly(PackedVector2Array([c + Vector2(-7, -10), c + Vector2(7, -10), c + Vector2(7, -8), c + Vector2(-7, -8)]), band, false)
			_px(c + Vector2(-1, -10), _c["trim"], 3, 2)
			var f := c + Vector2(6, -11)
			_poly(PackedVector2Array([f, f + Vector2(5, -6).rotated(p["sway"]), f + Vector2(7, -9).rotated(p["sway"]), f + Vector2(2, -2)]), Color(0.95, 0.95, 1.0))
		"bran":
			# coif de oțel cu panaș albastru
			_poly(PackedVector2Array([c + Vector2(-10, -1), c + Vector2(-10, -8), c + Vector2(-5, -13), c + Vector2(5, -13), c + Vector2(10, -8), c + Vector2(10, -1), c + Vector2(8, -2), c + Vector2(8, -6), c + Vector2(-8, -6), c + Vector2(-8, -2)]), col)
			draw_line(c + Vector2(-6, -11), c + Vector2(2, -12), col.lightened(0.35), 1.0)
			_poly(PackedVector2Array([c + Vector2(-1, -13), c + Vector2(1, -13), c + Vector2(-6, -21).rotated(p["sway"] * 0.5) + Vector2(sin(t * 5.0), 0), c + Vector2(-9, -16).rotated(p["sway"])]), band)
			_px(c + Vector2(-10, -4), _c["trim"], 2, 2)
		"ilva":
			# pălărie înaltă de vrăjitoare, cu vârful îndoit și fulg de nea
			_poly(PackedVector2Array([c + Vector2(-14, -6), c + Vector2(14, -8), c + Vector2(12, -4), c + Vector2(-12, -3)]), col)
			var tip := c + Vector2(10, -27) + Vector2(sin(t * 2.0) * 1.0, 0)
			_poly(PackedVector2Array([c + Vector2(-8, -7), c + Vector2(-3, -18), tip + Vector2(-4, 4), tip, tip + Vector2(1, 3), c + Vector2(4, -17), c + Vector2(8, -8)]), col)
			draw_line(c + Vector2(-5, -10), c + Vector2(-2, -17), col.lightened(0.3), 1.0)
			_poly(PackedVector2Array([c + Vector2(-8, -10), c + Vector2(8, -11), c + Vector2(8, -8), c + Vector2(-8, -7)]), band)
			var s := c + Vector2(1, -9)
			_px(s + Vector2(-1, 0), Color(1, 0.95, 0.6), 3, 1)
			_px(s + Vector2(0, -1), Color(1, 0.95, 0.6), 1, 3)
		"mira":
			# diademă aurie cu piatră de foc
			_poly(PackedVector2Array([c + Vector2(-8, -7), c + Vector2(8, -7), c + Vector2(7, -5), c + Vector2(-7, -5)]), col)
			_poly(PackedVector2Array([c + Vector2(-2, -7), c + Vector2(0, -11), c + Vector2(2, -7)]), col)
			_px(c + Vector2(-0.5, -8), band.lightened(0.2), 2, 2)
			# floare în păr
			draw_circle(c + Vector2(8, -6), 2.2, Color(1.0, 0.75, 0.3))
			_px(c + Vector2(7.5, -6.5), Color(1, 1, 0.8))


func _shield(hand: Vector2) -> void:
	_ellipse(hand + Vector2(-1, 0), 5.5, 6.5, _c["top"], 14)
	draw_arc(hand + Vector2(-1, 0), 5.5, 0.0, TAU, 14, _c["trim"], 1.0)
	_px(hand + Vector2(-2, -2), _c["trim"], 2, 4)


func _weapon(hand: Vector2, ang: float, p: Dictionary, h: Dictionary) -> void:
	var dir := Vector2.from_angle(ang)
	match h["weapon"]:
		"crossbow":
			var fwd := Vector2(1, 0) if p["arm_f"] < -0.6 else dir.orthogonal() * -1.0
			var stock := hand - fwd * 3.0
			var front := hand + fwd * 6.0
			draw_line(stock, front, Color(0.55, 0.36, 0.2), 2.0)
			var n := fwd.orthogonal()
			draw_line(front + n * 4.0, front - n * 4.0, _c["trim"], 1.0)
			draw_line(front + n * 4.0, hand + n * 0.5, Color(0.9, 0.9, 0.9, 0.7), 1.0)
			draw_line(front - n * 4.0, hand - n * 0.5, Color(0.9, 0.9, 0.9, 0.7), 1.0)
			if p["flash"]:
				draw_circle(front + fwd * 2.0, 2.5, Color(1.0, 0.95, 0.6))
		"sword":
			var tip := hand + dir.rotated(-1.2) * 13.0
			draw_line(hand, tip, Color(0.88, 0.9, 0.96), 2.0)
			draw_line(hand + dir.rotated(-1.2) * 2.0, tip, Color(1, 1, 1), 1.0)
			var g := dir.rotated(-1.2).orthogonal()
			draw_line(hand + g * 2.5, hand - g * 2.5, _c["trim"], 2.0)
			if p["flash"]:
				draw_arc(hand, 12.0, ang - 2.2, ang - 0.4, 10, Color(1, 1, 1, 0.8), 1.0)
		"staff", "orb":
			var up := Vector2(0.25, -1).normalized()
			var top := hand + up * 12.0
			draw_line(hand - up * 6.0, top, Color(0.5, 0.36, 0.26) if hero_id == "mira" else Color(0.55, 0.5, 0.75), 2.0)
			var gem: Color = _c["accent"]
			var pulse: float = 0.6 + 0.4 * sin(t * 5.0)
			draw_circle(top, 5.0 + p["glow"] * 3.0, Color(gem, 0.25 * pulse))
			if h["weapon"] == "staff":
				# spirală de cristal
				draw_arc(top, 3.0, 0.0, TAU * 0.8, 10, gem.lightened(0.3), 1.0)
				_px(top - Vector2(0.5, 0.5), Color.WHITE, 2, 2)
			else:
				draw_circle(top, 2.6, gem)
				_px(top - Vector2(1, 1), Color(1, 1, 0.8))
			if p["flash"]:
				draw_circle(top, 4.0, Color(1, 1, 1, 0.9))
