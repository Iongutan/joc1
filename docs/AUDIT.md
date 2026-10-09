# Audit — Pactul Umbrei (joc1)

Data: 2026-10-09 · Ramura: `feature/audit-roadmap` (bază: `main` @ `30a8894`) · Motor: Godot 4.7.2 stable, renderer Compatibility · Platforma de test: Windows 11, RTX 5070 Ti Laptop.

## 1. Rezumat

Prototipul pornește, nu are erori de script în niciuna din cele 3 scene și rulează la ~60 FPS pe PC. Bucla de luptă (3 eroi × 3 arme, boss, victorie, pact) e funcțională. **Lipsesc însă sistemele care fac jocul diferit conform GDD**: satul viu și apărarea satului, reclamele/achizițiile, magazinul, progresul eroilor, localizarea EN/RU, exportul Android. Singurul bug P0 (cheie duplicată în `project.godot` + BOM în 31 de fișiere) a fost reparat pe această ramură.

**Ce s-a verificat efectiv** (nimic altceva nu e pretins):

- import complet al proiectului, headless — 0 erori;
- fiecare scenă rulată headless: meniu (600 cadre), poveste (600 cadre), luptă pentru fiecare erou cu toate cele 3 arme și boss-ul activ (4000 cadre / erou) — 0 erori de script; singurele mesaje sunt avertismente „ObjectDB instances leaked at exit” (cache-uri statice de texturi, inofensive);
- FPS măsurat în fereastră (vezi §6);
- capturi de ecran reale în `docs/audit/` (vezi §7).

**Ce NU s-a verificat:** pe telefon, build Android, input tactil real, consum de baterie, memorie, sunetul (nu poate fi ascultat în test automat), echilibrarea.

## 2. Diferențe cerință ↔ implementare (menționate explicit)

| Cerința din prompt / GDD | Realitatea în cod |
| --- | --- |
| „câmp duplicat config_version în project.godot” | **Confirmat.** `"ï»¿config_version"=5` apărut din BOM-ul UTF-8 scris de editări PowerShell. **Reparat** (BOM scos din 31 de fișiere, linia duplicată ștearsă). |
| GDD v2: 3 eroi la lansare, inclusiv Bran | Bran a fost scos (nu are ilustrație); roster = Corvin, Ilva, Mira. |
| GDD v2: 5 stele / 10 copii, Altarul Sorții | **Absent.** Nu există stele, copii sau altar. |
| GDD v2: satul ca meniu principal, apărarea satului | **Absent.** Meniul e un ecran clasic; „Satul” afișează doar „în curând”. |
| GDD v2: pactul ucide un sătean anume, stările satului | **Parțial.** Doar un contor „Săteni pierduți” în luptă; nu se salvează, nu afectează nimic. |
| GDD v2: reclame contextuale, VIP, pachete | **Absent.** „Lumânare (reclamă)” e un buton dezactivat. |
| GDD v2: limbi EN / RO / RU | **Absent.** Toate textele sunt scrise direct în cod, în română; nu există `tr()`. |
| GDD v2: progresul eroului (nivel 1–60, talente) | **Absent.** `Save.hero_levels` nu crește niciodată. |
| Concept: fiecare boss diferit | **Parțial.** Toate cele 4 capitole folosesc același sprite (Preotul-Craniu) sub alte nume. |
| Concept: arme cu animații diferite | **Funcțional**, dar eroii au doar 2 poze (stat/atac) animate procedural, nu animații cadru cu cadru. |

## 3. Matrice existent / funcțional / incomplet / absent

