class_name Atmosphere
extends Node
## Atmosfera nopții: întuneric general, vignetă, licurici care plutesc în jurul eroului.
## Lumina propriu-zisă a eroului e în Player.

const DARKNESS := Color(0.36, 0.34, 0.5)

const VIGNETTE_SHADER := """
shader_type canvas_item;
uniform float strength = 0.75;
void fragment() {
	vec2 uv = UV - 0.5;
	uv.x *= 0.7;
	float d = length(uv);
	COLOR = vec4(0.02, 0.0, 0.05, smoothstep(0.28, 0.75, d) * strength);
}
"""

var _fireflies: CPUParticles2D
var _follow: Node2D


func setup(parent: Node, follow: Node2D, darkness: Color = DARKNESS) -> void:
	_follow = follow

	var dark := CanvasModulate.new()
	dark.color = darkness
	parent.add_child(dark)

	var layer := CanvasLayer.new()
	layer.layer = 4
	parent.add_child(layer)
	var vignette := ColorRect.new()
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader := Shader.new()
	shader.code = VIGNETTE_SHADER
	var mat := ShaderMaterial.new()
	mat.shader = shader
	vignette.material = mat
	layer.add_child(vignette)

	_fireflies = CPUParticles2D.new()
	_fireflies.amount = 46
	_fireflies.lifetime = 7.0
	_fireflies.preprocess = 7.0
	_fireflies.local_coords = false
	_fireflies.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	_fireflies.emission_rect_extents = Vector2(170, 280)
	_fireflies.direction = Vector2(0, -1)
	_fireflies.spread = 180.0
	_fireflies.gravity = Vector2(0, -4)
	_fireflies.initial_velocity_min = 4.0
	_fireflies.initial_velocity_max = 8.0
	_fireflies.scale_amount_min = 1.0
	_fireflies.scale_amount_max = 1.5
	var ramp := Gradient.new()
	ramp.set_color(0, Color(0.7, 1.0, 0.5, 0.0))
	ramp.set_color(1, Color(0.7, 1.0, 0.5, 0.0))
	ramp.add_point(0.25, Color(0.75, 1.0, 0.55, 0.9))
	ramp.add_point(0.75, Color(0.55, 0.9, 1.0, 0.8))
	_fireflies.color_ramp = ramp
	_fireflies.material = UiTheme.glow_material(true)
	_fireflies.z_index = 5
	parent.add_child(_fireflies)


func _process(_delta: float) -> void:
	if _follow != null and _fireflies != null:
		_fireflies.position = _follow.position
