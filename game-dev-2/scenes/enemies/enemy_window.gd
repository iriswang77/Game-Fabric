extends Area2D

# --- Tunable parameters ---
@export var patrol_speed: float = 200.0
@export var patrol_distance: float = 400.0  # how far it travels before turning

# --- Internal state ---
var _start_x: float
var _direction: int = 1  # 1 = right, -1 = left


func _ready() -> void:
	_start_x = global_position.x
	# Connect the overlap signal — fires when a CharacterBody2D enters our area
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	# Move horizontally
	global_position.x += patrol_speed * _direction * delta

	# Flip direction at the patrol bounds
	if global_position.x > _start_x + patrol_distance:
		_direction = -1
	elif global_position.x < _start_x - patrol_distance:
		_direction = 1


func _on_body_entered(body: Node2D) -> void:
	# Only damage the player, ignore anything else
	if body.has_method("take_hit"):
		body.take_hit()
