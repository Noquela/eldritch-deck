extends Node
class_name PlayerSanity

signal sanity_changed(current: int, maximum: int)
signal sanity_depleted
signal went_insane

@export var max_sanity: int = 10
@export var sanity_regen_per_turn: int = 3  # NÃO regenera totalmente!
var current_sanity: int = 0
var is_insane: bool = false  # Estado de enlouquecimento

func _ready() -> void:
	current_sanity = max_sanity
	sanity_changed.emit(current_sanity, max_sanity)

func spend_sanity(amount: int) -> bool:
	if current_sanity >= amount:
		current_sanity -= amount
		sanity_changed.emit(current_sanity, max_sanity)

		if current_sanity <= 0 and not is_insane:
			_trigger_insanity()

		return true
	return false

func restore_sanity(amount: int) -> void:
	current_sanity = min(max_sanity, current_sanity + amount)
	sanity_changed.emit(current_sanity, max_sanity)

	# Se recuperou sanidade, sai do enlouquecimento
	if current_sanity > 0 and is_insane:
		is_insane = false

func restore_partial() -> void:
	# Regenera apenas parcialmente no início do turno
	restore_sanity(sanity_regen_per_turn)

func lose_max_sanity(amount: int) -> void:
	# Perde sanidade MÁXIMA permanentemente (loucura progressiva)
	max_sanity = max(1, max_sanity - amount)
	current_sanity = min(current_sanity, max_sanity)
	sanity_changed.emit(current_sanity, max_sanity)
	print("Perdeu %d de sanidade máxima. Nova máxima: %d" % [amount, max_sanity])

func has_sanity(amount: int) -> bool:
	return current_sanity >= amount

func _trigger_insanity() -> void:
	# Enlouquecimento: efeitos ruins mas poder aumenta
	is_insane = true
	went_insane.emit()
	print("ENLOUQUECEU! Sanidade zerada!")
	# TODO: Adicionar efeitos de enlouquecimento (cartas mais fortes mas aleatórias?)
