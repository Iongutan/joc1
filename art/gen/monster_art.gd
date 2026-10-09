class_name MonsterArt
extends RefCounted
## Monștrii, desenați pixel cu pixel și puși într-un atlas (rând = tip, coloană = cadru).
## EnemyManager îi desenează pe toți dintr-o comandă, cu shader-ul care alege cadrul.

const CELL: int = 48
const FRAMES: int = 4
const ROWS: int = 4
const OUTLINE := Color(0.05, 0.03, 0.07)

const UMBRAR := [
	".......pppppppp.......",
	".....pppppppppppp.....",
	"....pppppppppppppp....",
	"...pppPPPPPPPPPPppp...",
	"...ppPddddddddddPpp...",
	"..pppPdEeddddEedPppp..",
	"..pppPddddddddddPppp..",
	"..pppPdddtdtdtddPppp..",
	"..pppPPddddddddPPppp..",
	".kpppppPPPPPPPPpppppk.",
	"kkppppppppppppppppppkk",
	".KPppppppppppppppppPK.",
	"..PppppppppppppppppP..",
	"..PppPppppppppppPppP..",
	"..PPpPPppppppppPPpPP..",
	"...P.PP.PPPPPP.PP.P...",
	"....d..d.d..d.d..d....",
]

const IMP_BODY := [
	".h....h.",
	".hrrrrh.",
	"rrrrrrrr",
	"rRerreRr",
	"rrrrrrrr",
	"rRtrrtRr",
	".rrrrrr.",
	".RrrrrR.",
	"..rRRr..",
	"..R..R..",
	".RR..RR.",
]

const IMP_WING_UP := [
	".......W",
	"......Ww",
	"....WWww",
	"..WWwwww",
	"WWwwwwww",
	".Wwwwwww",
	"..Ww.Www",
	"...W..Ww",
]

const IMP_WING_DOWN := [
	"........",
	"........",
	".......W",
	".....WWw",
	"...WWwww",
	".WWwwwww",
	"Wwwwwwww",
	".Ww.Ww.W",
	"..W..W..",
]

const OGRE_BODY := [
	"..........hh....hh..........",
	".........hGGGGGGGGh.........",
	"........GgggggggggG.........",
	".......GgLLgggggLLgG........",
	".......GgeeggggeeggG........",
	".......GggggGGGggggG........",
	"......GgtggggggggtgG........",
	"......GgtDDDDDDDDtgG........",
	".......GggggggggggG.........",
	"....GGGGgggggggggggGGGG.....",
	"...GgLLggggggggggggLLggG....",
	"..GgLLgggggggggggggggLLgG...",
	"..GggggGgggggggggggGggggG...",
	"..GgggGGgggggggggggGGgggG...",
	"..gggGGnnnnnnnnnnnnnGGggg...",
	"..LgG.GnNnnnmmnnnnNnG.GgL...",
	"......GnnnnmmmmnnnnnG.......",
	".......nnnnnmmnnnnnn........",
	".......NnnnnnnnnnnnN........",
]

const OGRE_LEG := [
	"GgggG.",
	"GgggG.",
	"GgLgG.",
	"GgggggG",
	"DDDDDDD",
]

const CLUB := [
	".ccc.",
	"cCccc",
	"cCcCc",
	"cccCc",
	".cCc.",
	"..cC.",
	"..cC.",
	"..cC.",
	"..cC.",
	"..cC.",
	"..CC.",
]

const CROWN := [
	"y.y.y.y",
	"yyyyyyy",
	"yYyYyYy",
]

const CULTIST := [
	"..........rrrr..........",
	"........rrrrrrrr........",
	".......rrrrrrrrrr.......",
	"......rrrRRRRRRrrr......",
	"......rrRddddddRrr......",
	".....rrRddddddddRrr.....",
	".....rrRdEeddEedRrr.....",
	".....rrRddddddddRrr.....",
	".....rrrRddddddRrrr.....",
	"....rrrrrRRRRRRrrrrr....",
	"...rrrrrrrrrrrrrrrrrr...",
	"..krrrrrrrryyrrrrrrrrk..",
	".kkrrrrrrrryyrrrrrrrrkk.",
	".kkRrrrrrrryyrrrrrrrRkk.",
	"..RRrrrrrrryyrrrrrrrRR..",
	"..RrrrrrrrryyrrrrrrrrR..",
	"..RrrrrrrrryyrrrrrrrrR..",
	"..RRrrrrrrryyrrrrrrrRR..",
	"...RrrrrrrryyrrrrrrrR...",
	"...RRrrrrrryyrrrrrrRR...",
	"...RRRrrrrryyrrrrrRRR...",
	"....RRRRRRRRRRRRRRRR....",
	"....R.RR.RRRRRR.RR.R....",
	".....k.k........k.k.....",
]

