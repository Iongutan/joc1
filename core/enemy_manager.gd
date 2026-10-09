class_name EnemyManager
extends Node2D
## Toți inamicii trăiesc aici, ca liste de date (fără noduri și fără fizică).
## Se desenează dintr-o singură comandă printr-un MultiMesh cu atlas animat.

signal died(at: Vector2, xp: int, type: int)

const MAX: int = 700
const PLAYER_RADIUS: float = 9.0
const RELOCATE_DIST: float = 760.0
const FLASH_COLOR := Color(4.0, 4.0, 4.0)

enum Type { UMBRAR, SANGERIU, OGRE, BOSS }

## Câte inimi ia fiecare tip dintr-o lovitură (căpcăunul și boss-ul lovesc greu).
const HEART_DAMAGE := [1, 1, 3, 3]

const ATLAS_SHADER := """
shader_type canvas_item;
uniform float frames = 4.0;
uniform float rows = 4.0;
void vertex() {
	vec2 uv = UV;
	if (INSTANCE_CUSTOM.b > 0.5) { uv.x = 1.0 - uv.x; }
	UV = vec2((uv.x + floor(INSTANCE_CUSTOM.r + 0.5)) / frames, (uv.y + floor(INSTANCE_CUSTOM.g + 0.5)) / rows);
}
"""

var n: int = 0
var pos := PackedVector2Array()
var hp := PackedFloat32Array()
var max_hp := PackedFloat32Array()
var speed := PackedFloat32Array()
var radius := PackedFloat32Array()
var size_scale := PackedFloat32Array()
var flash := PackedFloat32Array()
var type := PackedInt32Array()
var xp_value := PackedInt32Array()
var uid := PackedInt32Array()  # id stabil; indicii se schimbă la ștergere
var slow := PackedFloat32Array()  # secunde rămase cu viteză redusă

var grid: SpatialGrid
var freeze_timer: float = 0.0
var boss_index: int = -1

var _mmi: MultiMeshInstance2D
var _frame: int = 0
var _anim_t: float = 0.0
var _next_uid: int = 1


func _ready() -> void:
	for arr in ["pos", "hp", "max_hp", "speed", "radius", "size_scale", "flash", "type", "xp_value", "uid", "slow"]:
		var a = get(arr)
		a.resize(MAX)
		set(arr, a)
	grid = SpatialGrid.new(40.0, MAX)

	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_2D
	mm.use_colors = true
	mm.use_custom_data = true
	mm.mesh = SpriteFactory.quad_mesh(float(MonsterArt.CELL))
	mm.instance_count = MAX
	mm.visible_instance_count = 0
	_mmi = MultiMeshInstance2D.new()
	_mmi.multimesh = mm
	_mmi.texture = MonsterArt.atlas()
	var shader := Shader.new()
	shader.code = ATLAS_SHADER
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("frames", float(MonsterArt.FRAMES))
	mat.set_shader_parameter("rows", float(MonsterArt.ROWS))
	_mmi.material = mat
	add_child(_mmi)


func spawn(at: Vector2, t_type: Type, t: float) -> int:
	if n >= MAX:
		return -1
	var i: int = n
	n += 1
	pos[i] = at
	flash[i] = 0.0
	slow[i] = 0.0
	type[i] = t_type
	uid[i] = _next_uid
	_next_uid += 1
	match t_type:
		Type.UMBRAR:
			hp[i] = 14.0 + t * 0.3
			speed[i] = 34.0
			radius[i] = 9.0
			size_scale[i] = 1.25
			xp_value[i] = 1
		Type.SANGERIU:
			hp[i] = 9.0 + t * 0.22
			speed[i] = 62.0
			radius[i] = 7.0
			size_scale[i] = 0.9
			xp_value[i] = 1
		Type.OGRE:
			hp[i] = 170.0 + t * 2.6
			speed[i] = 28.0
			radius[i] = 14.0
			size_scale[i] = 1.25
			xp_value[i] = 12
		Type.BOSS:
			hp[i] = 1600.0 + t * 6.0
			speed[i] = 30.0
			radius[i] = 18.0
			size_scale[i] = 1.7
			xp_value[i] = 60
			boss_index = i
	max_hp[i] = hp[i]
	return i


## Mișcă inamicii și reconstruiește grila.
## Întoarce câte inimi ar lua eroul din contact (cea mai mare lovitură din cadru).
func update_enemies(delta: float, player_pos: Vector2) -> int:
	_frame += 1
	_anim_t += delta
	var hit: int = 0
	var frozen: bool = freeze_timer > 0.0
	if frozen:
		freeze_timer -= delta
	for i in n:
		var p: Vector2 = pos[i]
		var to: Vector2 = player_pos - p
		var d: float = to.length()
		if d > RELOCATE_DIST and type[i] != Type.BOSS:
			# Prea departe: îl mutăm în fața eroului în loc să-l ștergem.
			pos[i] = player_pos + to / d * (RELOCATE_DIST * 0.55)
			continue
		if d > 0.5 and not frozen:
			var sp: float = speed[i]
			if slow[i] > 0.0:
				slow[i] -= delta
				sp *= 0.45
			pos[i] = p + to * (sp * delta / d)
		if d < radius[i] + PLAYER_RADIUS:
			hit = maxi(hit, HEART_DAMAGE[type[i]])
		if flash[i] > 0.0:
			flash[i] -= delta
	grid.rebuild(pos, n)
	_separate()
	return hit


