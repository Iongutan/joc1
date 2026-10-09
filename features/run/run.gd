extends Node2D
## Scena de luptă. Ordinea pe cadru e fixă, ca toate sistemele să vadă date consistente:
## erou → inamici (+grilă) → arme → proiectile → ștergerea morților → cristale → spawn → desenare.

## Fiecare erou are 3 arme proprii; prima e arma de start, celelalte apar la nivel nou.
const HERO_WEAPONS := {
	"corvin": [
		{"script": preload("res://features/run/weapons/crossbow.gd"), "name": "Arbaleta de argint", "desc": "Săgeți spre cel mai apropiat inamic"},
		{"script": preload("res://features/run/weapons/flintlock.gd"), "name": "Pistolul cu cremene", "desc": "Foc în evantai, împinge inamicii"},
		{"script": preload("res://features/run/weapons/holy_water.gd"), "name": "Apa sfințită", "desc": "Sticle care lasă bălți arzătoare"},
	],
	"ilva": [
		{"script": preload("res://features/run/weapons/ice_shards.gd"), "name": "Ace de gheață", "desc": "Cioburi care urmăresc ținta"},
		{"script": preload("res://features/run/weapons/frost_ring.gd"), "name": "Cercul de ger", "desc": "Aură care rănește și încetinește"},
		{"script": preload("res://features/run/weapons/avalanche.gd"), "name": "Lavina", "desc": "Țepi de gheață ies din pământ"},
	],
	"mira": [
		{"script": preload("res://features/run/weapons/fireball.gd"), "name": "Mingea de foc", "desc": "Explodează în zonă la impact"},
		{"script": preload("res://features/run/weapons/flame_ring.gd"), "name": "Inelul de flăcări", "desc": "Sfere de foc care se rotesc în jurul tău"},
		{"script": preload("res://features/run/weapons/meteors.gd"), "name": "Meteorii", "desc": "Meteori cad pe grupurile de monștri"},
	],
}
const MAX_WEAPONS: int = 3
const SUPER_NAMES := {"corvin": "Ploaia de argint", "ilva": "Iarna veșnică", "mira": "Ploaia de meteori"}

var zones: ZoneManager
var player: Player
var enemies: EnemyManager
var projectiles: ProjectileManager
var gems: GemManager
var effects: Effects
var weapons: Array[Weapon] = []

var hud: Hud
var joystick: TouchStick
var panel: ChoicePanel
var cutin: SuperCutIn

var chapter: Dictionary
var time: float = 0.0
var kills: int = 0
var level: int = 1
var xp: int = 0
var xp_needed: int = 8
var villagers_lost: int = 0

var _spawn_acc: float = 0.0
var _elite_timer: float = 50.0
var _boss_spawned: bool = false
var _finished: bool = false
var _pending_levels: int = 0
var _choosing: bool = false
var _current_options: Array = []


func _ready() -> void:
	randomize()
	# opțiuni de test: --hero=ilva pornește cu alt erou (fără să schimbe salvarea)
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--hero="):
			Save.hero = HeroArt.valid(a.substr(7))
	chapter = Chapters.get_chapter(Save.chapter)

	var ground := Ground.new()
	ground.setup(chapter)
	add_child(ground)
	gems = GemManager.new()
	add_child(gems)
	enemies = EnemyManager.new()
	add_child(enemies)
	zones = ZoneManager.new()
	add_child(zones)
	projectiles = ProjectileManager.new()
	add_child(projectiles)
	player = Player.new()
	player.setup(Save.hero, Save.gear_stats())
	add_child(player)
	effects = Effects.new()
	add_child(effects)

	var atmosphere := Atmosphere.new()
	add_child(atmosphere)
	atmosphere.setup(self, player, Pixel.c(chapter["darkness"]))

	var ui := CanvasLayer.new()
	add_child(ui)
	joystick = TouchStick.new()
	ui.add_child(joystick)
	hud = Hud.new()
	hud.setup(Save.hero)
	add_child(hud)
	panel = ChoicePanel.new()
	add_child(panel)
	cutin = SuperCutIn.new()
	add_child(cutin)
	joystick.blocked = [hud.super_button, hud.pause_button]

	enemies.died.connect(_on_enemy_died)
	player.died.connect(_on_player_died)
	hud.super_pressed.connect(_use_super)
	hud.pause_pressed.connect(_open_pause)
	projectiles.exploded.connect(_on_exploded)
	zones.impact.connect(_on_zone_impact)
	_add_weapon(_pool()[0]["script"])
	if OS.get_cmdline_user_args().has("--all-weapons"):
		_add_weapon(_pool()[1]["script"])
		_add_weapon(_pool()[2]["script"])

	Events.xp_changed.emit(xp, xp_needed, level)
	Events.super_changed.emit(0.0)
	player.heal(0)  # interfața e gata acum: trimite inimile inițiale
	Audio.play_music("battle")
	_show_banner(chapter["name"], chapter["story"])
	if OS.get_cmdline_user_args().has("--boss-now"):
		time = float(chapter["boss_time"]) - 0.5
		player.add_charge(100.0)
	DebugShot.maybe_capture(self)


