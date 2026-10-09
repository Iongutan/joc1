class_name HeroPortrait
extends Control
## Eroul în interfață (meniu, ecranul eroilor, poveste, super): ilustrația pixel art mare,
## animată din cod (respiră; la „super” / „attack” trece pe poza de atac și strălucește).
## crop = "face" arată doar capul.

var hero_id: String = "corvin"
var crop: String = "full"
var anim: String = "idle"
var _tex: TextureRect
var _t: float = 0.0
var _anim_t: float = 0.0


func setup(id: String, p_crop: String = "full") -> void:
	crop = p_crop
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tex = TextureRect.new()
	_tex.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED if crop == "face" else TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_tex.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_tex)
	set_hero(id)


func set_hero(id: String) -> void:
	hero_id = HeroArt.valid(id)
	_apply()


func play(a: String) -> void:
	anim = a
	_anim_t = 0.0
	_apply()


func _apply() -> void:
	if _tex == null:
		return
	if crop == "face":
		_tex.texture = HeroArt.face(hero_id)
	else:
		var pose := "attack" if anim in ["attack", "super", "victory"] else "idle"
		_tex.texture = HeroArt.texture(hero_id, pose, true)


func _process(delta: float) -> void:
	if crop == "face" or _tex == null or not is_visible_in_tree():
		return
	_t += delta
	_anim_t += delta
	var t: float = floorf(_t * 12.0) / 12.0
	_tex.pivot_offset = Vector2(size.x * 0.5, size.y)
	var sy: float = 1.0 + sin(t * 2.6) * 0.018
	_tex.scale = Vector2(1.0 - (sy - 1.0) * 0.5, sy)
	if anim in ["attack", "super"]:
		_tex.modulate = Color(1.25, 1.2, 1.3) if _anim_t < 0.2 else Color.WHITE
		if _anim_t > 1.2:
			play("idle")
	else:
		_tex.modulate = Color.WHITE
