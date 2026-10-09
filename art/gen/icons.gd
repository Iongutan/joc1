class_name Icons
extends RefCounted
## Iconițe pixel art: inimi, resurse, echipament, navigare. Toate cu contur închis.

const OUTLINE := Color(0.05, 0.03, 0.07)

const MAPS := {
	"heart": [
		".rr...rr.",
		"rwrr.rrrr",
		"rwrrrrrrr",
		"rrrrrrrrR",
		".rrrrrrR.",
		"..rrrRR..",
		"...rRR...",
		"....R....",
	],
	"heart_empty": [
		".dd...dd.",
		"dDDd.dDDd",
		"dDDDdDDDd",
		"dDDDDDDDd",
		".dDDDDDd.",
		"..dDDDd..",
		"...dDd...",
		"....d....",
	],
	"heart_left": [
		".rr.",
		"rwrr",
		"rwrr",
		"rrr.",
		".rr.",
		"..rr",
		"...r",
	],
	"heart_right": [
		".rr.",
		"rrrr",
		"rrrr",
		".rrR",
		"rrR.",
		"rR..",
		"R...",
	],
	"coin": [
		"..yyyy..",
		".yYYYYy.",
		"yYywyYYy",
		"yYwyYYYy",
		"yYYYYYYy",
		"yYYYYYYy",
		".yYYYYy.",
		"..yyyy..",
	],
	"tear": [
		"...v....",
		"...vv...",
		"..vwvv..",
		".vwvvvv.",
		".vvvvVv.",
		".vvvvVv.",
		"..vVVv..",
		"...vv...",
	],
	"skull": [
		".wwwww.",
		"wwwwwww",
		"wkkwkkw",
		"wkkwkkw",
		"wwwkwww",
		".wwwww.",
		".w.w.w.",
	],
	"weapon": [
		"..........mm",
		".........mMm",
		"........mMm.",
		".......mMm..",
		"......mMm...",
		"..l..mMm....",
		"...lmMm.....",
		"....lm......",
		"...lgl......",
		"..lg..l.....",
		".lg.........",
		"gg..........",
	],
	"helmet": [
		"...mmmmm...",
		"..mmmmmmm..",
		".mmwmmmmMm.",
		".mwmmmmmMm.",
		"mmmmmmmmmMm",
		"mmMMMMMMMMm",
		"mMkkkmkkkMm",
		"mM.kkmkk.Mm",
		"mM..mmm..Mm",
		".M.......M.",
	],
	"armor": [
		"mm.......mm",
		"mmm.....mmm",
		"mmmmgggmmmm",
		".mmwmmmmmM.",
		".mwmmmmmmM.",
		".mmmmmmmmM.",
		".mmmgggmmM.",
		".mmmmmmmmM.",
		"..mmmmmmM..",
		"..MMMMMMM..",
	],
	"gloves": [
		"..b.b.b....",
		".bb.bb.b...",
		".bbbbbbb...",
		".bwbbbbbb..",
		".bbbbbbbbb.",
		".bbbbbbbB..",
		"..bbbbbB...",
		"..ggggg....",
		"..BBBBB....",
	],
	"boots": [
		"..bbbb.....",
		"..bwbb.....",
		"..bbbb.....",
		"..bbbb.....",
		"..bbbB.....",
		"..bbbbbbb..",
		".bbbbbbbbb.",
		".BBBBBBBBB.",
		".kk.....kk.",
	],
	"amulet": [
		"..k.....k..",
		"...k...k...",
		"....k.k....",
		".....k.....",
		"....ggg....",
		"...gvvvg...",
		"...gvwvg...",
		"...gvvvg...",
		"....ggg....",
	],
	"bag": [
		"....bbb....",
		"...b...b...",
		"..ggggggg..",
		".bbbbbbbbb.",
		".bwbbbbbbB.",
		".bbbbgbbbB.",
		".bbbbgbbbB.",
		".bbbbbbbbB.",
		"..BBBBBBB..",
	],
	"swords": [
		"m.........m",
		".m.......m.",
		"..m.....m..",
		"...m...m...",
		"....m.m....",
		".....m.....",
		"....g.g....",
		"...g...g...",
		"..l.....l..",
		".l.......l.",
	],
	"house": [
		".....r.....",
		"....rrr....",
		"...rrrrr...",
		"..rrrrrrr..",
		".rrrrrrrrr.",
		"..bbbbbbb..",
		"..bybbbyb..",
		"..bbbbbbb..",
		"..bbbkbbb..",
		"..bbbkbbb..",
	],
	"altar": [
		".....v.....",
		"....vwv....",
		"....vvv....",
		".....v.....",
		"...........",
		".ggggggggg.",
		"..mmmmmmm..",
		"..mMmMmMm..",
		"..mmmmmmm..",
		".MMMMMMMMM.",
	],
	"gear": [
		"....m.m....",
		"..m.mmm.m..",
		"...mmmmm...",
		".mmmMMMmmm.",
		"..mmM.Mmm..",
		".mmmM.Mmmm.",
		"..mmMMMmm..",
		"...mmmmm...",
		"..m.mmm.m..",
		"....m.m....",
	],
	"lock": [
		"..mmmm..",
		".m....m.",
		".m....m.",
		"gggggggg",
		"gyyyyyyg",
		"gyyGGyyg",
		"gyyGGyyg",
		"gggggggg",
	],
}

const PALETTE := {
	"r": "d8303f", "R": "8e1a2a", "w": "ffffff", "d": "2a1a2a", "D": "4a2f3e",
	"y": "f2c14e", "Y": "c7902a", "v": "a77bff", "V": "6a45c8", "k": "1a1220",
	"m": "c9d3e6", "M": "7f8aa3", "g": "e8b84a", "l": "8a5a34", "b": "8a5a34", "B": "5e3b22",
}

static var _cache: Dictionary = {}


static func get_icon(icon_name: String, scale: int = 4) -> ImageTexture:
	var key := "%s:%d" % [icon_name, scale]
	if _cache.has(key):
		return _cache[key]
	var pal: Dictionary = {}
	for k in PALETTE:
		pal[k] = Pixel.c(PALETTE[k])
	var src := Image.create_empty(16, 16, false, Image.FORMAT_RGBA8)
	src.fill(Color(0, 0, 0, 0))
	var art := Pixel.from_map(MAPS.get(icon_name, MAPS["lock"]), pal)
	Pixel.blit(src, art, Vector2i(1, 1))
	src = Pixel.outline(src, OUTLINE)
	var used := src.get_used_rect()
	src = src.get_region(used.grow(1).intersection(Rect2i(0, 0, 16, 16)))
	var t := Pixel.tex(Pixel.upscale(src, scale))
	_cache[key] = t
	return t