## Inamicii se împing ușor între ei ca să nu stea unul peste altul.
## Jumătate din ei pe cadru, alternativ, ca să împărțim costul.
func _separate() -> void:
	var starts: PackedInt32Array = grid.starts
	var items: PackedInt32Array = grid.items
	var inv: float = grid.inv_cell
	var mask: int = SpatialGrid.MASK
	var i: int = _frame & 1
	while i < n:
		var p: Vector2 = pos[i]
		var ri: float = radius[i]
		var push := Vector2.ZERO
		var cx: int = floori(p.x * inv)
		var cy: int = floori(p.y * inv)
		for oy in range(-1, 2):
			for ox in range(-1, 2):
				var b: int = (((cx + ox) * 73856093) ^ ((cy + oy) * 19349663)) & mask
				for k in range(starts[b], starts[b + 1]):
					var j: int = items[k]
					if j == i:
						continue
					var dv: Vector2 = p - pos[j]
					var minr: float = ri + radius[j]
					var dd: float = dv.length_squared()
					if dd < minr * minr and dd > 0.01:
						var dist: float = sqrt(dd)
						push += dv * ((minr - dist) / dist)
		if push != Vector2.ZERO:
			pos[i] = p + push.limit_length(4.0) * 0.5
		i += 2


func damage(i: int, amount: float) -> void:
	hp[i] -= amount
	flash[i] = 0.07
	Events.enemy_hit.emit(pos[i], amount)


## Indicele celui mai apropiat inamic viu sau -1.
func nearest(from: Vector2, max_dist: float) -> int:
	var best: int = -1
	var best_d: float = max_dist * max_dist
	for i in n:
		if hp[i] <= 0.0:
			continue
		var d: float = from.distance_squared_to(pos[i])
		if d < best_d:
			best_d = d
			best = i
	return best


func damage_in_radius(center: Vector2, r: float, amount: float, push: float = 0.0) -> void:
	var r2: float = r * r
	for i in n:
		var d: Vector2 = pos[i] - center
		if d.length_squared() < r2:
			damage(i, amount)
			if push > 0.0 and type[i] != Type.BOSS:
				pos[i] += d.normalized() * push


func push_enemy(i: int, by: Vector2) -> void:
	if type[i] != Type.BOSS:
		pos[i] += by


func slow_in_radius(center: Vector2, r: float, seconds: float) -> void:
	var r2: float = r * r
	for i in n:
		if center.distance_squared_to(pos[i]) < r2:
			slow[i] = maxf(slow[i], seconds)


## Șterge inamicii morți (după ce au lovit toate armele în cadrul curent).
func compact() -> void:
	var i: int = n - 1
	while i >= 0:
		if hp[i] <= 0.0:
			died.emit(pos[i], xp_value[i], type[i])
			_remove(i)
		i -= 1


func _remove(i: int) -> void:
	var last: int = n - 1
	if i == boss_index:
		boss_index = -1
	if i != last:
		pos[i] = pos[last]
		hp[i] = hp[last]
		max_hp[i] = max_hp[last]
		speed[i] = speed[last]
		radius[i] = radius[last]
		size_scale[i] = size_scale[last]
		flash[i] = flash[last]
		type[i] = type[last]
		xp_value[i] = xp_value[last]
		uid[i] = uid[last]
		slow[i] = slow[last]
		if boss_index == last:
			boss_index = i
	n -= 1


func render(player_pos: Vector2) -> void:
	var mm: MultiMesh = _mmi.multimesh
	mm.visible_instance_count = n
	var frozen: bool = freeze_timer > 0.0
	var base_frame: int = int(_anim_t * 7.0)
	for i in n:
		var s: float = size_scale[i]
		var p: Vector2 = pos[i]
		mm.set_instance_transform_2d(i, Transform2D(0.0, Vector2(s, s), 0.0, p - Vector2(0, 9.0 * s)))
		var frame: int = 0 if frozen else (base_frame + uid[i]) % 4
		var flip: float = 1.0 if player_pos.x < p.x else 0.0
		mm.set_instance_custom_data(i, Color(frame, type[i], flip, 0.0))
		var col := Color.WHITE
		if flash[i] > 0.0:
			col = FLASH_COLOR
		elif frozen or slow[i] > 0.0:
			col = Color(0.6, 0.85, 1.4)
		mm.set_instance_color(i, col)