func _process(delta: float) -> void:
	if _finished:
		return
	time += delta
	player.move(_input_dir(), delta)

	var hit: int = enemies.update_enemies(delta, player.position)
	if hit > 0:
		player.hit(hit)

	for w in weapons:
		w.update_weapon(delta, player, enemies, projectiles)
	projectiles.update_projectiles(delta, enemies)
	zones.update_zones(delta, enemies)
	enemies.compact()

	var gained: int = gems.update_gems(delta, player.position, player.magnet)
	if gained > 0:
		Audio.play("gem", -14.0, 0.15)
		_add_xp(gained)

	_spawn(delta)

	enemies.render(player.position)
	projectiles.render()
	gems.render()
	hud.set_stats(time, kills)
	hud.set_debug(enemies.n)
	if enemies.boss_index >= 0:
		hud.set_boss(chapter["boss"], enemies.hp[enemies.boss_index], enemies.max_hp[enemies.boss_index])


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	match key.physical_keycode:
		KEY_T:
			for k in 200:
				enemies.spawn(_spawn_point(), EnemyManager.Type.UMBRAR, time)
		KEY_SPACE:
			_use_super()
		KEY_B:
			time = maxf(time, float(chapter["boss_time"]) - 1.0)
		KEY_ESCAPE:
			_open_pause()


func _input_dir() -> Vector2:
	var dir := Vector2(
		float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT))
			- float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)),
		float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN))
			- float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP)))
	if DebugShot.is_autoplay():
		dir = Vector2.from_angle(time * 0.8)
	if dir != Vector2.ZERO:
		return dir.normalized()
	return joystick.output


# --- Spawn ---------------------------------------------------------------

func _spawn_point() -> Vector2:
	var dist: float = get_viewport_rect().size.length() * 0.5 / Player.ZOOM + 30.0
	return player.position + Vector2.from_angle(randf() * TAU) * dist


func _spawn(delta: float) -> void:
	_spawn_acc += delta * (1.2 + time * 0.045)
	while _spawn_acc >= 1.0:
		_spawn_acc -= 1.0
		var t := EnemyManager.Type.UMBRAR
		if time > float(chapter["imp_after"]) and randf() < 0.4:
			t = EnemyManager.Type.SANGERIU
		enemies.spawn(_spawn_point(), t, time)
	_elite_timer -= delta
	if _elite_timer <= 0.0:
		_elite_timer = 50.0
		enemies.spawn(_spawn_point(), EnemyManager.Type.OGRE, time)
	if not _boss_spawned and time >= float(chapter["boss_time"]):
		_boss_spawned = true
		enemies.spawn(player.position + Vector2(0, -170), EnemyManager.Type.BOSS, time)
		Audio.play("boss")
		Audio.vibrate(400)
		Events.shake.emit(10.0)
		_show_banner(chapter["boss"], "a sosit!", 140.0)


func _on_enemy_died(at: Vector2, value: int, type: int) -> void:
	gems.spawn(at, value)
	kills += 1
	match type:
		EnemyManager.Type.OGRE:
			effects.burst(at, Color(0.5, 1.0, 0.4), 26)
			player.add_charge(20.0)
			Audio.play("kill", -4.0)
			Events.shake.emit(5.0)
			_hit_stop(0.07)
		EnemyManager.Type.BOSS:
			effects.burst(at, Color(1.0, 0.8, 0.3), 40)
			Audio.vibrate(500)
			Events.shake.emit(12.0)
			_hit_stop(0.25)
			hud.set_boss("", 0.0, 0.0)
			_victory()
		_:
			effects.burst(at, Color(0.75, 0.55, 1.0) if type == EnemyManager.Type.UMBRAR else Color(1.0, 0.4, 0.4), 10)
			player.add_charge(1.5)
			Audio.play("kill", -12.0, 0.2)


## Oprește timpul o clipă: loviturile mari se simt mai puternic.
func _hit_stop(seconds: float) -> void:
	Engine.time_scale = 0.05
	await get_tree().create_timer(seconds, true, false, true).timeout
	Engine.time_scale = 1.0


