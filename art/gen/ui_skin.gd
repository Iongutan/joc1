class_name UiSkin
extends RefCounted
## Ramele pixel art ale interfeței (9-slice): lemn cu aur, piatră, pergament, buton roșu.
## Desenate la rezoluție mică și mărite de 3 ori, ca marginile să rămână pixelate.

const SCALE: int = 3
const MARGIN: int = 4

const FRAME := [
	".oooooooooooooo.",
	"oAAAAAAAAAAAAAAo",
	"oAhhhhhhhhhhhhBo",
	"oAhiiiiiiiiiijBo",
	"oAhiiiiiiiiiijBo",
	"oAhiiiiiiiiiijBo",
	"oAhiiiiiiiiiijBo",
	"oAhjjjjjjjjjjjBo",
	"oAhiiiiiiiiiijBo",
	"oAhiiiiiiiiiijBo",
	"oAhiiiiiiiiiijBo",
	"oAhiiiiiiiiiijBo",
	"oAhjjjjjjjjjjjBo",
	"oAjjjjjjjjjjjjBo",
	"oBBBBBBBBBBBBBBo",
	".oooooooooooooo.",
]

## A = rama luminoasă, B = rama umbrită, h = lumină interioară, i = interior, j = umbră interioară
const STYLES := {
	"wood": {"o": "1a0f0a", "A": "f2c14e", "B": "9a6a22", "h": "c48a52", "i": "8a5a34", "j": "6a4226"},
	"wood_pressed": {"o": "1a0f0a", "A": "9a6a22", "B": "f2c14e", "h": "6a4226", "i": "7a4c2c", "j": "8a5a34"},
	"red": {"o": "1a0a0a", "A": "ffd76a", "B": "a8761e", "h": "e0505a", "i": "b8323c", "j": "8a1f2a"},
	"red_pressed": {"o": "1a0a0a", "A": "a8761e", "B": "ffd76a", "h": "8a1f2a", "i": "a02a34", "j": "b8323c"},
	"stone": {"o": "0a0810", "A": "c9a24a", "B": "6e5426", "h": "3e3550", "i": "2a2338", "j": "1e192a"},
	"parchment": {"o": "2a1a0e", "A": "8a5a34", "B": "4e2e1a", "h": "fff1cf", "i": "ecd6a8", "j": "d2b47e"},
	"dark": {"o": "000000", "A": "4a3e5e", "B": "241c30", "h": "1c1626", "i": "15101e", "j": "100c17"},
	"slot": {"o": "0a0810", "A": "8f86a8", "B": "3e3550", "h": "2e2640", "i": "221c30", "j": "1a1526"},
	"disabled": {"o": "0a0a0a", "A": "5a5560", "B": "34303a", "h": "34303a", "i": "2a2730", "j": "222026"},
}

static var _cache: Dictionary = {}


static func texture(style: String) -> ImageTexture:
	if _cache.has(style):
		return _cache[style]
	var pal: Dictionary = {}
	var colors: Dictionary = STYLES.get(style, STYLES["wood"])
	for k in colors:
		pal[k] = Pixel.c(colors[k])
	var rows: Array = FRAME.duplicate()
	if not style.begins_with("wood") and not style.begins_with("red"):
		# doar lemnul are scânduri; restul au interior uniform
		rows[7] = rows[8]
		rows[12] = rows[11]
	var t := Pixel.tex(Pixel.upscale(Pixel.from_map(rows, pal), SCALE))
	_cache[style] = t
	return t


static func box(style: String, pad_h: int = 18, pad_v: int = 12) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture = texture(style)
	var m: int = MARGIN * SCALE
	sb.texture_margin_left = m
	sb.texture_margin_right = m
	sb.texture_margin_top = m
	sb.texture_margin_bottom = m
	sb.content_margin_left = pad_h
	sb.content_margin_right = pad_h
	sb.content_margin_top = pad_v
	sb.content_margin_bottom = pad_v
	return sb
