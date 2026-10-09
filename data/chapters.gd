class_name Chapters
extends RefCounted
## Capitolele Actului I. Fiecare are alt peisaj, alte culori și alt boss.

const LIST := [
	{
		"id": "campia", "act": "ACTUL I · DRĂVANIA", "name": "Capitolul 1: Câmpia",
		"story": "Satele de la marginea câmpiei au tăcut. Corvin pornește la drum.",
		"boss": "Preotul-Craniu", "boss_time": 210.0, "reward": 120,
		"ground": ["2a3322", "324029", "26301f"], "fog": "8fb08a",
		"glow": ["9fe36a", "fff3a0"], "props": ["grass", "grave", "stone", "flower"],
		"darkness": "5a6a80", "imp_after": 40.0,
	},
	{
		"id": "codrii", "act": "ACTUL I · DRĂVANIA", "name": "Capitolul 2: Codrii Negri",
		"story": "În pădure, copacii au ochi. Mama Ghiara îl așteaptă.",
		"boss": "Căpcăunul Pădurii", "boss_time": 240.0, "reward": 180,
		"ground": ["1f2a1c", "263322", "1a2418"], "fog": "6a9a7a",
		"glow": ["7fffd4", "c8ff7a"], "props": ["tree", "mushroom", "root", "grass"],
		"darkness": "3e5060", "imp_after": 20.0,
	},
	{
		"id": "pestera", "act": "ACTUL I · DRĂVANIA", "name": "Capitolul 3: Peștera de Cristal",
		"story": "Sub munte, cristalele cântă. Ceva vechi se trezește.",
		"boss": "Marele Preot al Cristalului", "boss_time": 240.0, "reward": 240,
		"ground": ["241e2c", "2c2536", "1e1926"], "fog": "8a6ac8",
		"glow": ["b08aff", "7fd6ff"], "props": ["crystal", "mushroom", "stone", "crack"],
		"darkness": "403a60", "imp_after": 10.0,
	},
	{
		"id": "mlastina", "act": "ACTUL I · DRĂVANIA", "name": "Capitolul 4: Mlaștina Bocetelor",
		"story": "Sătenii spun că mlaștina plânge noaptea. Au dreptate.",
		"boss": "Căpcăunul Mlaștinii", "boss_time": 270.0, "reward": 320,
		"ground": ["232a22", "2a3226", "1c221b"], "fog": "a0b090",
		"glow": ["c8ff7a", "ffb36a"], "props": ["reed", "puddle", "grave", "mushroom"],
		"darkness": "4a5a50", "imp_after": 0.0,
	},
]


static func get_chapter(i: int) -> Dictionary:
	return LIST[clampi(i, 0, LIST.size() - 1)]
