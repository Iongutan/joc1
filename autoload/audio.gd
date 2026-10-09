extends Node
## Sunete, muzică și vibrații. Efectele sonore sunt sintetizate din cod (stil retro 8-bit)
## până vin fișierele audio finale. Vibrația merge doar pe telefon.

const RATE: int = 22050
const VOICES: int = 14

var _sfx: Dictionary = {}
var _players: Array[AudioStreamPlayer] = []
var _next: int = 0
var _last_play: Dictionary = {}
var _music: AudioStreamPlayer
var _music_cache: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in VOICES:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_players.append(p)
	_music = AudioStreamPlayer.new()
	_music.volume_db = -10.0
	add_child(_music)
	_build_sfx()


# --- Efecte sonore -------------------------------------------------------

func play(sfx_name: String, volume_db: float = 0.0, pitch_jitter: float = 0.06) -> void:
	if not Save.sound_on or not _sfx.has(sfx_name):
		return
	# nu suprapunem același sunet de prea multe ori pe secundă
	var now: int = Time.get_ticks_msec()
	if now - int(_last_play.get(sfx_name, -1000)) < 45:
		return
	_last_play[sfx_name] = now
	var p: AudioStreamPlayer = _players[_next]
	_next = (_next + 1) % VOICES
	p.stream = _sfx[sfx_name]
	p.volume_db = volume_db
	p.pitch_scale = 1.0 + randf_range(-pitch_jitter, pitch_jitter)
	p.play()


func vibrate(ms: int, strength: float = -1.0) -> void:
	if not Save.vibration_on:
		return
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(ms, strength)


func _build_sfx() -> void:
	_sfx["shoot"] = _tone(980.0, 520.0, 0.07, "square", 0.22, 0.0)
	_sfx["hit"] = _tone(260.0, 120.0, 0.05, "noise", 0.25, 0.8)
	_sfx["kill"] = _tone(420.0, 90.0, 0.14, "square", 0.22, 0.5)
	_sfx["gem"] = _tone(1300.0, 1900.0, 0.05, "sine", 0.22, 0.0)
	_sfx["hurt"] = _tone(320.0, 110.0, 0.22, "saw", 0.35, 0.4)
	_sfx["heart_break"] = _tone(900.0, 200.0, 0.18, "noise", 0.32, 0.9)
	_sfx["click"] = _tone(700.0, 600.0, 0.035, "square", 0.18, 0.0)
	_sfx["level_up"] = _arp([523.0, 659.0, 784.0, 1046.0], 0.08, "square", 0.22)
	_sfx["victory"] = _arp([523.0, 659.0, 784.0, 1046.0, 784.0, 1046.0, 1318.0], 0.1, "square", 0.24)
	_sfx["super"] = _tone(180.0, 1400.0, 0.55, "saw", 0.3, 0.25)
	_sfx["boss"] = _tone(110.0, 55.0, 0.9, "saw", 0.4, 0.5)
	_sfx["pact"] = _arp([196.0, 185.0, 147.0, 110.0], 0.22, "saw", 0.3)
	_sfx["whoosh"] = _tone(400.0, 1200.0, 0.18, "noise", 0.18, 1.0)
	_sfx["type"] = _tone(1500.0, 1400.0, 0.02, "square", 0.08, 0.0)
	_sfx["chest"] = _arp([784.0, 988.0, 1175.0], 0.06, "sine", 0.22)
	_sfx["pistol"] = _tone(220.0, 60.0, 0.16, "noise", 0.4, 0.85)
	_sfx["splash"] = _tone(900.0, 300.0, 0.14, "noise", 0.22, 0.95)
	_sfx["ice"] = _tone(2200.0, 1600.0, 0.08, "tri", 0.2, 0.15)
	_sfx["fire"] = _tone(300.0, 140.0, 0.2, "noise", 0.28, 0.7)
	_sfx["boom"] = _tone(140.0, 40.0, 0.35, "noise", 0.42, 0.8)


## Un sunet scurt cu frecvență care alunecă (de la f0 la f1) și se stinge.
func _tone(f0: float, f1: float, dur: float, wave: String, vol: float, noise_mix: float) -> AudioStreamWAV:
	var n: int = int(dur * RATE)
	var data := PackedByteArray()
	data.resize(n * 2)
	var phase: float = 0.0
	var noise_v: float = 0.0
	for i in n:
		var t: float = float(i) / float(n)
		var f: float = lerpf(f0, f1, t)
		phase = fmod(phase + f / RATE, 1.0)
		var s: float = _wave(wave, phase)
		if i % 3 == 0:
			noise_v = randf_range(-1.0, 1.0)
		s = lerpf(s, noise_v, noise_mix)
		var env: float = minf(t * 40.0, 1.0) * pow(1.0 - t, 1.6)
		data.encode_s16(i * 2, int(clampf(s * env * vol, -1.0, 1.0) * 32767.0))
	return _wav(data, false)


