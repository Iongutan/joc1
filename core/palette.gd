class_name Palette
extends RefCounted
## Palete de culori în format .hex (o culoare pe rând, ca pe Lospec).
## Folosite de pipeline-ul de sprite-uri ca toată grafica unui act să împartă aceleași culori.


static func load_hex(path: String) -> PackedColorArray:
	var out := PackedColorArray()
	var text := FileAccess.get_file_as_string(path)
	for line in text.split("\n"):
		var s := line.strip_edges().trim_prefix("#")
		if s.length() == 6 and s.is_valid_hex_number():
			out.append(Color.html(s))
	return out


static func save_hex(path: String, colors: PackedColorArray) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	for c in colors:
		f.store_line(c.to_html(false))
	f.close()


## Cele mai folosite N culori din imagini (culori apropiate sunt grupate în „găleți”).
static func extract(images: Array[Image], count: int) -> PackedColorArray:
	var buckets: Dictionary = {}
	for img in images:
		for y in img.get_height():
			for x in img.get_width():
				var c := img.get_pixel(x, y)
				if c.a < 0.5:
					continue
				var key: int = (int(c.r * 15.0) << 8) | (int(c.g * 15.0) << 4) | int(c.b * 15.0)
				if not buckets.has(key):
					buckets[key] = [0, Vector3.ZERO]
				buckets[key][0] += 1
				buckets[key][1] += Vector3(c.r, c.g, c.b)
	var keys := buckets.keys()
	keys.sort_custom(func(a, b): return buckets[a][0] > buckets[b][0])
	var out := PackedColorArray()
	for k in keys.slice(0, count):
		var avg: Vector3 = buckets[k][1] / float(buckets[k][0])
		out.append(Color(avg.x, avg.y, avg.z))
	return out


## Înlocuiește fiecare pixel opac cu cea mai apropiată culoare din paletă.
static func apply(img: Image, palette: PackedColorArray) -> void:
	var cache: Dictionary = {}
	for y in img.get_height():
		for x in img.get_width():
			var c := img.get_pixel(x, y)
			if c.a < 0.5:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
				continue
			var key: int = c.to_rgba32()
			if not cache.has(key):
				cache[key] = nearest(c, palette)
			img.set_pixel(x, y, cache[key])


static func nearest(c: Color, palette: PackedColorArray) -> Color:
	var best := c
	var best_d: float = INF
	for p in palette:
		# distanță ponderată după cum percepe ochiul culorile
		var d: float = 0.3 * pow(c.r - p.r, 2.0) + 0.59 * pow(c.g - p.g, 2.0) + 0.11 * pow(c.b - p.b, 2.0)
		if d < best_d:
			best_d = d
			best = p
	return Color(best.r, best.g, best.b, 1.0)
