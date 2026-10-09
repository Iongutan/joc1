class_name ProjectileArt
extends RefCounted
## Proiectilele, desenate pixel cu pixel într-un atlas (o coloană pe tip), orientate spre dreapta.

const CELL: int = 16
enum Kind { BOLT, PELLET, FLASK, SHARD, FIREBALL, STAKE }
const COUNT: int = 6

const MAPS := {
	Kind.BOLT: [
		"................",
		"................",
		"................",
		"................",
		"................",
		"................",
		".rr.........ww..",
		"rrmmmmmmmmmmmww.",
		".rr.........ww..",
		"................",
	],
	Kind.PELLET: [
		"................",
		"................",
		"................",
		"................",
		"................",
		"......oyy.......",
		".....oyyww......",
		".....oyyyy......",
		"......oyy.......",
	],
	Kind.FLASK: [
		"................",
		"................",
		"................",
		"......kk........",
		"......mm........",
		".....bwbb.......",
		"....bwbbbb......",
		"....bbbbbb......",
		"....bbbbBb......",
		".....bbBB.......",
	],
	Kind.SHARD: [
		"................",
		"................",
		"................",
		"................",
		"................",
		"........cc......",
		"...ccccCwwc.....",
		"ccCCCCCCwwwwc...",
		"...ccccCwwc.....",
		"........cc......",
	],
	Kind.FIREBALL: [
		"................",
		"................",
		"................",
		"................",
		"......rro.......",
		"...rrooyyo......",
		".rrroyyyyyo.....",
		"rrooyywwyyo.....",
		".rrroyyyyyo.....",
		"...rrooyyo......",
		"......rro.......",
	],
	Kind.STAKE: [
		"................",
		"................",
		"................",
		"................",
		"................",
		"................",
		"..lllllllllgg...",
		".LLLLLLLLLLggww.",
		"..lllllllllgg...",
	],
}

const PALETTE := {
	"r": "c8283a", "m": "d9dde8", "w": "ffffff", "o": "ff7a1a", "y": "ffd84a",
	"k": "6a4a2e", "b": "5ab8ff", "B": "2f7fd0", "c": "8fe8ff", "C": "3fb6e8",
	"l": "8a5a34", "L": "5e3b22", "g": "e8b84a",
}

static var _atlas: ImageTexture


static func atlas() -> ImageTexture:
	if _atlas != null:
		return _atlas
	var pal: Dictionary = {}
	for k in PALETTE:
		pal[k] = Pixel.c(PALETTE[k])
	var img := Image.create_empty(CELL * COUNT, CELL, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	for kind in MAPS:
		var art := Pixel.from_map(MAPS[kind], pal)
		var cell := Image.create_empty(CELL, CELL, false, Image.FORMAT_RGBA8)
		cell.fill(Color(0, 0, 0, 0))
		Pixel.blit(cell, art, Vector2i(0, (CELL - art.get_height()) / 2 + 1))
		cell = Pixel.selective_outline(cell, 0.55)
		Pixel.blit(img, cell, Vector2i(int(kind) * CELL, 0))
	_atlas = Pixel.tex(img)
	return _atlas
