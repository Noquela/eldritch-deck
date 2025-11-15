extends Resource
class_name StatusEffect

enum EffectType {
	STRENGTH,      # Aumenta dano causado
	WEAKNESS,      # Reduz dano causado
	VULNERABLE,    # Recebe mais dano
	FRAIL,         # Perde mais bloqueio
	REGEN,         # Regenera vida por turno
	POISON         # Perde vida por turno
}

var type: EffectType
var stacks: int = 0
var duration: int = -1  # -1 = permanente, >= 0 = temporário

func _init(effect_type: EffectType, amount: int = 1, turns: int = -1) -> void:
	type = effect_type
	stacks = amount
	duration = turns

func get_effect_name() -> String:
	match type:
		EffectType.STRENGTH:
			return "Força"
		EffectType.WEAKNESS:
			return "Fraqueza"
		EffectType.VULNERABLE:
			return "Vulnerável"
		EffectType.FRAIL:
			return "Frágil"
		EffectType.REGEN:
			return "Regeneração"
		EffectType.POISON:
			return "Veneno"
	return "Desconhecido"

func reduce_duration() -> void:
	if duration > 0:
		duration -= 1

func is_expired() -> bool:
	return duration == 0