| Zonă | Stare | Detalii |
| --- | --- | --- |
| Pornire, meniu principal | Funcțional | Capitole cu săgeți, setări sunet/vibrații, buton Luptă |
| Poveste (prolog) | Funcțional | 6 scene, text animat, „Sari peste”, vibrații |
| Ecranul eroilor + echipament | Funcțional | 3 eroi, 6 sloturi, inventar static (nu se câștigă obiecte) |
| Luptă: mișcare, joystick, cameră | Funcțional | Joystick doar testat cu mouse (emulare touch) |
| Inamici (4 tipuri), spawn, boss | Funcțional | MultiMesh + grilă spațială; boss același în toate capitolele |
| Arme (9) + nivel 1–8 | Funcțional | Neechilibrate; fără teste de valori |
| Inimi segmentate, invulnerabilitate | Funcțional | |
| Super-putere + scena anime | Funcțional | |
| Nivel nou (3 alegeri), pauză, victorie, moarte/pact | Funcțional | |
| Salvare (aur, erou, capitol, echipament, setări) | Funcțional | Fără versiune de format / migrare |
| Sunete, muzică, vibrații | Incomplet | Sintetizate procedural; vibrația necesită permisiune Android |
| Atmosferă (lumini, ceață, particule) | Funcțional | |
| Satul viu / apărarea satului | Absent | Nucleul GDD |
| Magazin, valute (Lacrimi), Altar, stele | Absent | Lacrimile apar doar ca număr 0 |
| Reclame (AdMob), achiziții (Billing), consimțământ GDPR | Absent | |
| Localizare EN / RU | Absent | |
| Export Android (preset, semnare, permisiuni) | Absent | Fără `export_presets.cfg` |
| Teste automate | Absent | Doar rulări headless manuale |

## 4. Inventar

**Scene (3):** `features/menu/main_menu.tscn`, `features/run/run.tscn`, `features/story/intro.tscn`. Restul UI-ului e construit din cod.

**Eroi (3) și arme (9):**

| Erou | Arme | Super |
| --- | --- | --- |
| Corvin | `crossbow.gd`, `flintlock.gd`, `holy_water.gd` | Ploaia de argint |
| Ilva | `ice_shards.gd`, `frost_ring.gd`, `avalanche.gd` | Iarna veșnică |
| Mira | `fireball.gd`, `flame_ring.gd`, `meteors.gd` | Ploaia de meteori |

**Inamici / bossi:** Cultist (`UMBRAR`), Sângeriu (`SANGERIU`), Căpcăun (`OGRE`, elit la 50 s), Preotul-Craniu (`BOSS`) — `core/enemy_manager.gd`, desen în `art/gen/monster_art.gd`.

**UI:** HUD, panou de alegeri, joystick, scena super, ecranul eroilor, meniu, fundaluri pixel (`PixelCanvas`).

**Autoload:** `Events`, `Save`, `Audio`.

**Asseturi:** 12 sprite-uri de eroi (`art/heroes/*`), `art/monsters/preot.png` (**nefolosit**), 2 documente `.docx` în `materiale/`. Restul graficii (inamici, iconițe, font, rame UI, proiectile) e generat din cod.

**Cod mort:** `art/rig/hero_rig.gd` (HeroRig), `features/menu/pact_sigil.gd`, `features/run/weapons/moon_blades.gd`, `features/run/weapons/white_flower.gd`.

## 5. Bugs și riscuri, prioritizate

### P0 — blochează

| # | Problemă | Stare |
| --- | --- | --- |
| P0-1 | Cheie duplicată `config_version` în `project.godot` + BOM în 31 de fișiere (risc de încărcare greșită a proiectului) | **Reparat pe această ramură** |

### P1 — important înainte de vertical slice

| # | Problemă | Fișier |
| --- | --- | --- |
| P1-1 | Satul viu / apărarea satului lipsesc (diferențiatorul jocului) | — |
| P1-2 | Nu există export Android; vibrația cere permisiunea `VIBRATE` | `export_presets.cfg` lipsă |
| P1-3 | Textele nu sunt localizabile (fără `tr()`) | toate UI-urile |
| P1-4 | Același sprite de boss pentru 4 capitole cu nume diferite | `monster_art.gd`, `chapters.gd` |
| P1-5 | Progresul eroului nu există (`hero_levels` nu crește), aurul nu are pe ce fi cheltuit | `save.gd`, meniu |
| P1-6 | O oprire de ~285 ms observată o singură dată într-o luptă (cauză neidentificată; posibil generarea muzicii sau a fontului) | `audio.gd` / `pixel_font.gd` |
| P1-7 | Ilustrațiile mari din Figma nu sunt descărcate; linkurile expiră în jur de 2026-10-16 | — |

### P2 — calitate

