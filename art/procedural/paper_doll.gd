class_name PaperDoll
extends RefCounted
## Grafică procedurală din piese compatibile: corp + costum + siluetă + armă + ornamente +
## suprapuneri de strălucire. Toate piesele se agață de aceleași puncte ale corpului de bază,
## deci orice combinație se potrivește. Culorile vin din „sloturi” (s, c, d, m, a, g…),
## așa că aceleași piese dau monștri și personaje diferite doar schimbând paleta.
##
## Straturi, în ordinea desenării: back → body → costume → silhouette → weapon → ornament → glow.
## Stratul „glow” poate fi oprit (compose(..., false)) ca să verificăm că figura rămâne lizibilă
## și fără efecte.

const LAYERS := ["back", "body", "costume", "silhouette", "weapon", "ornament", "glow"]
const CANVAS := Vector2i(40, 44)
## Unde stă corpul de bază pe pânză și punctele lui de prindere (coordonate în pânză).
const BODY_AT := Vector2i(10, 10)
const ANCHORS := {
	"head": Vector2i(20, 12), "chest": Vector2i(20, 24), "hand_r": Vector2i(29, 27),
	"hand_l": Vector2i(11, 27), "feet": Vector2i(20, 39), "back": Vector2i(20, 20),
}

## Fiecare piesă: strat, punct de prindere, decalajul hărții față de acel punct, harta.
const PARTS := {
	"body_base": {"layer": "body", "anchor": "head", "offset": Vector2i(-10, -2), "map": [
		"....ssssssssssss....",
		"...ssssssssssssss...",
		"...sssseesssseesss..",
		"...sssseesssseesss..",
		"....ssssssssssssss..",
		".....ssssssssssss...",
		".......ssssssss.....",
		".....dddddddddddd...",
		"....dddddddddddddd..",
		"...sdddddddddddddds.",
		"...sdddddddddddddds.",
		"...sdddddddddddddds.",
		"....dddddddddddddd..",
		".....dddd....dddd...",
		".....dddd....dddd...",
		".....dddd....dddd...",
		".....bbbb....bbbb...",
		"....bbbbb....bbbbb..",
	]},
	"robe": {"layer": "costume", "anchor": "chest", "offset": Vector2i(-10, -5), "map": [
		"....cccccccccccc....",
		"...cccccccaaccccc...",
		"..ccccccccaacccccc..",
		"..ccccccccaacccccc..",
		"..ccccccccaacccccc..",
		"..ccccccccaacccccc..",
		".cccccccccaaccccccc.",
		".cccccccccaaccccccc.",
		".cccccccccaaccccccc.",
		"cccccccccccccccccccc",
		"cccccccccccccccccccc",
		"c.cc.cccccccccc.cc.c",
	]},
	"plate": {"layer": "costume", "anchor": "chest", "offset": Vector2i(-9, -5), "map": [
		"..mmmmmmmmmmmmmm..",
		".mmmmmmmmmmmmmmmm.",
		"mmmmmmmaammmmmmmmm",
		".mmmmmmaammmmmmmm.",
		".mmmmmmmmmmmmmmmm.",
		"..kkkkkkkkkkkkkk..",
		"..cccccccccccccc..",
		"..ccc.ccccc.cccc..",
	]},
	"hood": {"layer": "silhouette", "anchor": "head", "offset": Vector2i(-11, -6), "map": [
		".........cccc.........",
		"......cccccccccc......",
		"....cccccccccccccc....",
		"...ccccccccccccccccc..",
		"..cccc............cccc",
		"..ccc..............ccc",
		"..ccc..............ccc",
		"..ccc..............ccc",
		"..cccc............cccc",
		"...ccc............ccc.",
	]},
	"horns": {"layer": "silhouette", "anchor": "head", "offset": Vector2i(-12, -9), "map": [
		"hh....................hh",
		"hhh..................hhh",
		".hhh................hhh.",
		"..hhh..............hhh..",
		"...hhh............hhh...",
	]},
	"wide_hat": {"layer": "silhouette", "anchor": "head", "offset": Vector2i(-13, -9), "map": [
		"..........cccccc..........",
		".........cccccccc.........",
		".........caaaaaac.........",
		"..ccccccccccccccccccccccc.",
		"cccccccccccccccccccccccccc",
	]},
	"staff": {"layer": "weapon", "anchor": "hand_r", "offset": Vector2i(-2, -18), "map": [
		".ggg.",
		"ggwgg",
		".ggg.",
		"..w..",
		"..w..",
		"..w..",
		"..w..",
		"..w..",
		"..w..",
		"..w..",
		"..w..",
		"..w..",
		"..w..",
		"..w..",
		"..w..",
		"..w..",
		"..w..",
		"..w..",
		"..w..",
		"..w..",
		"..w..",
	]},
	"sword": {"layer": "weapon", "anchor": "hand_r", "offset": Vector2i(-1, -14), "map": [
		"..m..",
		".mmm.",
		".mmm.",
		".mmm.",
		".mmm.",
		".mmm.",
		".mmm.",
		".mmm.",
		".mmm.",
		".mmm.",
		"aaaaa",
		"..k..",
		"..k..",
	]},
	"belt": {"layer": "ornament", "anchor": "chest", "offset": Vector2i(-8, 3), "map": [
		"kkkkkkkkkkkkkkkk",
		"kkkkkkkaakkkkkkk",
	]},
	"amulet": {"layer": "ornament", "anchor": "chest", "offset": Vector2i(-2, -3), "map": [
		"k...k",
		".k.k.",
		"..a..",
		".aga.",
		"..a..",
	]},
	"eye_glow": {"layer": "glow", "anchor": "head", "offset": Vector2i(-6, 0), "map": [
		"gg......gg",
		"gg......gg",
	]},
	"aura": {"layer": "glow", "anchor": "feet", "offset": Vector2i(-12, -2), "map": [
		"....gggggggggggggggg....",
		"..gg................gg..",
		"....gggggggggggggggg....",
	]},
}

