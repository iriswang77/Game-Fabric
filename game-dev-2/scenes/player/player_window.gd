extends CharacterBody2D

# --- Tunable parameters (play with these later) ---
@export var move_speed: float = 400.0
@export var min_size: float = 20.0
@export var max_size: float = 200.0
@export var starting_size: float = 80.0
@export var size_change_per_hit: float = 15.0
@export var size_change_per_pickup: float = 20.0
@export var manual_resize_step: float = 5.0

# --- Internal state ---
var current_size: float
@onready var color_rect: ColorRect = $ColorRect
@onready var collision: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	current_size = starting_size
	_apply_size()


func _physics_process(delta: float) -> void:
	# Movement
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vector * move_speed
	move_and_slide()

	# Manual size control (Q / E)
	if Input.is_action_pressed("shrink"):
		_change_size(-manual_resize_step * delta * 60.0)
	if Input.is_action_pressed("grow"):
		_change_size(manual_resize_step * delta * 60.0)


func take_hit() -> void:
	_change_size(-size_change_per_hit)


func grow_from_pickup() -> void:
	_change_size(size_change_per_pickup)


func _change_size(amount: float) -> void:
	current_size = clamp(current_size + amount, min_size, max_size)
	_apply_size()
	if current_size <= min_size:
		_garbage_collected()


func _apply_size() -> void:
	# Keep the rectangle square-ish: width = size, height = size * 0.75
	var w := current_size
	var h := current_size * 0.75
	color_rect.position = Vector2(-w / 2.0, -h / 2.0)
	color_rect.size = Vector2(w, h)
	(collision.shape as RectangleShape2D).size = Vector2(w, h)


func _garbage_collected() -> void:
	print("GARBAGE COLLECTED — reloading scene")
	get_tree().reload_current_scene()