| # | Problemă | Fișier |
| --- | --- | --- |
| P2-1 | Tastele de test T (200 inamici), B (boss) active și în build-ul final | `run.gd:157` |
| P2-2 | `--hero=` (test) se scrie în salvare la ieșirea din luptă | `run.gd`, `save.gd` |
| P2-3 | Apa sfințită și Lavina îl întorc pe erou mereu spre dreapta la aruncare | `holy_water.gd`, `avalanche.gd`, `meteors.gd` |
| P2-4 | Poza de atac a lui Corvin păstrează puțin pământ din ilustrația originală | `art/heroes/corvin_attack*.png` |
| P2-5 | Textul „SUPER” se suprapune peste portret în butonul de super | `hud.gd` |
| P2-6 | Cod mort (4 scripturi) și asset nefolosit (`preot.png`) | §4 |
| P2-7 | Muzica e generată sincron la prima pornire (blochează firul principal) | `audio.gd` |
| P2-8 | Literele chirilice cad pe fontul standard (nu pixel) | `pixel_font.gd` |
| P2-9 | Salvarea nu are versiune de format | `save.gd` |
| P2-10 | Obiectele de echipament de tip „armă” nu au legătură cu armele reale ale eroilor | `items.gd` |

### Dependențe și riscuri

- **Grafica** depinde de generarea AI (Figma, credite) + `tools/pixelize.gd`; consistența între cadre e riscul principal pentru animații cadru cu cadru.
- **Monetizarea** depinde de pluginuri terțe Godot (AdMob, Google Play Billing) — încă neinstalate, compatibilitate cu 4.7 neverificată.
- **Performanța pe telefon** e necunoscută; PC-ul de test e mult peste un telefon mediu.
- **Google Play**: cont personal nou → test închis 12+ testeri × 14 zile înainte de producție.

## 6. Snapshot FPS (PC, fereastră 450×800, VSync activ)

| Scenă / scenariu | FPS min | FPS mediu | FPS max |
| --- | --- | --- | --- |
| Meniu principal | 43 | 58 | 60 |
| Poveste (prolog) | 56 | ~59 | 60 |
| Luptă — Corvin, 3 arme | 60 | 60 | 60 |
| Luptă — Mira, 3 arme, boss activ, spawn maxim | 60 | 60 | 60 |

Metodă: `godot --path . <scenă> --quit-after N -- --perf` (scrie FPS în consolă la fiecare 60 de cadre, prima mostră ignorată).

## 7. Capturi (făcute pe această ramură)

| Fișier | Ce arată |
| --- | --- |
| [menu.png](audit/menu.png) | Meniul principal |
| [heroes.png](audit/heroes.png) | Ecranul eroilor |
| [intro.png](audit/intro.png) | Prima scenă din poveste |
| [run.png](audit/run.png) | Luptă, primele secunde |
| [boss.png](audit/boss.png) | Lupta cu boss-ul |
| [w_corvin.png](audit/w_corvin.png), [w_ilva.png](audit/w_ilva.png), [w_mira.png](audit/w_mira.png) | Fiecare erou cu toate cele 3 arme |

## 8. Comenzi de test

```bash
# import + erori de script
"E:/godot/Godot_v4.7.2-stable_win64_console.exe" --headless --path . --import
# luptă headless, un erou, toate armele, boss
"E:/godot/Godot_v4.7.2-stable_win64_console.exe" --headless --path . res://features/run/run.tscn --quit-after 4000 -- --hero=mira --all-weapons --boss-now --shot-autoplay
# FPS în fereastră
"E:/godot/Godot_v4.7.2-stable_win64_console.exe" --path . res://features/run/run.tscn --quit-after 1800 -- --perf --hero=corvin --all-weapons
# captură de ecran
"E:/godot/Godot_v4.7.2-stable_win64_console.exe" --path . -- --skip-intro --shot=menu.png --shot-delay=3
```

Opțiuni de test: `--skip-intro`, `--open-heroes`, `--boss-now`, `--hero=<corvin|ilva|mira>`, `--all-weapons`, `--shot-autoplay`, `--shot=<fișier>`, `--shot-delay=<s>`, `--perf`.
