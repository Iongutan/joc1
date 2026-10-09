class_name HeroArt
extends RefCounted
## Eroii jucabili: date (nume, titlu, culoare de accent) și sprite-urile pixel art
## din art/heroes/ (<id>_idle, <id>_attack; varianta _big pentru meniuri).

const ROSTER := ["corvin", "ilva", "mira"]

const HEROES := {
	"corvin": {"name": "Corvin", "title": "Vânătorul", "accent": Color(0.85, 0.2, 0.25)},
	"ilva": {"name": "Ilva", "title": "Vrăjitoarea de gheață", "accent": Color(0.5, 0.85, 1.0)},
	"mira": {"name": "Mira", "title": "Fiica Focului", "accent": Color(1.0, 0.55, 0.2)},
}

static var _cache: Dictionary = {}


static func valid(id: String) -> String:
	return id if HEROES.has(id) else "corvin"


## pose = "idle" sau "attack"; big = varianta mare pentru meniuri.
static func texture(id: String, pose: String = "idle", big: bool = false) -> Texture2D:
	var path := "res://art/heroes/%s_%s%s.png" % [valid(id), pose, "_big" if big else ""]
	if not _cache.has(path):
		_cache[path] = load(path)
	return _cache[path]


## Doar capul și umerii (partea de sus a ilustrației), pentru iconițe.
static func face(id: String) -> Texture2D:
	var key := "face:" + valid(id)
	if not _cache.has(key):
		var big := texture(id, "idle", true)
		var at := AtlasTexture.new()
		at.atlas = big
		var s: Vector2 = big.get_size()
		var w: float = minf(s.x, s.y * 0.42)
		at.region = Rect2((s.x - w) * 0.5, 0, w, w)
		_cache[key] = at
	return _cache[key]
