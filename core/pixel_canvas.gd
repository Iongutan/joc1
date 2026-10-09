class_name PixelCanvas
extends SubViewportContainer
## Desenează conținutul la rezoluție mică și îl mărește fără netezire,
## ca fundalurile și ilustrațiile să arate ca pixel art adevărat.


static func wrap(content: Control, shrink: int = 3) -> PixelCanvas:
	var pc := PixelCanvas.new()
	pc.stretch = true
	pc.stretch_shrink = shrink
	pc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var vp := SubViewport.new()
	vp.transparent_bg = true
	vp.disable_3d = true
	vp.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	pc.add_child(vp)
	vp.add_child(content)
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return pc


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
