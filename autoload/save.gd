extends Node
## Progresul jucătorului, salvat pe telefon (user://save.cfg).

const PATH := "user://save.cfg"

var gold: int = 0
var tears: int = 0
var hero: String = "corvin"
var unlocked_heroes: Array = ["corvin", "ilva", "mira"]
var chapter: int = 0
var unlocked_chapter: int = 0
var intro_seen: bool = false
var sound_on: bool = true
var music_on: bool = true
var vibration_on: bool = true
var hero_levels: Dictionary = {"corvin": 1, "ilva": 1, "mira": 1}
var equipment: Dictionary = {}  # slot -> id obiect
var inventory: Array = ["w_crossbow_c", "h_hood_c", "a_leather_c", "g_leather_c", "b_leather_c", "m_garlic_r", "w_moonblade_r", "a_chain_r"]


func _ready() -> void:
	load_game()
	if equipment.is_empty():
		equipment = {"weapon": "w_crossbow_c", "helmet": "h_hood_c", "armor": "a_leather_c"}


func load_game() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return
	gold = cfg.get_value("p", "gold", gold)
	tears = cfg.get_value("p", "tears", tears)
	hero = HeroArt.valid(cfg.get_value("p", "hero", hero))
	chapter = cfg.get_value("p", "chapter", chapter)
	unlocked_chapter = cfg.get_value("p", "unlocked_chapter", unlocked_chapter)
	intro_seen = cfg.get_value("p", "intro_seen", intro_seen)
	sound_on = cfg.get_value("s", "sound", sound_on)
	music_on = cfg.get_value("s", "music", music_on)
	vibration_on = cfg.get_value("s", "vibration", vibration_on)
	hero_levels = cfg.get_value("p", "hero_levels", hero_levels)
	equipment = cfg.get_value("p", "equipment", equipment)
	inventory = cfg.get_value("p", "inventory", inventory)


func save_game() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("p", "gold", gold)
	cfg.set_value("p", "tears", tears)
	cfg.set_value("p", "hero", hero)
	cfg.set_value("p", "chapter", chapter)
	cfg.set_value("p", "unlocked_chapter", unlocked_chapter)
	cfg.set_value("p", "intro_seen", intro_seen)
	cfg.set_value("s", "sound", sound_on)
	cfg.set_value("s", "music", music_on)
	cfg.set_value("s", "vibration", vibration_on)
	cfg.set_value("p", "hero_levels", hero_levels)
	cfg.set_value("p", "equipment", equipment)
	cfg.set_value("p", "inventory", inventory)
	cfg.save(PATH)


## Bonusurile totale din echipamentul purtat.
func gear_stats() -> Dictionary:
	var s := {"atk": 0.0, "hearts": 0, "speed": 0.0, "magnet": 0.0}
	for slot in equipment:
		var item: Dictionary = Items.get_item(equipment[slot])
		if item.is_empty():
			continue
		for k in item["stats"]:
			s[k] += item["stats"][k]
	return s


## Un singur număr, ca în jocurile de gen, ca jucătorul să vadă cum crește.
func power() -> int:
	var s := gear_stats()
	var lvl: int = hero_levels.get(hero, 1)
	return 500 + lvl * 60 + int(s["atk"] * 1200.0) + s["hearts"] * 90 + int(s["speed"] * 600.0) + int(s["magnet"] * 300.0)
