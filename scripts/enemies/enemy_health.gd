extends Node2D
class_name EnemyHealth

signal health_changed(current: int, maximum: int)
signal enemy_died

@export var max_health: int = 50
var current_health: int

@onready var health_bar: ProgressBar = $HealthBar
@onready var sprite: ColorRect = $Sprite

func _ready() -> void:
	current_health = max_health
	_update_health_bar()

func take_damage(amount: int) -> void:
	current_health = max(0, current_health - amount)
	_update_health_bar()
	health_changed.emit(current_health, max_health)

	if current_health <= 0:
		enemy_died.emit()
		queue_free()

func _update_health_bar() -> void:
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health