## Exemple de combinații (folosite și de validatorul de lizibilitate).
const EXAMPLES := {
	"cultist": {"parts": ["body_base", "robe", "hood", "belt", "staff", "eye_glow"],
		"colors": {"s": "e6dcc8", "e": "120810", "d": "3a1c28", "b": "2a1a14", "c": "b8323c", "a": "e8b84a",
			"k": "5a2a1a", "w": "7a5434", "g": "ff4a5a", "m": "c9d3e6", "h": "e6dcc0"}},
	"skeleton_knight": {"parts": ["body_base", "plate", "horns", "sword", "amulet", "eye_glow"],
		"colors": {"s": "ece8de", "e": "141418", "d": "2a2a36", "b": "3a3a46", "c": "4a2a6a", "a": "e8b84a",
			"k": "3a2a20", "w": "7a5434", "g": "8ff6ff", "m": "b8c0cc", "h": "d8d0c0"}},
	"swamp_witch": {"parts": ["body_base", "robe", "wide_hat", "amulet", "staff", "aura"],
		"colors": {"s": "a8c890", "e": "1a2014", "d": "2a3a24", "b": "3a2a1a", "c": "3e5a34", "a": "c8a050",
			"k": "4a3020", "w": "5a4a30", "g": "c8ff7a", "m": "9aa0a8", "h": "d0c0a0"}},
}


static func compose(spec: Dictionary, with_glow: bool = true) -> Image:
	var pal: Dictionary = {}
	for k in spec["colors"]:
		pal[k] = Pixel.c(spec["colors"][k])
	var img := Image.create_empty(CANVAS.x, CANVAS.y, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var glow_img := Image.create_empty(CANVAS.x, CANVAS.y, false, Image.FORMAT_RGBA8)
	glow_img.fill(Color(0, 0, 0, 0))
	for layer in LAYERS:
		for part_id in spec["parts"]:
			var part: Dictionary = PARTS.get(part_id, {})
			if part.is_empty() or part["layer"] != layer:
				continue
			var at: Vector2i = ANCHORS[part["anchor"]] + part["offset"]
			var piece := Pixel.from_map(part["map"], pal)
			if layer == "glow":
				Pixel.blit(glow_img, piece, at)
			else:
				Pixel.blit(img, piece, at)
	var out := Pixel.selective_outline(Pixel.shade(img))
	if with_glow:
		Pixel.blit(out, glow_img, Vector2i.ZERO)
	return out


## Pixelii care aparțin stratului de strălucire (pentru validator: nu sunt afectați de întuneric).
static func glow_mask(spec: Dictionary) -> Image:
	var only := spec.duplicate(true)
	only["parts"] = (spec["parts"] as Array).filter(func(p): return PARTS.get(p, {}).get("layer", "") == "glow")
	var pal: Dictionary = {}
	for k in spec["colors"]:
		pal[k] = Pixel.c(spec["colors"][k])
	var img := Image.create_empty(CANVAS.x, CANVAS.y, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for part_id in only["parts"]:
		var part: Dictionary = PARTS[part_id]
		Pixel.blit(img, Pixel.from_map(part["map"], pal), ANCHORS[part["anchor"]] + part["offset"])
	return img