const CULT_STAFF := [
	"..g..",
	".gGg.",
	"gGGGg",
	".gGg.",
	"..w..",
	".www.",
	"..w..",
	"..w..",
	"..w..",
	"..w..",
	"..w..",
	"..w..",
	"..w..",
	"..w..",
	"..W..",
	"..W..",
	"..W..",
	"..W..",
	"..W..",
]

const CULT_BOOK := [
	".g..g.",
	"..gg..",
	"bbbbbb",
	"bGGGGb",
	"bGbbGb",
	"bbbbbb",
]

const PRIEST := [
	"...........tttttttt...........",
	".........tttttttttttt.........",
	"........tttttttttttttt........",
	".......tttTTTTTTTTTTttt.......",
	".......ttTwwwwwwwwwwTtt.......",
	".......ttTwdddwwdddwTtt.......",
	".......ttTwdcdwwdcdwTtt.......",
	".......ttTwwwwddwwwwTtt.......",
	".......ttTTwwdwwdwwTTtt.......",
	"......ttttTTwwwwwwTTtttt......",
	".....tttttTTwdwdwdTTttttt.....",
	"....ootttttttttttttttttoo.....",
	"...lootttttttooottttttttool...",
	"..llltttttttoooooottttttlll...",
	".kklltttttttttottttttttllkk...",
	".kkllttttnnnnnnnnnnttttllkk...",
	"..llltttnnnyyyyyynnntttlll....",
	"..llltttnnyccccccynntttlll....",
	"..lllltttnnyccccynnttttllll...",
	"...llltttnnnyccynnnttttlll....",
	"...llltttnnnnyynnnnttttlll....",
	"...lllltttnnnnnnnnttttllll....",
	"...lllltttnnyyyynntttllll.....",
	"....llltttnyccccyntttlll......",
	"....llllttnnyccynnttllll......",
	"....llllttnnnyynnnttllll......",
	"....lllllttttttttttlllll......",
	"....TTTTTTTTTTTTTTTTTTTT......",
	".....T.TT.TTTTTTTT.TT.T.......",
]

const BRAZIER := [
	"..f.F..",
	".fFfFf.",
	"fFFFFFf",
	".fFFFf.",
	"ooooooo",
	"oOyOyOo",
	".ooooo.",
	"...w...",
	"...w...",
	"...w...",
	"...w...",
	"...w...",
	"...w...",
	"...w...",
	"...w...",
	"...w...",
	"...w...",
	"...W...",
	"...W...",
	"...W...",
]

static var _atlas: ImageTexture


