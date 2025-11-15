extends Node
class_name PlayerHealth

signal health_changed(current: int, maximum: int)
signal player_died

@export var max_health: int = 100
var current_health: int
var player_block = null

func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)

func set_player_block(block_system) -> void:
	player_block = block_system

func take_damage(amount: int) -> void:
	var damage_to_take = amount

	# Se tem bloqueio, absorver dano primeiro
	if player_block and player_block.get_block() > 0:
		var blocked = player_block.lose_block(amount)
		damage_to_take -= blocked
		print("Bloqueio absorveu %d de dano! Dano restante: %d" % [blocked, damage_to_take])

	# Aplicar dano restante na vida
	if damage_to_take > 0:
		current_health = max(0, current_health - damage_to_take)
		health_changed.emit(current_health, max_health)

	if current_health <= 0:
		player_died.emit()

func heal(amount: int) -> void:
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)

func get_health_percentage() -> float:
	return float(current_health) / float(max_health)
