extends Area2D
## Document — Classified intel collectible.
## Initially hidden under a MaskingWindow; revealed when the window is dragged away.
## Player collects it by overlapping the Area2D.

signal document_collected

@export var intel_value:  int    = 1
@export var document_id:  String = "doc_001"

var is_collected: bool = false

@onready var doc_label: Label = $Sprite/DocLabel

func _ready() -> void:
	add_to_group("documents")
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

## Called by MaskingWindow when it has moved far enough from its origin.
func reveal() -> void:
	visible = true
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.4)

func _on_body_entered(body: Node) -> void:
	_try_collect(body)

func _on_area_entered(area: Area2D) -> void:
	_try_collect(area.get_parent())

func _try_collect(node: Node) -> void:
	if is_collected:
		return
	if node.is_in_group("player") or (node.get_parent() != null and node.get_parent().is_in_group("player")):
		collect()

func collect() -> void:
	is_collected = true
	GameState.collect_intel()
	document_collected.emit()
	# Flash-then-shrink animation before freeing
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2(1.35, 1.35), 0.1)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
	tween.tween_callback(queue_free)
