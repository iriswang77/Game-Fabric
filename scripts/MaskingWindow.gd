extends Node2D
## MaskingWindow — Draggable propaganda window that conceals a Document.
## Moving it increases the Gaze meter.
## When dragged far enough from its origin the hidden document is revealed.

const WINDOW_WIDTH:        float = 130.0
const WINDOW_HEIGHT:       float = 100.0
const GAZE_PER_PIXEL:      float = 0.04
const MIN_REVEAL_DISTANCE: float = 70.0

var is_dragging:   bool    = false
var drag_offset:   Vector2 = Vector2.ZERO
var origin_pos:    Vector2
var revealed:      bool    = false

@onready var hidden_doc: Node2D = $HiddenDocument

func _ready() -> void:
	origin_pos = global_position
	add_to_group("masking_windows")

func _input(event: InputEvent) -> void:
	if GameState.is_game_over:
		is_dragging = false
		return

	if event is InputEventMouseButton:
		var mbe := event as InputEventMouseButton
		if mbe.button_index == MOUSE_BUTTON_LEFT:
			if mbe.pressed:
				var rect := Rect2(
					global_position - Vector2(WINDOW_WIDTH * 0.5, WINDOW_HEIGHT * 0.5),
					Vector2(WINDOW_WIDTH, WINDOW_HEIGHT)
				)
				if rect.has_point(mbe.global_position):
					is_dragging = true
					drag_offset = global_position - mbe.global_position
					get_viewport().set_input_as_handled()
			else:
				if is_dragging:
					is_dragging = false
					_check_reveal()

	elif event is InputEventMouseMotion and is_dragging:
		var old_pos := global_position
		global_position  = event.global_position + drag_offset
		var moved := global_position.distance_to(old_pos)
		if moved > 0.5:
			GameState.add_gaze(moved * GAZE_PER_PIXEL)
		get_viewport().set_input_as_handled()

func _check_reveal() -> void:
	if revealed or hidden_doc == null:
		return
	if global_position.distance_to(origin_pos) >= MIN_REVEAL_DISTANCE:
		revealed = true
		hidden_doc.visible = true
		if hidden_doc.has_method("reveal"):
			hidden_doc.reveal()
