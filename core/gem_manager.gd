class_name GemManager
extends Node2D
## Cristalele de experiență lăsate de inamici.

const MAX: int = 800
const PICKUP_RADIUS: float = 10.0
const PULL_SPEED: float = 260.0
const COLOR_SMALL := Color(0.45, 0.85, 1.0)
const COLOR_BIG := Color(1.0, 0.82, 0.3)

var n: int = 0
var pos := PackedVector2Array()
var value := PackedInt32Array()
var attracted := PackedByteArray()

var _mmi: MultiMeshInstance2D


func _ready() -> void:
	pos.resize(MAX)
	value.resize(MAX)
	attracted.resize(MAX)
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_2D
	mm.use_colors = true
	mm.mesh = SpriteFactory.quad_mesh(12.0)
	mm.instance_count = MAX
	mm.visible_instance_count = 0
	_mmi = MultiMeshInstance2D.new()
	_mmi.multimesh = mm
	_mmi.texture = SpriteFactory.gem_texture()
	_mmi.material = UiTheme.glow_material()
	add_child(_mmi)


func spawn(at: Vector2, v: int) -> void:
	if n >= MAX:
		# Plin: adăugăm valoarea la un cristal existent, nu pierdem XP.
		value[randi() % n] += v
		return
	pos[n] = at
	value[n] = v
	attracted[n] = 0
	n += 1


## Mișcă cristalele atrase și întoarce XP-ul adunat în acest cadru.
func update_gems(delta: float, player_pos: Vector2, magnet: float) -> int:
	var gained: int = 0
	var m2: float = magnet * magnet
	var pick2: float = PICKUP_RADIUS * PICKUP_RADIUS
	var i: int = 0
	while i < n:
		var p: Vector2 = pos[i]
		var to: Vector2 = player_pos - p
		var d2: float = to.length_squared()
		if d2 < pick2:
			gained += value[i]
			_remove(i)
			continue
		if attracted[i] == 1 or d2 < m2:
			attracted[i] = 1
			var d: float = sqrt(d2)
			pos[i] = p + to / d * minf(d, PULL_SPEED * delta)
		i += 1
	return gained


func _remove(i: int) -> void:
	var last: int = n - 1
	if i != last:
		pos[i] = pos[last]
		value[i] = value[last]
		attracted[i] = attracted[last]
	n -= 1


func render() -> void:
	var mm: MultiMesh = _mmi.multimesh
	mm.visible_instance_count = n
	for i in n:
		mm.set_instance_transform_2d(i, Transform2D(0.0, pos[i]))
		mm.set_instance_color(i, COLOR_BIG if value[i] >= 10 else COLOR_SMALL)
