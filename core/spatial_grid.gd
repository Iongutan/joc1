class_name SpatialGrid
extends RefCounted
## Grilă spațială cu hash, reconstruită la fiecare cadru prin counting sort.
## Nu alocă memorie în timpul jocului: toate listele sunt pregătite la început.
## Permite găsirea rapidă a inamicilor dintr-o zonă fără să-i verificăm pe toți.

const BUCKETS: int = 1024  # putere a lui 2
const MASK: int = BUCKETS - 1

var cell_size: float
var inv_cell: float
var starts: PackedInt32Array  # starts[b]..starts[b+1] = elementele din bucket-ul b
var items: PackedInt32Array
var _cursor: PackedInt32Array
var _cell_of: PackedInt32Array


func _init(p_cell_size: float, capacity: int) -> void:
	cell_size = p_cell_size
	inv_cell = 1.0 / p_cell_size
	starts.resize(BUCKETS + 1)
	_cursor.resize(BUCKETS)
	items.resize(capacity)
	_cell_of.resize(capacity)


## Aceeași formulă e copiată în buclele critice (EnemyManager, ProjectileManager).
static func bucket(cx: int, cy: int) -> int:
	return ((cx * 73856093) ^ (cy * 19349663)) & MASK


func rebuild(positions: PackedVector2Array, n: int) -> void:
	_cursor.fill(0)
	for i in n:
		var p: Vector2 = positions[i]
		var b: int = (((floori(p.x * inv_cell)) * 73856093) ^ ((floori(p.y * inv_cell)) * 19349663)) & MASK
		_cell_of[i] = b
		_cursor[b] += 1
	var acc: int = 0
	for b in BUCKETS:
		var c: int = _cursor[b]
		starts[b] = acc
		_cursor[b] = acc
		acc += c
	starts[BUCKETS] = acc
	for i in n:
		var b: int = _cell_of[i]
		items[_cursor[b]] = i
		_cursor[b] += 1


## Indicii candidaților dintr-un cerc. Apelantul verifică distanța exactă.
## Alocă o listă mică: se folosește doar de câteva ori pe cadru (arme).
func query(center: Vector2, radius: float) -> PackedInt32Array:
	var result := PackedInt32Array()
	var seen := PackedInt32Array()
	var x0: int = floori((center.x - radius) * inv_cell)
	var x1: int = floori((center.x + radius) * inv_cell)
	var y0: int = floori((center.y - radius) * inv_cell)
	var y1: int = floori((center.y + radius) * inv_cell)
	for cy in range(y0, y1 + 1):
		for cx in range(x0, x1 + 1):
			var b: int = bucket(cx, cy)
			if seen.has(b):
				continue
			seen.append(b)
			for k in range(starts[b], starts[b + 1]):
				result.append(items[k])
	return result
