extends SceneTree
## Verifică asseturile față de assets_manifest.csv și raportează:
##   - fișiere din art/ (png, hex, wav, ogg, ttf, otf) care lipsesc din manifest;
##   - rânduri din manifest al căror fișier nu există;
##   - rânduri fără licență, fără sursă sau fără verificare;
##   - rânduri care nu permit uz comercial.
## Codul de ieșire e 1 dacă există probleme (util în CI), altfel 0.
##
##   godot --headless --path . --script res://tools/check_assets.gd

const MANIFEST := "res://assets_manifest.csv"
const SCAN_DIRS := ["res://art"]
const EXTS := ["png", "hex", "wav", "ogg", "mp3", "ttf", "otf"]
const REQUIRED := ["path", "source", "license", "commercial_use", "verified_on"]


func _init() -> void:
	var problems: Array[String] = []
	var rows: Dictionary = {}
	var f := FileAccess.open(MANIFEST, FileAccess.READ)
	if f == null:
		print("EROARE: lipsește " + MANIFEST)
		quit(1)
		return
	var header := f.get_csv_line()
	while not f.eof_reached():
		var line := f.get_csv_line()
		if line.size() < header.size() or line[0].strip_edges() == "":
			continue
		var row: Dictionary = {}
		for i in header.size():
			row[header[i]] = line[i].strip_edges()
		rows[row["path"]] = row

	var files: Array[String] = []
	for d in SCAN_DIRS:
		_scan(d, files)

	for p in files:
		if not rows.has(p):
			problems.append("FĂRĂ LICENȚĂ în manifest: " + p)
	for p in rows:
		var row: Dictionary = rows[p]
		if not FileAccess.file_exists(p):
			problems.append("FIȘIER LIPSĂ (e în manifest): " + p)
		for k in REQUIRED:
			if String(row.get(k, "")) == "":
				problems.append("CÂMP GOL '%s': %s" % [k, p])
		if String(row.get("commercial_use", "")).to_lower() != "yes":
			problems.append("FĂRĂ UZ COMERCIAL: %s (%s)" % [p, row.get("license", "?")])

	print("Asseturi scanate: %d · rânduri în manifest: %d" % [files.size(), rows.size()])
	if problems.is_empty():
		print("OK: toate asseturile au sursă și licență cu uz comercial.")
		quit(0)
	else:
		for pr in problems:
			print("  - " + pr)
		print("PROBLEME: %d" % problems.size())
		quit(1)


func _scan(dir: String, out: Array[String]) -> void:
	var d := DirAccess.open(dir)
	if d == null:
		return
	d.list_dir_begin()
	var name := d.get_next()
	while name != "":
		var full := dir.path_join(name)
		if d.current_is_dir():
			if not name.begins_with("."):
				_scan(full, out)
		elif name.get_extension().to_lower() in EXTS:
			out.append(full)
		name = d.get_next()
