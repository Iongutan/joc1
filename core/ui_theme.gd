class_name UiTheme
extends RefCounted
## Stilul vizual unic al interfeței: piatră întunecată, rame aurii, strălucire violet.
## Toate ecranele folosesc aceeași temă, ca jocul să arate unitar.

const INK := Color(0.96, 0.9, 0.78)
const INK_DIM := Color(0.7, 0.64, 0.6)
const GOLD := Color(0.86, 0.66, 0.32)
const GOLD_BRIGHT := Color(1.0, 0.84, 0.45)
const VIOLET := Color(0.55, 0.32, 0.95)
const STONE := Color(0.12, 0.09, 0.16)
const STONE_LIGHT := Color(0.19, 0.14, 0.25)
const BLOOD := Color(0.75, 0.12, 0.16)

static var _theme: Theme


static func get_theme() -> Theme:
	if _theme != null:
		return _theme
	var t := Theme.new()
	t.default_font = PixelFont.get_font()
	t.default_font_size = 36

	t.set_stylebox("normal", "Button", UiSkin.box("wood"))
	t.set_stylebox("hover", "Button", UiSkin.box("wood"))
	t.set_stylebox("pressed", "Button", UiSkin.box("wood_pressed"))
	t.set_stylebox("focus", "Button", StyleBoxEmpty.new())
	t.set_stylebox("disabled", "Button", UiSkin.box("disabled"))
	t.set_color("font_color", "Button", INK)
	t.set_color("font_hover_color", "Button", GOLD_BRIGHT)
	t.set_color("font_pressed_color", "Button", GOLD_BRIGHT)
	t.set_color("font_focus_color", "Button", INK)
	t.set_color("font_disabled_color", "Button", Color(0.5, 0.47, 0.5))
	t.set_constant("outline_size", "Button", 0)

	t.set_color("font_color", "Label", INK)
	t.set_constant("outline_size", "Label", 0)
	t.set_color("font_shadow_color", "Label", Color(0, 0, 0, 0.6))
	t.set_constant("shadow_offset_x", "Label", 0)
	t.set_constant("shadow_offset_y", "Label", 3)

	t.set_stylebox("panel", "PanelContainer", UiSkin.box("stone", 20, 16))
	t.set_stylebox("panel", "Panel", UiSkin.box("stone", 20, 16))

	var bar_bg := StyleBoxFlat.new()
	bar_bg.bg_color = Color(0, 0, 0, 0.6)
	bar_bg.border_color = Color(0.25, 0.2, 0.3)
	bar_bg.set_border_width_all(2)
	bar_bg.set_corner_radius_all(3)
	t.set_stylebox("background", "ProgressBar", bar_bg)
	_theme = t
	return t


static func _box(bg: Color, border: Color, border_w: int, glow: Color, glow_a: float) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(border_w)
	sb.set_corner_radius_all(6)
	sb.content_margin_left = 18
	sb.content_margin_right = 18
	sb.content_margin_top = 12
	sb.content_margin_bottom = 12
	if glow_a > 0.0:
		sb.shadow_color = Color(glow.r, glow.g, glow.b, glow_a)
		sb.shadow_size = 8
	return sb


## Bară de progres colorată (viață, experiență).
static func bar_fill(col: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = col
	sb.set_corner_radius_all(3)
	return sb


## Material pentru obiecte care strălucesc în întuneric (nu sunt afectate de lumină).
static func glow_material(additive: bool = false) -> CanvasItemMaterial:
	var m := CanvasItemMaterial.new()
	m.light_mode = CanvasItemMaterial.LIGHT_MODE_UNSHADED
	if additive:
		m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return m


## Textură radială moale, pentru lumini și aure.
static func radial_texture(size: int, inner: Color, outer: Color) -> GradientTexture2D:
	var g := Gradient.new()
	g.set_color(0, inner)
	g.set_color(1, outer)
	var tex := GradientTexture2D.new()
	tex.gradient = g
	tex.width = size
	tex.height = size
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	return tex
