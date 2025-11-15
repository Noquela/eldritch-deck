extends Node
class_name Corruption

signal corruption_changed(current: float, maximum: float)
signal corruption_maxed

@export var max_corruption: float = 100.0
var current_corruption: float = 0.0

func _ready() -> void:
	corruption_changed.emit(current_corruption, max_corruption)

func add_corruption(amount: float) -> void:
	current_corruption = min(max_corruption, current_corruption + amount)
	corruption_changed.emit(current_corruption, max_corruption)

	if current_corruption >= max_corruption:
		corruption_maxed.emit()

func reduce_corruption(amount: float) -> void:
	current_corruption = max(0.0, current_corruption - amount)
	corruption_changed.emit(current_corruption, max_corruption)

func get_corruption_percentage() -> float:
	return (current_corruption / max_corruption) * 100.0

func is_corrupted() -> bool:
	return current_corruption >= max_corruption
