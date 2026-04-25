extends Node
## GameState — Global singleton (autoload).
## Tracks player integrity, collected intel, the Gaze meter, and ending logic.

signal gaze_changed(new_level: float)
signal intel_changed(new_count: int)
signal game_over_triggered
signal ending_triggered(ending_type: String)
signal cursor_activated

# ── State variables ────────────────────────────────────────────────────────────
var intel_collected: int  = 0
var gaze_level:      float = 0.0
var player_integrity: float = 100.0
var is_game_over:    bool  = false
var cursor_active:   bool  = false

# ── Constants ──────────────────────────────────────────────────────────────────
const MAX_GAZE: float        = 100.0
const GAZE_DECAY_RATE: float = 1.5   # units per second (passive decay)

# ── Process ───────────────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	if is_game_over:
		return
	# Slowly reduce gaze when the cursor is not yet active
	if not cursor_active and gaze_level > 0.0:
		gaze_level = maxf(0.0, gaze_level - GAZE_DECAY_RATE * delta)
		gaze_changed.emit(gaze_level)

# ── Public API ─────────────────────────────────────────────────────────────────
func add_gaze(amount: float) -> void:
	if is_game_over:
		return
	gaze_level = minf(MAX_GAZE, gaze_level + amount)
	gaze_changed.emit(gaze_level)
	if gaze_level >= MAX_GAZE and not cursor_active:
		cursor_active = true
		cursor_activated.emit()

func collect_intel() -> void:
	if is_game_over:
		return
	intel_collected += 1
	intel_changed.emit(intel_collected)

func damage_player(amount: float) -> void:
	if is_game_over:
		return
	player_integrity = maxf(0.0, player_integrity - amount)
	if player_integrity <= 0.0:
		trigger_game_over()

func trigger_game_over() -> void:
	if is_game_over:
		return
	is_game_over = true
	game_over_triggered.emit()

## ending_type must be one of: "UPLOAD", "LEAK", "DELETE"
func trigger_ending(ending_type: String) -> void:
	is_game_over = true
	ending_triggered.emit(ending_type)

func reset() -> void:
	intel_collected  = 0
	gaze_level       = 0.0
	player_integrity = 100.0
	is_game_over     = false
	cursor_active    = false