# --- Super-puterea -------------------------------------------------------

func _use_super() -> void:
	if player.super_charge < 100.0 or not player.alive or _finished:
		return
	player.super_charge = 0.0
	Events.super_changed.emit(0.0)
	player.play_super()
	cutin.play(Save.hero, SUPER_NAMES.get(Save.hero, "Super"))
	Audio.play("super")
	Audio.vibrate(180)
	Events.shake.emit(8.0)
	await _hit_stop(0.45)
	match Save.hero:
		"mira":
			# ploaie de meteori peste tot ecranul
			for k in 14:
				var at: Vector2 = player.position + Vector2(randf_range(-150, 150), randf_range(-240, 240))
				zones.add(at, 34.0, 0.01, 0.0, ZoneManager.Kind.METEOR, 0.3 + k * 0.07, 60.0 * player.damage_mult)
			effects.burst(player.position, Color(1.0, 0.6, 0.2), 40)
		"ilva":
			enemies.freeze_timer = 4.0
			enemies.damage_in_radius(player.position, 260.0, 35.0 * player.damage_mult)
			effects.burst(player.position, Color(0.7, 0.95, 1.0), 40)
		_:
			for k in 36:
				var dir := Vector2.from_angle(TAU * float(k) / 36.0)
				projectiles.spawn(player.position, dir * 300.0, 45.0 * player.damage_mult, 5, 1.4)
			effects.burst(player.position, Color(0.85, 0.9, 1.0), 40)
	Events.shake.emit(10.0)


# --- Nivel nou -----------------------------------------------------------

func _add_xp(amount: int) -> void:
	xp += amount
	while xp >= xp_needed:
		xp -= xp_needed
		level += 1
		xp_needed = 6 + level * 5
		_pending_levels += 1
	Events.xp_changed.emit(xp, xp_needed, level)
	if _pending_levels > 0 and not _choosing and player.alive:
		_show_level_up()


func _show_level_up() -> void:
	_choosing = true
	get_tree().paused = true
	joystick.release()
	Audio.play("level_up")
	Audio.vibrate(40)
	_current_options = _build_options()
	var buttons: Array = []
	for opt in _current_options:
		buttons.append({"text": "%s\n%s" % [opt["title"], opt["desc"]]})
	panel.open("NIVEL %d!" % level, "Alege o putere", buttons, _on_level_pick)


func _on_level_pick(idx: int) -> void:
	Audio.play("click")
	(_current_options[idx]["fn"] as Callable).call()
	_pending_levels -= 1
	if _pending_levels > 0:
		_show_level_up()
	else:
		_choosing = false
		get_tree().paused = false


func _build_options() -> Array:
	var opts: Array = []
	for w in weapons:
		if w.level < Weapon.MAX_LEVEL:
			opts.append({"title": "%s — nivel %d" % [w.weapon_name, w.level + 1],
				"desc": w.next_desc(), "fn": w.upgrade})
	if weapons.size() < MAX_WEAPONS:
		for entry in _pool():
			if _owned(entry["script"]) == null:
				opts.append({"title": "%s (armă nouă)" % entry["name"],
					"desc": entry["desc"], "fn": _add_weapon.bind(entry["script"])})
	opts.append({"title": "Cizme ușoare", "desc": "+12% viteză de mișcare", "fn": _passive_speed})
	opts.append({"title": "Inimă de stejar", "desc": "+1 inimă și vindecare", "fn": _passive_heart})
	opts.append({"title": "Talisman magnetic", "desc": "Aduni cristalele de mai departe", "fn": _passive_magnet})
	opts.append({"title": "Furia vânătorului", "desc": "+10% damage la toate armele", "fn": _passive_fury})
	opts.shuffle()
	return opts.slice(0, 3)


func _passive_speed() -> void:
	player.speed *= 1.12


func _passive_heart() -> void:
	player.add_max_hearts(1)
	player.heal(2)


func _passive_magnet() -> void:
	player.magnet *= 1.3


func _passive_fury() -> void:
	player.damage_mult *= 1.1


func _owned(script: Script) -> Weapon:
	for w in weapons:
		if w.get_script() == script:
			return w
	return null


func _pool() -> Array:
	return HERO_WEAPONS.get(Save.hero, HERO_WEAPONS["corvin"])


func _on_exploded(at: Vector2, radius: float, _kind: int) -> void:
	effects.ring(at, radius, Color(1.0, 0.55, 0.15))
	effects.burst(at, Color(1.0, 0.6, 0.2), 12)
	Audio.play("boom", -10.0)


