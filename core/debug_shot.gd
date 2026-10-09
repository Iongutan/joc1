class_name DebugShot
extends Node
## Unealtă de dezvoltare: dacă jocul e pornit cu `-- --shot=cale.png`,
## salvează o captură de ecran după câteva secunde și închide jocul.
## Opțional: `--shot-delay=4`, `--shot-autoplay` (eroul se mișcă singur în cerc).

var path: String = ""
var delay: float = 3.0
var autoplay: bool = false


static func maybe_capture(owner_node: Node) -> void:
	var shot := DebugShot.new()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--shot="):
			shot.path = arg.substr(7)
		elif arg.begins_with("--shot-delay="):
			shot.delay = arg.substr(13).to_float()
		elif arg == "--shot-autoplay":
			shot.autoplay = true
	if shot.path == "":
		shot.free()
		return
	shot.process_mode = Node.PROCESS_MODE_ALWAYS
	owner_node.add_child(shot)


static func is_autoplay() -> bool:
	return OS.get_cmdline_user_args().has("--shot-autoplay")


func _ready() -> void:
	await get_tree().create_timer(delay, true, false, true).timeout
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png(path)
	get_tree().quit()
