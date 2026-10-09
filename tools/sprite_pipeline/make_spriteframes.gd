extends SceneTree
## Salvează SpriteFrames-ul unui sheet ca resursă .tres (pentru editorul Godot).
## Rulează DUPĂ ce PNG-ul sheet-ului a fost importat (godot --headless --path . --import).
##
##   godot --headless --path . --script res://tools/sprite_pipeline/make_spriteframes.gd -- res://art/sheets/corvin_sheet.json


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		push_error("Lipsește calea către <nume>_sheet.json")
		quit(2)
		return
	var json_path: String = args[0]
	var sf := SheetLoader.frames(json_path)
	if sf == null:
		quit(1)
		return
	var out := json_path.get_basename().trim_suffix("_sheet") + "_frames.tres"
	var err := ResourceSaver.save(sf, out)
	print("SpriteFrames salvat: %s (eroare=%d, animații=%s)" % [out, err, ", ".join(sf.get_animation_names())])
	quit(0 if err == OK else 1)
