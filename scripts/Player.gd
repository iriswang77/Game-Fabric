extends Node2D
## Player — The unauthorised red browser window.
## Drag the window with the mouse to move it.
## Window scale represents HP: shrinking = losing integrity.
## If integrity reaches 0 → "Garbage Collection" (Game Over).

signal player_damaged(new_integrity: float)
signal player_dead

const WINDOW_WIDTH:   float = 100.0
const WINDOW_HEIGHT:  float = 70.0
const MAX_INTEGRITY:  float = 100.0

var integrity:    float = MAX_INTEGRITY
var is_dragging:  bool  = false
var drag_offset:  Vector2 = Vector2.ZERO

@onready var hit_area:     Area2D = $HitArea
@onready var window_body:  Panel  = $WindowBody
@onready var status_label: Label  = $WindowBody/BodyContent

func _ready() -> void:
	add_to_group("player")
	GameState.game_over_triggered.connect(_on_game_over)

func _input(event: InputEvent) -> void:
	if GameState.is_game_over:
		is_dragging = false
		return

	if event is InputEventMouseButton:
		var mbe := event as InputEventMouseButton
		if mbe.button_index == MOUSE_BUTTON_LEFT:
			if mbe.pressed:
				var half_w := WINDOW_WIDTH  * scale.x * 0.5
				var half_h := WINDOW_HEIGHT * scale.y * 0.5
				var rect   := Rect2(
					global_position - Vector2(half_w, half_h),
					Vector2(WINDOW_WIDTH * scale.x, WINDOW_HEIGHT * scale.y)
				)
				if rect.has_point(mbe.global_position):
					is_dragging = true
					drag_offset = global_position - mbe.global_position
					get_viewport().set_input_as_handled()
			else:
				is_dragging = false

	elif event is InputEventMouseMotion and is_dragging:
		global_position = event.global_position + drag_offset
		get_viewport().set_input_as_handled()

## Called by enemies and the cursor when they deal damage.
func take_damage(amount: float) -> void:
	integrity = maxf(0.0, integrity - amount)
	GameState.damage_player(amount)
	_update_size()
	player_damaged.emit(integrity)
	if status_label:
		status_label.text = "[INTEGRITY: %d%%]" % int(integrity)
	if integrity <= 0.0:
		player_dead.emit()

func _update_size() -> void:
	# Map integrity 0–100 to scale 0.1–1.0
	var ratio     := integrity / MAX_INTEGRITY
	var new_scale := lerpf(0.1, 1.0, ratio)
	scale = Vector2(new_scale, new_scale)

func _on_game_over() -> void:
	is_dragging = false
	set_process_input(false)