func _on_zone_impact(at: Vector2, radius: float, kind: int) -> void:
	var col := Color(0.7, 0.95, 1.0) if kind == ZoneManager.Kind.ICE_SPIKES else Color(1.0, 0.5, 0.15)
	effects.ring(at, radius, col)
	effects.burst(at, col, 16)
	if kind == ZoneManager.Kind.METEOR:
		Audio.play("boom", -4.0)
		Events.shake.emit(4.0)
	else:
		Audio.play("ice", -4.0)


func _add_weapon(script: Script) -> void:
	var w: Weapon = script.new()
	w.zones = zones
	weapons.append(w)
	add_child(w)


# --- Pauză ---------------------------------------------------------------

func _open_pause() -> void:
	if _choosing or _finished or not player.alive:
		return
	get_tree().paused = true
	joystick.release()
	Audio.play("click")
	panel.open("PAUZĂ", chapter["name"], [
		{"text": "Continuă"},
		{"text": "Sunet: %s" % ("pornit" if Save.sound_on else "oprit")},
		{"text": "Vibrații: %s" % ("pornite" if Save.vibration_on else "oprite")},
		{"text": "Renunță (înapoi în meniu)"},
	], _on_pause_choice)


func _on_pause_choice(idx: int) -> void:
	match idx:
		0:
			get_tree().paused = false
		1:
			Save.sound_on = not Save.sound_on
			Save.music_on = Save.sound_on
			Save.save_game()
			if Save.music_on:
				Audio.play_music("battle")
			else:
				Audio.stop_music()
			_open_pause()
		2:
			Save.vibration_on = not Save.vibration_on
			Save.save_game()
			Audio.vibrate(80)
			_open_pause()
		3:
			_leave(int(kills / 10.0))


# --- Victorie, moarte și pactul -------------------------------------------

func _victory() -> void:
	_finished = true
	await get_tree().create_timer(1.2).timeout
	var gold: int = int(chapter["reward"]) + kills / 4
	Save.gold += gold
	Save.unlocked_chapter = maxi(Save.unlocked_chapter, mini(Save.chapter + 1, Chapters.LIST.size() - 1))
	Save.save_game()
	get_tree().paused = true
	Audio.play("victory")
	Audio.vibrate(120)
	panel.open("VICTORIE!", "%s a fost învins.\nUciși: %d   ·   Aur câștigat: %d\nSăteni pierduți: %d" % [chapter["boss"], kills, gold, villagers_lost],
		[{"text": "Înapoi în sat"}], func(_i: int) -> void: _leave(0))


func _on_player_died() -> void:
	get_tree().paused = true
	joystick.release()
	Audio.play("pact")
	Audio.vibrate(350)
	panel.open("AI MURIT",
		"Semnul Pactului arde pe mâna ta. Poți trăi din nou... dar cineva din sat va plăti.",
		[
			{"text": "Pactul: reînvie (moare un sătean)"},
			{"text": "Lumânare: reînviere curată (reclamă — în curând)", "disabled": true},
			{"text": "Renunță (păstrezi o parte din aur)"},
		],
		_on_death_choice)


func _on_death_choice(idx: int) -> void:
	match idx:
		0:
			villagers_lost += 1
			Events.villager_lost.emit(villagers_lost)
			player.revive()
			enemies.damage_in_radius(player.position, 150.0, 9999.0)
			Events.shake.emit(8.0)
			Audio.vibrate(200)
			get_tree().paused = false
		2:
			_leave(int(kills / 10.0))


func _leave(gold: int) -> void:
	if gold > 0:
		Save.gold += gold
		Save.save_game()
	get_tree().paused = false
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://features/menu/main_menu.tscn")


## Banner scurt în mijlocul ecranului (numele capitolului, sosirea boss-ului).
func _show_banner(title: String, sub: String, y_offset: float = 0.0) -> void:
	var layer := CanvasLayer.new()
	layer.layer = 6
	add_child(layer)
	var box := VBoxContainer.new()
	box.theme = UiTheme.get_theme()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	box.offset_left = -330
	box.offset_right = 330
	box.offset_top = -260 + y_offset
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(box)
	var t := Label.new()
	t.text = title
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	t.add_theme_font_size_override("font_size", 48)
	t.add_theme_color_override("font_color", UiTheme.GOLD_BRIGHT)
	box.add_child(t)
	var s := Label.new()
	s.text = sub
	s.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	s.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	s.add_theme_font_size_override("font_size", 24)
	box.add_child(s)
	box.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(box, "modulate:a", 1.0, 0.4)
	tw.tween_interval(2.2)
	tw.tween_property(box, "modulate:a", 0.0, 0.6)
	tw.tween_callback(layer.queue_free)
