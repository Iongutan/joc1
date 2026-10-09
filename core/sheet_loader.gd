class_name SheetLoader
extends RefCounted
## Transformă un sprite sheet (PNG + JSON produse de tools/sprite_pipeline/build_sheet.gd)
## într-o resursă SpriteFrames: fiecare cadru e o AtlasTexture din același atlas (o singură
## textură → un singur draw call), cu viteza și repetarea fiecărei animații din JSON.

static var _cache: Dictionary = {}


static func has_sheet(json_path: String) -> bool:
	return FileAccess.file_exists(json_path)


## Metadatele sheet-ului (cell, pivot, animations).
static func meta(json_path: String) -> Dictionary:
	var data = JSON.parse_string(FileAccess.get_file_as_string(json_path))
	return data if data is Dictionary else {}


static func frames(json_path: String) -> SpriteFrames:
	if _cache.has(json_path):
		return _cache[json_path]
	var m := meta(json_path)
	if m.is_empty():
		push_error("Sheet invalid: " + json_path)
		return null
	var tex: Texture2D = load(json_path.get_base_dir().path_join(m["image"]))
	var cell := Vector2(float(m["cell"][0]), float(m["cell"][1]))
	var sf := SpriteFrames.new()
	sf.remove_animation("default")
	for anim_name in m["animations"]:
		var a: Dictionary = m["animations"][anim_name]
		sf.add_animation(anim_name)
		sf.set_animation_speed(anim_name, float(a["fps"]))
		sf.set_animation_loop(anim_name, bool(a["loop"]))
		for i in int(a["frames"]):
			var at := AtlasTexture.new()
			at.atlas = tex
			at.region = Rect2(Vector2(i * cell.x, int(a["row"]) * cell.y), cell)
			sf.add_frame(anim_name, at)
	_cache[json_path] = sf
	return sf


## Decalajul care pune pivotul (picioarele) din celulă pe originea nodului.
static func pivot_offset(json_path: String) -> Vector2:
	var m := meta(json_path)
	if m.is_empty():
		return Vector2.ZERO
	return Vector2(float(m["cell"][0]) * 0.5 - float(m["pivot"][0]), float(m["cell"][1]) * 0.5 - float(m["pivot"][1]))
