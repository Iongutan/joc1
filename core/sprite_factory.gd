class_name SpriteFactory
extends RefCounted
## Grafică provizorie generată din cod, până vin sprite-urile pixel art reale.
## Texturile sunt deschise la culoare, ca MultiMesh să le poată colora per instanță.


static func quad_mesh(size: float) -> ArrayMesh:
	var h: float = size * 0.5
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = PackedVector2Array([Vector2(-h, -h), Vector2(h, -h), Vector2(h, h), Vector2(-h, h)])
	arrays[Mesh.ARRAY_TEX_UV] = PackedVector2Array([Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)])
	arrays[Mesh.ARRAY_INDEX] = PackedInt32Array([0, 1, 2, 0, 2, 3])
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


static func _new_image(size: int) -> Image:
	var img := Image.create_empty(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	return img


static func _disc(img: Image, cx: float, cy: float, r: float, col: Color, squash: float = 1.0) -> void:
	var w: int = img.get_width()
	for y in w:
		for x in w:
			var dx: float = x + 0.5 - cx
			var dy: float = (y + 0.5 - cy) / squash
			if dx * dx + dy * dy <= r * r:
				img.set_pixel(x, y, col)


## Creatură cu glugă și ochi strălucitori (32x32).
static func enemy_texture() -> ImageTexture:
	var img := _new_image(32)
	_disc(img, 16, 28, 10, Color(0, 0, 0, 0.35), 0.3)
	_disc(img, 16, 19, 11, Color(0.62, 0.62, 0.66))
	_disc(img, 16, 18, 10, Color(0.78, 0.78, 0.82))
	_disc(img, 16, 12, 8, Color(0.9, 0.9, 0.94))
	_disc(img, 16, 14, 5, Color(0.12, 0.12, 0.14))
	for p in [Vector2i(13, 14), Vector2i(14, 14), Vector2i(18, 14), Vector2i(19, 14)]:
		img.set_pixelv(p, Color(1, 1, 1))
	return ImageTexture.create_from_image(img)


## Cristal de experiență (12x12).
static func gem_texture() -> ImageTexture:
	var img := _new_image(12)
	for y in 12:
		for x in 12:
			var d: float = absf(x - 5.5) + absf(y - 5.5)
			if d <= 5.0:
				img.set_pixel(x, y, Color(0.75, 0.75, 0.8) if d > 3.0 else Color(1, 1, 1))
	return ImageTexture.create_from_image(img)


## Săgeată de arbaletă orientată spre dreapta (16x16).
static func bolt_texture() -> ImageTexture:
	var img := _new_image(16)
	for x in range(2, 13):
		img.set_pixel(x, 7, Color(0.85, 0.88, 0.95))
		img.set_pixel(x, 8, Color(0.6, 0.62, 0.7))
	for i in 3:
		img.set_pixel(13 + i, 7, Color(1, 1, 1))
		img.set_pixel(13 + i, 8, Color(0.9, 0.9, 0.95))
	img.set_pixel(12, 6, Color(1, 1, 1))
	img.set_pixel(12, 9, Color(1, 1, 1))
	for x in range(1, 4):
		img.set_pixel(x, 6, Color(0.8, 0.15, 0.15))
		img.set_pixel(x, 9, Color(0.8, 0.15, 0.15))
	return ImageTexture.create_from_image(img)
