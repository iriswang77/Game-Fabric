# Game-Fabric — Operation Quiet Window

A 2D narrative-stealth puzzle game built with **Godot 4**.

> *You are an unauthorized process — disguised as a small red browser window — infiltrating an authoritarian government's public website to steal classified intel.*

---

## Concept

**Aesthetic:** Hand-drawn, "scratchy" UI with a wobbly Windows 95 meets Dystopia look.  
**Tone:** Experimental, tense, and narrative-driven (similar to *Papers, Please*).

---

## Project Structure

```
project.godot               Godot 4 project config (autoloads GameState)
scenes/
  Main.tscn                 Browser viewport / playfield (run this to start)
  Player.tscn               The Red Window — draggable, size = HP
  Enemy.tscn                Blue Security Window — patrols, damages on sight
  Document.tscn             Classified intel collectible
  MaskingWindow.tscn        Propaganda window hiding a Document underneath
  Cursor.tscn               Inevitable cursor-threat, activates at full Gaze
scripts/
  GameState.gd              Global singleton — intel, Gaze meter, integrity, endings
  Player.gd                 Drag movement, size-as-HP shrink mechanic
  Enemy.gd                  Patrol AI, distance-based player detection
  Document.gd               Reveal & collect logic
  MaskingWindow.gd          Drag logic + Gaze meter increase
  Cursor.gd                 Chase AI, proximity damage
  Main.gd                   Scene wiring, HUD, narrative ending triggers
shaders/
  wobbly_screen.gdshader    CRT scanlines + wobbly-edge post-process effect
```

---

## Core Mechanics

| Mechanic | Description |
|---|---|
| **PlayerWindow (Red)** | Drag to move. Scale = HP. Shrinks when hit; tiny = fast but fragile. |
| **EnemyWindow (Blue)** | Patrols left/right. Damages player when within detection range. |
| **MaskingWindow (Grey)** | Drag off documents. Every pixel moved raises the **Gaze Meter**. |
| **Gaze Meter** | 0-100. Decays slowly when idle. Hits 100 -> Cursor activates. |
| **The Cursor** | Chases the player relentlessly once the Gaze Meter is full. |
| **Documents** | Hidden under Masking Windows. Collect all 3 to unlock endings. |

---

## Narrative Endings

Collect all 3 classified documents to trigger the final choice:

- **UPLOAD** — Send the intel to your handler. Mission success. *(Complicit ending.)*  
- **LEAK** — Release the intel to the public. *(Public betrayal ending.)*  
- **DELETE** — Erase everything. Leave no trace. *(Quiet erasure ending.)*

---

## How to Run

1. Install [Godot 4.2+](https://godotengine.org/download).
2. Open the project folder (`File -> Open Project`).
3. Press **F5** (or the Play button) to run `Main.tscn`.

---

## Requirements

- Godot Engine **4.2** or later  
- Forward Plus renderer (default; set in `project.godot`)
