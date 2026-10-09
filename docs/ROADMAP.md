# Roadmap — Pactul Umbrei

Data: 2026-10-09 · Pornește de la [AUDIT.md](AUDIT.md). Principiu: **fără rescriere masivă** — se construiește peste arhitectura existentă (managere pe date, MultiMesh, autoload-uri, UI din cod).

## 1. Vertical slice (ținta următoare)

Un singur capitol, complet și „ca în magazin”, jucabil pe un telefon Android real:

1. Pornire → poveste (o dată) → meniu.
2. Alegi eroul (3) și pleci în **Capitolul 1: Câmpia**.
3. Luptă cu cele 3 arme ale eroului, elit, boss propriu (Preotul-Craniu).
4. **Pactul are consecințe**: săteni cu nume mor, satul își schimbă starea (4 stări) și dialogurile.
5. **Apărarea satului** — o noapte, 3 valuri, ziduri și un turn de îmbunătățit.
6. Victorie → aur → **un upgrade cumpărat** (nivelul eroului sau o stea de armă).
7. **O reclamă cu recompensă** (lumânare / aur ×2) cu ID-uri de test + consimțământ GDPR.
8. Textele în **RO + EN** prin `tr()`.
9. **APK instalat pe un telefon** și testat 15 minute fără crash, la ≥ 50 FPS.

**Criterii de acceptare a slice-ului:** toate cele 9 puncte demonstrate pe telefon, fără erori în log, cu capturi și video scurt.

## 2. Sprinturi (estimări pentru un dezvoltator + Claude, ~4 h/zi)

| Sprint | Durată | Conținut | Rezultat verificabil |
| --- | --- | --- | --- |
| **S0 — Igienă** | 1–2 zile | P0 reparat (gata pe ramură); P2-1/2/3/5/6 (taste de test doar în debug, curățare cod mort, orientarea eroului la aruncări, text SUPER); versiune de format în salvare | Import fără avertismente; build debug identic funcțional |
| **S1 — Android** | 2–3 zile | `export_presets.cfg`, permisiunea VIBRATE, semnare debug, APK pe telefon; măsurare FPS și input tactil reale | APK rulează pe telefon; tabel FPS telefon în AUDIT |
| **S2 — Satul viu** | 4–5 zile | Date săteni (nume, meserie), pactul ucide unul anume, 4 stări ale satului, dialoguri, persistență | Moartea prin pact schimbă vizibil satul după luptă |
| **S3 — Apărarea satului** | 5–6 zile | Mod nou în `run.tscn` (ziua: upgrade-uri; noaptea: valuri), ziduri, turn, refolosind EnemyManager/ZoneManager | O noapte completă jucabilă, câștig/pierdere |
| **S4 — Economie minimă** | 3–4 zile | Nivelul eroului cumpărat cu aur, 5 stele pe arme (10 copii) din cufere de boss | Aurul are utilitate; progres salvat |
| **S5 — Monetizare test** | 3–4 zile | Plugin AdMob (ID-uri de test), UMP/GDPR, reclama „lumânare” și „aur ×2”, limită zilnică | Reclamă de test afișată pe telefon |
| **S6 — Localizare** | 2–3 zile | Toate textele prin `tr()`, CSV RO/EN, comutator de limbă | Jocul complet în engleză |
| **S7 — Polish slice** | 3–4 zile | Boss propriu per capitol (sau doar cap. 1 în slice), sunete per armă, echilibrare, fix P1-6 | Checklist slice bifat |

**Total estimat până la vertical slice: ~23–31 zile de lucru.** Estimările presupun grafică generată + pixelizată cu `tools/pixelize.gd`; un artist ar adăuga timp de comandă, dar ar reduce riscul de consistență.

## 3. După vertical slice

| Etapă | Conținut |
| --- | --- |
| Test închis Google Play | 12+ testeri × 14 zile, update-uri săptămânale |
| Capitolele 2–4 | Bossi proprii, mecanici de capitol |
| Altarul Sorții, VIP, pachete | Monetizarea completă din GDD v2 |
| Animații cadru cu cadru | Foi de sprite pentru mers / atac / vrajă |
| Actul II | Tărâm nou, eroi noi |

## 4. Checklist de acceptare (pentru această ramură)

- [x] `project.godot` fără cheia duplicată; 0 fișiere cu BOM
- [x] Import headless fără erori
- [x] Cele 3 scene rulează headless fără erori de script
- [x] Lupta testată pentru fiecare erou cu toate cele 3 arme și boss-ul
- [x] FPS măsurat și documentat
- [x] Capturi reale în `docs/audit/`
- [x] `docs/AUDIT.md` și `docs/ROADMAP.md` create
- [ ] Revizuit de tine și aprobat pentru merge în `main`

## 5. Următorul pas

Aprobi merge-ul acestei ramuri în `main`, apoi începem **S0 + S1** (igienă și primul APK pe telefon) — fără un test pe telefon, orice altă estimare de performanță e o presupunere.
