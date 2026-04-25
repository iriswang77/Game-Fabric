extends CharacterBody2D
## Enemy — Blue security window.
## Patrols left/right between two generated points.
## When the player enters detection range, applies damage on a timer.

const PATROL_SPEED:     float = 70.0
const DETECT_DAMAGE:    float = 15.0
const DETECT_INTERVAL:  float = 1.0
const DETECTION_RANGE:  float = 160.0

@export var patrol_range: float = 120.0

var patrol_point_a:  Vector2
var patrol_point_b:  Vector2
var moving_to_b:     bool    = true
var player_ref:      Node2D  = null
var initial_pos:     Vector2

@onready var status_label: Label = $WindowBody/StatusLabel
@onready var damage_timer: Timer = $DamageTimer

func _ready() -> void:
	add_to_group("enemies")
	initial_pos    = global_position
	patrol_point_a = initial_pos + Vector2(-patrol_range, 0.0)
	patrol_point_b = initial_pos + Vector2( patrol_range, 0.0)
	damage_timer.wait_time = DETECT_INTERVAL
	damage_timer.one_shot  = false
	damage_timer.timeout.connect(_on_damage_timer_timeout)

func _physics_process(_delta: float) -> void:
	if GameState.is_game_over:
		velocity = Vector2.ZERO
		return
	_patrol()
	_check_detection()

func _patrol() -> void:
	var target := patrol_point_b if moving_to_b else patrol_point_a
	var dir    := (target - global_position).normalized()
	velocity    = dir * PATROL_SPEED
	move_and_slide()
	if global_position.distance_to(target) < 10.0:
		moving_to_b = not moving_to_b

func _check_detection() -> void:
	if player_ref == null:
		return
	var dist := global_position.distance_to(player_ref.global_position)
	if dist <= DETECTION_RANGE:
		if status_label:
			status_label.text = "[!! ALERT !!]"
		if damage_timer.is_stopped():
			damage_timer.start()
			_apply_damage()
	else:
		if status_label:
			status_label.text = "[SCANNING...]"
		if not damage_timer.is_stopped():
			damage_timer.stop()

func _apply_damage() -> void:
	if player_ref and player_ref.has_method("take_damage"):
		player_ref.take_damage(DETECT_DAMAGE)

func _on_damage_timer_timeout() -> void:
	if player_ref and global_position.distance_to(player_ref.global_position) <= DETECTION_RANGE:
		_apply_damage()
	else:
		damage_timer.stop()

## Called by Main.gd after all scenes are ready.
func set_player(player: Node2D) -> void:
	player_ref = player
