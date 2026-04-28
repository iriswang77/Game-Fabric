extends Node2D
## Cursor — The inevitable threat.
## Activates once the Gaze meter reaches 100%.
## Chases the player and deals contact damage.

const CHASE_SPEED:     float = 130.0
const CONTACT_DAMAGE:  float = 20.0
const DAMAGE_COOLDOWN: float = 0.6

var player_ref:          Node2D = null
var is_active:           bool   = false
var damage_cooldown_left: float  = 0.0

@onready var activation_timer: Timer    = $ActivationTimer
@onready var sprite:           ColorRect = $Sprite

func _ready() -> void:
	visible = false
	GameState.cursor_activated.connect(_on_cursor_activated)
	activation_timer.wait_time = 2.0
	activation_timer.one_shot  = true
	activation_timer.timeout.connect(_start_chase)

func _process(delta: float) -> void:
	if not is_active or player_ref == null or GameState.is_game_over:
		return

	# Chase
	var dir := (player_ref.global_position - global_position).normalized()
	global_position += dir * CHASE_SPEED * delta

	# Proximity damage
	if damage_cooldown_left > 0.0:
		damage_cooldown_left -= delta
	var dist := global_position.distance_to(player_ref.global_position)
	if dist < 28.0 and damage_cooldown_left <= 0.0:
		damage_cooldown_left = DAMAGE_COOLDOWN
		if player_ref.has_method("take_damage"):
			player_ref.take_damage(CONTACT_DAMAGE)

func _on_cursor_activated() -> void:
	visible = true
	var vp := get_viewport_rect()
	global_position = Vector2(vp.size.x + 50.0, vp.size.y * 0.5)
	activation_timer.start()

func _start_chase() -> void:
	is_active = true

## Called by Main.gd once the player node is available.
func set_player(player: Node2D) -> void:
	player_ref = player
