class_name ProjectileManager
extends Node2D
## Proiectilele eroului, ca liste de date + un MultiMesh cu atlas (un tip pe coloană).
## Comportamente: normal (lovește și dispare / străpunge), exploziv (damage în zonă),
## urmăritor (se întoarce spre inamic), aruncat în arc (nu lovește în zbor; la aterizare
## lasă o zonă prin semnalul `landed`).

signal exploded(at: Vector2, radius: float, kind: int)
signal landed(at: Vector2, kind: int)

const MAX: int = 500
const HIT_PAD: float = 5.0

const SHADER := """
shader_type canvas_item;
render_mode unshaded;
uniform float frames = 6.0;
void vertex() {
	UV = vec2((UV.x + floor(INSTANCE_CUSTOM.r + 0.5)) / frames, UV.y);
}
"""

var n: int = 0
var pos := PackedVector2Array()
var vel := PackedVector2Array()
var dmg := PackedFloat32Array()
var pierce := PackedInt32Array()
var life := PackedFloat32Array()
var last_hit := PackedInt32Array()  # uid-ul ultimului inamic lovit
var kind := PackedInt32Array()
var blast := PackedFloat32Array()  # rază explozie (0 = fără)
var homing := PackedByteArray()
var lob := PackedByteArray()
var spin := PackedFloat32Array()

var _mmi: MultiMeshInstance2D
var _frame: int = 0


func _ready() -> void:
	for arr in ["pos", "vel", "dmg", "pierce", "life", "last_hit", "kind", "blast", "homing", "lob", "spin"]:
		var a = get(arr)
		a.resize(MAX)
		set(arr, a)
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_2D
	mm.use_custom_data = true
	mm.mesh = SpriteFactory.quad_mesh(float(ProjectileArt.CELL))
	mm.instance_count = MAX
	mm.visible_instance_count = 0
	_mmi = MultiMeshInstance2D.new()
	_mmi.multimesh = mm
	_mmi.texture = ProjectileArt.atlas()
	var sh := Shader.new()
	sh.code = SHADER
	var mat := ShaderMaterial.new()
	mat.shader = sh
	mat.set_shader_parameter("frames", float(ProjectileArt.COUNT))
	_mmi.material = mat
	add_child(_mmi)
	z_index = 5


func spawn(at: Vector2, velocity: Vector2, damage: float, p_pierce: int, p_life: float = 1.6,
		p_kind: int = ProjectileArt.Kind.BOLT, p_blast: float = 0.0, p_homing: bool = false, p_lob: bool = false) -> void:
	if n >= MAX:
		return
	pos[n] = at
	vel[n] = velocity
	dmg[n] = damage
	pierce[n] = p_pierce
	life[n] = p_life
	last_hit[n] = 0
	kind[n] = p_kind
	blast[n] = p_blast
	homing[n] = 1 if p_homing else 0
	lob[n] = 1 if p_lob else 0
	spin[n] = 0.0
	n += 1


func update_projectiles(delta: float, enemies: EnemyManager) -> void:
	_frame += 1
	var i: int = 0
	while i < n:
		if homing[i] == 1 and (_frame + i) % 6 == 0:
			var t: int = enemies.nearest(pos[i], 220.0)
			if t >= 0:
				var want: Vector2 = (enemies.pos[t] - pos[i]).normalized() * vel[i].length()
				vel[i] = vel[i].lerp(want, 0.45)
		pos[i] += vel[i] * delta
		life[i] -= delta
		if lob[i] == 1:
			spin[i] += delta * 14.0
			if life[i] <= 0.0:
				landed.emit(pos[i], kind[i])
				_remove(i)
				continue
			i += 1
			continue
		var done: bool = life[i] <= 0.0
		if not done and _hit(i, enemies):
			done = true
		if done:
			if blast[i] > 0.0:
				enemies.damage_in_radius(pos[i], blast[i], dmg[i] * 0.8)
				exploded.emit(pos[i], blast[i], kind[i])
			_remove(i)
		else:
			i += 1


## Verifică inamicii din celulele vecine. Întoarce true dacă proiectilul s-a consumat.
func _hit(i: int, enemies: EnemyManager) -> bool:
	var starts: PackedInt32Array = enemies.grid.starts
	var items: PackedInt32Array = enemies.grid.items
	var inv: float = enemies.grid.inv_cell
	var mask: int = SpatialGrid.MASK
	var p: Vector2 = pos[i]
	var cx: int = floori(p.x * inv)
	var cy: int = floori(p.y * inv)
	for oy in range(-1, 2):
		for ox in range(-1, 2):
			var b: int = (((cx + ox) * 73856093) ^ ((cy + oy) * 19349663)) & mask
			for k in range(starts[b], starts[b + 1]):
				var j: int = items[k]
				if j >= enemies.n or enemies.hp[j] <= 0.0 or enemies.uid[j] == last_hit[i]:
					continue
				var r: float = enemies.radius[j] + HIT_PAD
				if p.distance_squared_to(enemies.pos[j]) < r * r:
					enemies.damage(j, dmg[i])
					last_hit[i] = enemies.uid[j]
					pierce[i] -= 1
					if pierce[i] <= 0:
						return true
	return false


func _remove(i: int) -> void:
	var last: int = n - 1
	if i != last:
		pos[i] = pos[last]
		vel[i] = vel[last]
		dmg[i] = dmg[last]
		pierce[i] = pierce[last]
		life[i] = life[last]
		last_hit[i] = last_hit[last]
		kind[i] = kind[last]
		blast[i] = blast[last]
		homing[i] = homing[last]
		lob[i] = lob[last]
		spin[i] = spin[last]
	n -= 1


func render() -> void:
	var mm: MultiMesh = _mmi.multimesh
	mm.visible_instance_count = n
	for i in n:
		var rot: float = spin[i] if lob[i] == 1 else vel[i].angle()
		mm.set_instance_transform_2d(i, Transform2D(rot, pos[i]))
		mm.set_instance_custom_data(i, Color(kind[i], 0, 0, 0))
