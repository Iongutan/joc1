# Pipeline de grafică — Pactul Umbrei

Ramura: `feature/sprite-pipeline`. Tot ce e descris aici a fost rulat pe această ramură (rezultatele sunt în `art/sheets/`, `art/palettes/`, `docs/audit/`).

## 1. Fluxul complet

```
ilustrație (AI Figma / artist / pachet licențiat)
   │  tools/pixelize.gd          scoate fundalul, micșorează la grila jocului, contur
   ▼
art/heroes/<id>_idle.png, <id>_attack.png        (poze de bază, ~82 px înălțime)
   │  tools/sprite_pipeline/build_sheet.gd + art/sheets/<id>.spec.json
   │     • taie marginile goale
   │     • extrage / aplică paleta (art/palettes/<id>.hex)
   │     • cadre desenate (files[]) SAU derivate din poză (fx)
   │     • aliniază fiecare cadru pe pivot (picioare), păstrează margini transparente
   ▼
art/sheets/<id>_sheet.png  +  <id>_sheet.json     (atlas: un rând pe animație)
   │  core/sheet_loader.gd  (la rulare)   sau   tools/sprite_pipeline/make_spriteframes.gd
   ▼
SpriteFrames (AtlasTexture din același atlas)  →  AnimatedSprite2D în HeroView
   │  tools/validate_readability.gd   lizibilitate la scara jocului, cu/fără glow
   │  tools/check_assets.gd           fiecare fișier are sursă și licență în assets_manifest.csv
```

## 2. Reguli

| Regulă | Unde e impusă |
| --- | --- |
| **Import nearest-neighbor, fără compresie cu pierderi, fără mipmaps** | `project.godot` → `[importer_defaults] texture` (`compress/mode=0`, `mipmaps/generate=false`, `process/fix_alpha_border=true`) + `textures/canvas_textures/default_texture_filter=0` (Nearest) |
| **Atlas** | Un sheet per personaj; toate cadrele sunt `AtlasTexture` din aceeași textură |
| **Pivot** | `pivot` în spec = punctul picioarelor în celulă (ex. `[48, 93]` într-o celulă 96×96); `SheetLoader.pivot_offset()` îl pune pe originea nodului |
| **Margini transparente** | `margin` (implicit 2 px) — niciun pixel opac pe marginea celulei, deci fără „sângerare” între cadre |
| **Palete** | `.hex`, o culoare pe rând (format Lospec); `extract_palette: N` extrage N culori; ținta ghidului vizual: ≤ 48 culori / personaj |
| **Export** | PNG RGBA 8 biți + JSON cu `cell`, `pivot`, `animations{row, frames, fps, loop}` |
| **Licență** | Fiecare fișier din `art/` are un rând în `assets_manifest.csv` (verificat de `check_assets.gd`) |

## 3. Specificația unui sheet (exemplu: Corvin)

`art/sheets/corvin.spec.json` — 6 animații, derivate din cele 2 poze desenate:

| Animație | Sursă | Cadre | FPS | Efect (`fx`) |
| --- | --- | --- | --- | --- |
| idle | corvin_idle.png | 4 | 6 | breathe — corpul se strânge cu 1–2 rânduri |
| run | corvin_idle.png | 6 | 12 | hop — salt + turtire la aterizare |
| attack | corvin_attack.png | 3 | 14 | recoil — recul + bliț |
| super | corvin_attack.png | 4 | 8 | float — plutește |
| hurt | corvin_idle.png | 2 | 12 | flash — alb, apoi roșu |
| victory | corvin_attack.png | 4 | 8 | float |

Când există cadre desenate (de artist sau generate), se folosește `"files": ["run_0.png", "run_1.png", …]` în loc de `source` + `fx`; restul pașilor rămân identici.

## 4. Grafica procedurală din piese (`art/procedural/paper_doll.gd`)

Piese compatibile, agățate de aceleași puncte ale corpului de bază (`head`, `chest`, `hand_r`, `hand_l`, `feet`, `back`):

| Strat | Piese |
| --- | --- |
| body | `body_base` |
| costume | `robe`, `plate` |
| silhouette | `hood`, `horns`, `wide_hat` |
| weapon | `staff`, `sword` |
| ornament | `belt`, `amulet` |
| glow (suprapunere, se poate opri) | `eye_glow`, `aura` |

Culorile vin din sloturi (`s` piele, `c` costum, `d` haine de bază, `m` metal, `a` accent, `g` strălucire…), deci aceleași piese dau creaturi diferite schimbând doar paleta. Exemple incluse: `cultist`, `skeleton_knight`, `swamp_witch`.

## 5. Validarea lizibilității

`tools/validate_readability.gd` simulează lupta: fundalul fiecărui capitol, întunericul (`CanvasModulate`) și lumina eroului; glow-ul nu e afectat de întuneric. Criteriile se aplică **fără glow** (figura trebuie să se citească și fără efecte):

| Criteriu | Prag |
| --- | --- |
| Înălțime | ≥ 24 px |
| Contrast mediu față de fundal | ≥ 0.10 luminanță |
| Pixeli clar diferiți de fundal | ≥ 12 % |
| Siluetă plină (opac / încadrare) | ≥ 0.30 |
| Culori | ≤ 64 |

Rezultatul curent (`docs/audit/readability.txt`): toate cele 6 subiecte trec. Avertisment pentru toate: **fără lumina eroului (marginea ecranului) contrastul scade sub 0.10** — de aceea ochii strălucitori și conturul sunt importanți pentru monștri. Înainte de pipeline, Ilva (147 culori) și Mira (188) picau la paletă; după pipeline au 40.

## 6. Comenzi

```bash
godot --headless --path . --import
godot --headless --path . --script res://tools/sprite_pipeline/build_sheet.gd -- art/sheets/corvin.spec.json
godot --headless --path . --import
godot --headless --path . --script res://tools/sprite_pipeline/make_spriteframes.gd -- res://art/sheets/corvin_sheet.json
godot --headless --path . --script res://tools/validate_readability.gd
godot --headless --path . --script res://tools/check_assets.gd
```

(`godot` = `E:/godot/Godot_v4.7.2-stable_win64_console.exe`; `check_assets` și `validate_readability` ies cu cod 1 dacă găsesc probleme.)
