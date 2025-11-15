extends Node
class_name PlayerEnergy

signal energy_changed(current: int, maximum: int)
signal energy_depleted

@export var max_energy: int = 3
var current_energy: int = 0

func _ready() -> void:
	current_energy = max_energy
	energy_changed.emit(current_energy, max_energy)

func spend_energy(amount: int) -> bool:
	if current_energy >= amount:
		current_energy -= amount
		energy_changed.emit(current_energy, max_energy)

		if current_energy <= 0:
			energy_depleted.emit()

		return true
	return false

func restore_energy(amount: int) -> void:
	current_energy = min(max_energy, current_energy + amount)
	energy_changed.emit(current_energy, max_energy)

func restore_full() -> void:
	current_energy = max_energy
	energy_changed.emit(current_energy, max_energy)

func has_energy(amount: int) -> bool:
	return current_energy >= amount
