# Licențe și surse de grafică

## 1. Regula de bază

Intră în joc **doar** grafică pentru care avem dreptul scris de folosire comercială, notat în `assets_manifest.csv` și verificat cu `tools/check_assets.gd`.

**Interzis:** extragerea („rip”) de sprite-uri sau imagini din alte jocuri (inclusiv **Guardian Tales**), de pe **Pinterest**, Google Images, DeviantArt, ArtStation sau rețele sociale, fără licență explicită de la autor. Pinterest nu acordă licențe pentru imaginile salvate de alții, iar grafica unui joc comercial aparține editorului lui. Referințele de stil (cum arată, ce culori, ce proporții) sunt permise ca inspirație, nu ca fișiere.

## 2. Fișa de licență (câmpurile din `assets_manifest.csv`)

| Câmp | Ce conține |
| --- | --- |
| `path` | Calea `res://` a fișierului |
| `kind` | sprite, spritesheet, palette, tileset, font, sound, music |
| `source` | De unde vine (link, unealtă, pachet) |
| `author` | Autorul / studioul |
| `license` | Numele licenței sau rezumatul exact al termenilor |
| `license_url` | Pagina cu termenii |
| `commercial_use` | `yes` doar dacă termenii permit explicit |
| `attribution_required` | `yes` / `no` (+ textul de credit în `notes`) |
| `ai_training_allowed` | ce spun termenii despre antrenarea AI (`no`, `yes`, `n/a`) |
| `verified_on` | data la care am citit termenii |
| `notes` | restricții (fără revânzare etc.) |

## 3. Grafica existentă în proiect

| Origine | Licență | Verificat |
| --- | --- | --- |
| Eroii și boss-ul din `art/heroes`, `art/monsters` — generate cu Figma AI (contul proiectului), pixelizate cu `tools/pixelize.gd` | [Figma AI Terms](https://www.figma.com/legal/ai-terms/) (în vigoare din 24.06.2026): §2 „Customer retains all right, title, and interest in Customer’s Input and Output”; §5 fără garanții — clientul răspunde de verificarea drepturilor. | 2026-10-09 |
| Sheet-uri și palete derivate (`art/sheets`, `art/palettes`) | Derivate ale rândului de mai sus | 2026-10-09 |
| Inamici, iconițe, font, rame UI, proiectile, fundaluri | Desenate din cod în proiect (fără fișiere externe) | — |

## 4. Surse comerciale verificate (2026-10-09)

Doar sursele de mai jos au fost citite pe pagina oficială la data indicată. **Termenii se pot schimba: recitește-i la cumpărare și pune data nouă în manifest.**

| Pachet | Preț | Uz comercial | Modificare | Atribuire | Restricții |
| --- | --- | --- | --- | --- | --- |
| [Monster Second Pack — bobddadoo](https://bobddadoo.itch.io/monster-second-pack) (orc, șopârlă, ciupercă, golem; 64×64, 1136 cadre) | min. 9,99 $ | Da („unlimited personal and commercial projects once purchased”) | Da | Apreciată, nu obligatorie | Fără revânzare/redistribuire a asseturilor; **fără antrenare AI** |
| [The Dark Series: Top Down Monster Pack 1 — Penusbmic](https://penusbmic.itch.io/the-dark-series-top-down-monster-pack-1) | min. 3 $ | Da („Feel free to use for commercial projects”) | Da | Cerută opțional („Penusbmic”) | Fără revânzare individuală; fără licență formală — păstrează captura paginii |
| [Caves & Goblins 32×32 — goblin-enjoyer](https://goblin-enjoyer.itch.io/caves-goblins-a-32x32-asset-pack) | Plătești cât vrei | Da | Da | Nespecificată | Fără revânzare/redistribuire, NFT, **antrenare AI** |
| [Kenney](https://kenney.nl/support) (UI, iconițe, efecte) | Gratuit | Da — CC0 | Da | Nu e obligatorie | Logo-ul Kenney nu se folosește |

Nu au fost verificate (deci **nu** se folosesc până la verificare): orice alt pachet menționat în discuții anterioare.

## 5. Când adaugi un asset

1. Citește pagina de licență; salvează o captură în `materiale/licente/`.
2. Pune fișierul în `art/…`.
3. Adaugă rândul în `assets_manifest.csv` cu toate câmpurile.
4. Rulează `tools/check_assets.gd` — trebuie să afișeze `OK`.