## Arpegiu: note scurte una după alta (nivel nou, victorie).
func _arp(freqs: Array, note_dur: float, wave: String, vol: float) -> AudioStreamWAV:
	var per: int = int(note_dur * RATE)
	var data := PackedByteArray()
	data.resize(per * freqs.size() * 2)
	var phase: float = 0.0
	for k in freqs.size():
		for i in per:
			var t: float = float(i) / float(per)
			phase = fmod(phase + float(freqs[k]) / RATE, 1.0)
			var env: float = minf(t * 30.0, 1.0) * (1.0 - t * 0.6)
			var idx: int = (k * per + i) * 2
			data.encode_s16(idx, int(clampf(_wave(wave, phase) * env * vol, -1.0, 1.0) * 32767.0))
	return _wav(data, false)


func _wave(wave: String, ph: float) -> float:
	match wave:
		"square":
			return 1.0 if ph < 0.5 else -1.0
		"saw":
			return ph * 2.0 - 1.0
		"sine":
			return sin(ph * TAU)
		"tri":
			return 1.0 - absf(ph * 4.0 - 2.0)
		_:
			return randf_range(-1.0, 1.0)


func _wav(data: PackedByteArray, loop: bool) -> AudioStreamWAV:
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = RATE
	w.stereo = false
	w.data = data
	if loop:
		w.loop_mode = AudioStreamWAV.LOOP_FORWARD
		w.loop_begin = 0
		w.loop_end = data.size() / 2
	return w


# --- Muzică -------------------------------------------------------------

func play_music(track: String) -> void:
	if not Save.music_on:
		_music.stop()
		return
	if not _music_cache.has(track):
		_music_cache[track] = _compose(track)
	if _music.stream == _music_cache[track] and _music.playing:
		return
	_music.stream = _music_cache[track]
	_music.play()


func stop_music() -> void:
	_music.stop()


## Muzică generată: bas, arpegiu în minor și tobe simple. Se repetă la nesfârșit.
func _compose(track: String) -> AudioStreamWAV:
	var bpm: float = 76.0 if track == "menu" else 132.0
	var rate: int = 16000
	var beat: float = 60.0 / bpm
	var bars: int = 4
	var total: int = int(beat * 4.0 * bars * rate)
	# progresie în La minor: Am - F - C - G (melancolic, de basm întunecat)
	var roots := [110.0, 87.31, 130.81, 98.0]
	var chords := [[0, 3, 7, 12], [0, 4, 7, 12], [0, 4, 7, 12], [0, 4, 7, 10]]
	var data := PackedByteArray()
	data.resize(total * 2)
	var ph_bass: float = 0.0
	var ph_arp: float = 0.0
	var step_len: float = beat / (2.0 if track == "menu" else 4.0)
	for i in total:
		var t: float = float(i) / rate
		var bar: int = int(t / (beat * 4.0)) % 4
		var step: int = int(t / step_len)
		var in_step: float = fmod(t, step_len) / step_len
		var root: float = roots[bar]
		var notes: Array = chords[bar]
		var semis: int = notes[step % 4] + (12 if (step / 4) % 2 == 1 else 0)
		var f_arp: float = root * 2.0 * pow(2.0, semis / 12.0)
		ph_arp = fmod(ph_arp + f_arp / rate, 1.0)
		ph_bass = fmod(ph_bass + root * 0.5 / rate, 1.0)
		var arp: float = (1.0 if ph_arp < 0.25 else -1.0) * 0.16 * pow(1.0 - in_step, 2.0)
		var bass: float = (1.0 - absf(ph_bass * 4.0 - 2.0)) * 0.3
		var s: float = arp + bass
		if track != "menu":
			var in_beat: float = fmod(t, beat) / beat
			s += sin(in_beat * 60.0 * (1.0 - in_beat)) * 0.35 * pow(1.0 - in_beat, 8.0)
			var off: float = fmod(t + beat * 0.5, beat) / beat
			s += randf_range(-1.0, 1.0) * 0.08 * pow(1.0 - off, 14.0)
		else:
			s += sin(t * TAU * root) * 0.08
		data.encode_s16(i * 2, int(clampf(s, -1.0, 1.0) * 32767.0 * 0.8))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = rate
	w.data = data
	w.loop_mode = AudioStreamWAV.LOOP_FORWARD
	w.loop_end = total
	return w
