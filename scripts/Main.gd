extends Node2D
## Main — Scene root.
## Wires up all nodes, manages the HUD, and handles the three narrative endings.

const TOTAL_INTEL: int = 3

@onready var player:          Node2D       = $Player
@onready var cursor:          Node2D       = $Cursor
@onready var gaze_bar:        ProgressBar  = $HUD/GazeBar
@onready var integrity_bar:   ProgressBar  = $HUD/IntegrityBar
@onready var intel_label:     Label        = $HUD/IntelLabel
@onready var game_over_screen: Panel       = $HUD/GameOverScreen
@onready var ending_screen:   Panel        = $HUD/EndingScreen
@onready var ending_label:    Label        = $HUD/EndingScreen/VBox/EndingLabel
@onready var choice_container: VBoxContainer = $HUD/EndingScreen/VBox/ChoiceContainer
@onready var upload_btn:      Button       = $HUD/EndingScreen/VBox/ChoiceContainer/UploadBtn
@onready var leak_btn:        Button       = $HUD/EndingScreen/VBox/ChoiceContainer/LeakBtn
@onready var delete_btn:      Button       = $HUD/EndingScreen/VBox/ChoiceContainer/DeleteBtn
@onready var restart_btn:     Button       = $HUD/GameOverScreen/VBox/RestartBtn

func _ready() -> void:
	GameState.reset()

	# Wire enemies to the player
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_method("set_player"):
			enemy.set_player(player)

	cursor.set_player(player)

	# HUD signals
	GameState.gaze_changed.connect(_on_gaze_changed)
	GameState.intel_changed.connect(_on_intel_changed)
	GameState.game_over_triggered.connect(_on_game_over)
	GameState.ending_triggered.connect(_on_ending_triggered)

	# Button signals
	upload_btn.pressed.connect(_on_upload_pressed)
	leak_btn.pressed.connect(_on_leak_pressed)
	delete_btn.pressed.connect(_on_delete_pressed)
	restart_btn.pressed.connect(_on_restart_pressed)

	# Initialise HUD
	gaze_bar.max_value      = 100.0
	gaze_bar.value          = 0.0
	integrity_bar.max_value = 100.0
	integrity_bar.value     = 100.0
	intel_label.text        = "Intel: 0 / %d" % TOTAL_INTEL

	game_over_screen.visible = false
	ending_screen.visible    = false

func _process(_delta: float) -> void:
	if not GameState.is_game_over:
		integrity_bar.value = GameState.player_integrity

# ── HUD callbacks ──────────────────────────────────────────────────────────────
func _on_gaze_changed(new_level: float) -> void:
	gaze_bar.value = new_level

func _on_intel_changed(new_count: int) -> void:
	intel_label.text = "Intel: %d / %d" % [new_count, TOTAL_INTEL]
	if new_count >= TOTAL_INTEL:
		_show_ending_choices()

func _on_game_over() -> void:
	game_over_screen.visible = true

func _on_ending_triggered(ending_type: String) -> void:
	choice_container.visible = false
	match ending_type:
		"UPLOAD":
			ending_label.text = (
				"ENDING: UPLOAD\n\n"
				+ "\"The data is sent.\"\n\n"
				+ "You complete the mission.\n"
				+ "But who gave the order?\n\n"
				+ "[ Complicit in silence. ]"
			)
		"LEAK":
			ending_label.text = (
				"ENDING: LEAK\n\n"
				+ "\"The truth floods public feeds.\"\n\n"
				+ "The system fractures.\n"
				+ "You are marked.\n\n"
				+ "[ The people know. ]"
			)
		"DELETE":
			ending_label.text = (
				"ENDING: DELETE\n\n"
				+ "\"You erase all intel.\"\n\n"
				+ "No trace. No mission.\n"
				+ "The quiet erasure.\n\n"
				+ "[ Did it ever happen? ]"
			)

func _show_ending_choices() -> void:
	ending_label.text    = "MISSION COMPLETE\n\nAll intel retrieved.\nWhat will you do with it?"
	choice_container.visible = true
	ending_screen.visible    = true

# ── Button handlers ────────────────────────────────────────────────────────────
func _on_upload_pressed() -> void:
	GameState.trigger_ending("UPLOAD")

func _on_leak_pressed() -> void:
	GameState.trigger_ending("LEAK")

func _on_delete_pressed() -> void:
	GameState.trigger_ending("DELETE")

func _on_restart_pressed() -> void:
	GameState.reset()
	get_tree().reload_current_scene()
