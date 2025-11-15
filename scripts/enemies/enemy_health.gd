extends Node2D
class_name EnemyHealth

signal health_changed(current: int, maximum: int)
signal enemy_died

@export var enemy_data: Resource = null
var max_health: int = 50
var current_health: int
var enemy_name: String = "Inimigo"

@onready var health_bar: ProgressBar = $HealthBar
@onready var sprite: ColorRect = $Sprite
@onready var enemy_ai = $EnemyAI
@onready var intention_label: Label = $IntentionLabel
@onready var name_label: Label = $NameLabel

func _ready() -> void:
	if enemy_data:
		initialize_from_data(enemy_data)
	current_health = max_health
	_update_health_bar()
	_update_name_label()

func initialize_from_data(data: Resource) -> void:
	enemy_data = data
	max_health = data.max_health
	enemy_name = data.enemy_name

	# Passar dados para a AI
	if enemy_ai:
		enemy_ai.set_enemy_data(data)

func _update_name_label() -> void:
	if name_label:
		name_label.text = enemy_name

func choose_action() -> Dictionary:
	return enemy_ai.choose_next_action()

func show_intention() -> void:
	if intention_label:
		intention_label.text = enemy_ai.get_action_description()

func get_next_action() -> Dictionary:
	return enemy_ai.get_next_action()

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
