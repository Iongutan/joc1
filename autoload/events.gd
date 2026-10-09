extends Node
## Bus global de evenimente. Părțile jocului comunică prin semnale,
## fără să se cunoască direct între ele.

signal hearts_changed(hearts: int, max_hearts: int, lost: int)
signal xp_changed(xp: int, xp_needed: int, level: int)
signal enemy_hit(at: Vector2, amount: float)
signal super_changed(charge: float)
signal villager_lost(total: int)
signal shake(strength: float)

var _perf_frames: int = 0


func _process(_delta: float) -> void:
	# Diagnostic de performanță: jocul pornit cu `-- --perf` scrie în consolă costul pe cadru.
	if not OS.get_cmdline_user_args().has("--perf"):
		set_process(false)
		return
	_perf_frames += 1
	if _perf_frames % 60 == 0:
		print("PERF process=%.2fms draws=%d objects=%d prims=%d fps=%d" % [
			Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0,
			Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
			Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME),
			Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),
			Engine.get_frames_per_second()])
