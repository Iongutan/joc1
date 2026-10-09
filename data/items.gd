class_name Items
extends RefCounted
## Echipamentul: 6 locuri (armă, coif, armură, mănuși, cizme, amuletă), 5 rarități.

const SLOTS := ["weapon", "helmet", "armor", "gloves", "boots", "amulet"]
const SLOT_NAMES := {"weapon": "Armă", "helmet": "Coif", "armor": "Armură", "gloves": "Mănuși", "boots": "Cizme", "amulet": "Amuletă"}
const SLOT_ICONS := {"weapon": "weapon", "helmet": "helmet", "armor": "armor", "gloves": "gloves", "boots": "boots", "amulet": "amulet"}

const RARITY_NAMES := ["Comun", "Rar", "Epic", "Legendar", "Mitic"]
const RARITY_COLORS := [Color(0.85, 0.85, 0.85), Color(0.4, 0.85, 0.4), Color(0.35, 0.6, 1.0), Color(0.75, 0.4, 1.0), Color(1.0, 0.6, 0.2)]

const DB := {
	"w_crossbow_c": {"name": "Arbaletă de vânător", "slot": "weapon", "rarity": 0, "stats": {"atk": 0.05}},
	"w_moonblade_r": {"name": "Lama Lunii", "slot": "weapon", "rarity": 1, "stats": {"atk": 0.12}},
	"w_silver_e": {"name": "Arbaleta de argint", "slot": "weapon", "rarity": 2, "stats": {"atk": 0.22, "speed": 0.03}},
	"h_hood_c": {"name": "Gluga vânătorului", "slot": "helmet", "rarity": 0, "stats": {"hearts": 1}},
	"h_iron_r": {"name": "Coif de fier", "slot": "helmet", "rarity": 1, "stats": {"hearts": 2}},
	"a_leather_c": {"name": "Vestă de piele", "slot": "armor", "rarity": 0, "stats": {"hearts": 1}},
	"a_chain_r": {"name": "Zale de oțel", "slot": "armor", "rarity": 1, "stats": {"hearts": 2, "speed": -0.02}},
	"a_shadow_l": {"name": "Mantia Umbrei", "slot": "armor", "rarity": 3, "stats": {"hearts": 3, "atk": 0.1}},
	"g_leather_c": {"name": "Mănuși de piele", "slot": "gloves", "rarity": 0, "stats": {"atk": 0.04}},
	"b_leather_c": {"name": "Cizme de drum", "slot": "boots", "rarity": 0, "stats": {"speed": 0.06}},
	"m_garlic_r": {"name": "Talisman de usturoi", "slot": "amulet", "rarity": 1, "stats": {"magnet": 0.25, "hearts": 1}},
}


static func get_item(id: String) -> Dictionary:
	return DB.get(id, {})


static func describe(item: Dictionary) -> String:
	var parts: Array = []
	var s: Dictionary = item.get("stats", {})
	if s.has("atk"):
		parts.append("+%d%% atac" % int(s["atk"] * 100.0))
	if s.has("hearts"):
		parts.append("+%d inimi" % s["hearts"])
	if s.has("speed"):
		parts.append("%+d%% viteză" % int(s["speed"] * 100.0))
	if s.has("magnet"):
		parts.append("+%d%% magnet" % int(s["magnet"] * 100.0))
	return ", ".join(parts)