static func _pal(d: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for k in d:
		out[k] = Pixel.c(d[k])
	return out


static func atlas() -> ImageTexture:
	if _atlas != null:
		return _atlas
	var img := Image.create_empty(CELL * FRAMES, CELL * ROWS, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	var cult_pal := _pal({"r": "b8323c", "R": "7a1c28", "d": "120810", "E": "ffdf4a", "e": "ff8a2a",
		"k": "e6dcc8", "y": "e8b84a", "w": "7a5434", "W": "5a3a22", "g": "ff3a4a", "G": "ffb0b0",
		"b": "5a2a1a"})
	var priest_pal := _pal({"t": "4ccbd8", "T": "2a8a98", "w": "ece8de", "d": "141418", "c": "8ff6ff",
		"o": "e07a3a", "O": "b04a1a", "l": "a8d0f0", "k": "2a2030", "n": "2f9aa8", "y": "e0603a",
		"f": "6fe0ff", "F": "e8ffff", "W": "6a4a2e"})
	var imp_pal := _pal({"r": "c23a44", "R": "7d1f2a", "e": "fff27a", "t": "ffffff", "h": "e8d6b0",
		"w": "6a2448", "W": "2e0f1f"})
	var ogre_pal := _pal({"g": "4f9a3a", "G": "2f6a2a", "D": "1d3a1d", "L": "7cc25a", "t": "f0e6c8",
		"e": "ffdf4a", "n": "8a5a34", "N": "4e2e1a", "m": "b8bec8", "h": "e6dcc0", "c": "7a5232", "C": "4a3020"})

	for f in FRAMES:
		var bob: int = [0, 1, 0, -1][f]
		# rândul 0: Umbrar
		_cell(img, 0, f, _cultist(cult_pal, bob, f))
		# rândul 1: Sângeriu (liliac-vampir)
		_cell(img, 1, f, _imp(imp_pal, f))
		# rândul 2: Căpcăunul (elit)
		_cell(img, 2, f, _ogre(ogre_pal, f))
		# rândul 3: Preotul-Craniu (boss)
		_cell(img, 3, f, _priest(priest_pal, bob, f))
	_atlas = Pixel.tex(img)
	return _atlas


static func _cell(atlas_img: Image, row: int, frame: int, sprite: Image) -> void:
	var outlined := Pixel.selective_outline(Pixel.shade(sprite))
	var at := Vector2i(frame * CELL + (CELL - outlined.get_width()) / 2, row * CELL + CELL - outlined.get_height() - 2)
	Pixel.blit(atlas_img, outlined, at)


static func _umbrar(pal: Dictionary, bob: int, frame: int, crowned: bool) -> Image:
	var img := Image.create_empty(24, 24, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var rows: Array = UMBRAR.duplicate()
	if frame % 2 == 1:
		rows[16] = ".....d..d..dd..d..d..."
	Pixel.blit(img, Pixel.from_map(rows, pal), Vector2i(1, 4 + bob))
	if crowned:
		Pixel.blit(img, Pixel.from_map(CROWN, pal), Vector2i(8, 1 + bob))
	return img


static func _imp(pal: Dictionary, frame: int) -> Image:
	var img := Image.create_empty(26, 20, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var up: bool = frame % 2 == 0
	var wing := Pixel.from_map(IMP_WING_UP if up else IMP_WING_DOWN, pal)
	var dy: int = 0 if up else 2
	Pixel.blit(img, wing, Vector2i(1, 1))
	Pixel.blit(img, Pixel.flip_h(wing), Vector2i(17, 1))
	Pixel.blit(img, Pixel.from_map(IMP_BODY, pal), Vector2i(9, 4 + dy))
	return img


static func _ogre(pal: Dictionary, frame: int) -> Image:
	var img := Image.create_empty(34, 30, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var bob: int = [0, 1, 0, 1][frame]
	var club_dy: int = [0, -1, -2, -1][frame]
	Pixel.blit(img, Pixel.from_map(CLUB, pal), Vector2i(0, 4 + club_dy))
	var leg := Pixel.from_map(OGRE_LEG, pal)
	var la: int = 0 if frame == 1 else 1
	var lb: int = 0 if frame == 3 else 1
	Pixel.blit(img, leg, Vector2i(9, 20 + la + bob))
	Pixel.blit(img, leg, Vector2i(19, 20 + lb + bob))
	Pixel.blit(img, Pixel.from_map(OGRE_BODY, pal), Vector2i(3, 2 + bob))
	return img


static func _cultist(pal: Dictionary, bob: int, frame: int) -> Image:
	var img := Image.create_empty(34, 34, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var rows: Array = CULTIST.duplicate()
	if frame % 2 == 1:
		rows[23] = "......k.k......k.k......"
	Pixel.blit(img, Pixel.from_map(CULT_STAFF, pal), Vector2i(1, 6 + bob + (1 if frame == 2 else 0)))
	Pixel.blit(img, Pixel.from_map(rows, pal), Vector2i(4, 8 + bob))
	Pixel.blit(img, Pixel.from_map(CULT_BOOK, pal), Vector2i(26, 18 + bob))
	return img


static func _priest(pal: Dictionary, bob: int, frame: int) -> Image:
	var img := Image.create_empty(44, 46, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var flame: Array = BRAZIER.duplicate()
	if frame % 2 == 1:
		flame[0] = ".f..F.."
		flame[1] = "fFf.fFf"
	Pixel.blit(img, Pixel.from_map(flame, pal), Vector2i(1, 6 + bob))
	Pixel.blit(img, Pixel.from_map(PRIEST, pal), Vector2i(8, 12 + bob))
	return img