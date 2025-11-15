extends Node
class_name StatusManager

signal status_applied(effect_type, stacks: int)
signal status_removed(effect_type)
signal status_updated(effect_type, stacks: int)

var effects: Dictionary = {}  # EffectType -> StatusEffect

func apply_status(effect_type, stacks: int, duration: int = -1) -> void:
	if effects.has(effect_type):
		# Adicionar stacks ao efeito existente
		effects[effect_type].stacks += stacks
		status_updated.emit(effect_type, effects[effect_type].stacks)
		print("Status atualizado: %s x%d" % [effects[effect_type].get_effect_name(), effects[effect_type].stacks])
	else:
		# Criar novo efeito
		var effect = StatusEffect.new(effect_type, stacks, duration)
		effects[effect_type] = effect
		status_applied.emit(effect_type, stacks)
		print("Status aplicado: %s x%d" % [effect.get_effect_name(), stacks])

func remove_status(effect_type) -> void:
	if effects.has(effect_type):
		var effect_name = effects[effect_type].get_effect_name()
		effects.erase(effect_type)
		status_removed.emit(effect_type)
		print("Status removido: %s" % effect_name)

func get_status_stacks(effect_type) -> int:
	if effects.has(effect_type):
		return effects[effect_type].stacks
	return 0

func has_status(effect_type) -> bool:
	return effects.has(effect_type)

func reduce_all_durations() -> void:
	var to_remove = []
	for effect_type in effects:
		var effect = effects[effect_type]
		effect.reduce_duration()
		if effect.is_expired():
			to_remove.append(effect_type)

	# Remover efeitos expirados
	for effect_type in to_remove:
		remove_status(effect_type)

func clear_all_statuses() -> void:
	effects.clear()

func get_all_effects() -> Array:
	return effects.values()
