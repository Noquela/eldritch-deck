extends Node
class_name RitualManager

signal ritual_started(ritual_name: String, turns: int)
signal ritual_progressed(ritual_name: String, turns_remaining: int)
signal ritual_completed(ritual_name: String)

class ActiveRitual:
	var card_data: CardData
	var turns_remaining: int
	var damage_dealt: int = 0

	func _init(data: CardData):
		card_data = data
		turns_remaining = data.ritual_turns

var active_rituals: Array[ActiveRitual] = []

func start_ritual(card_data: CardData) -> void:
	if not card_data.is_ritual:
		push_error("Tentou iniciar ritual com carta não-ritual!")
		return

	var ritual = ActiveRitual.new(card_data)
	active_rituals.append(ritual)

	print("🔮 RITUAL INICIADO: %s (%d turnos)" % [card_data.card_name, card_data.ritual_turns])
	ritual_started.emit(card_data.card_name, card_data.ritual_turns)

func progress_rituals(enemy) -> void:
	var completed_rituals: Array[ActiveRitual] = []

	for ritual in active_rituals:
		# Aplicar dano por turno
		if ritual.card_data.ritual_damage_per_turn > 0 and is_instance_valid(enemy):
			enemy.take_damage(ritual.card_data.ritual_damage_per_turn)
			ritual.damage_dealt += ritual.card_data.ritual_damage_per_turn
			print("🔮 Ritual '%s' causa %d de dano" % [ritual.card_data.card_name, ritual.card_data.ritual_damage_per_turn])

		# Decrementar turnos
		ritual.turns_remaining -= 1
		print("🔮 Ritual '%s' - %d turnos restantes" % [ritual.card_data.card_name, ritual.turns_remaining])
		ritual_progressed.emit(ritual.card_data.card_name, ritual.turns_remaining)

		# Verificar se completou
		if ritual.turns_remaining <= 0:
			completed_rituals.append(ritual)

	# Completar rituais finalizados
	for ritual in completed_rituals:
		_complete_ritual(ritual, enemy)
		active_rituals.erase(ritual)

func _complete_ritual(ritual: ActiveRitual, enemy) -> void:
	print("✨ RITUAL COMPLETO: %s!" % ritual.card_data.card_name)

	# Aplicar dano final
	if ritual.card_data.ritual_final_damage > 0 and is_instance_valid(enemy):
		enemy.take_damage(ritual.card_data.ritual_final_damage)
		print("✨ Dano final do ritual: %d" % ritual.card_data.ritual_final_damage)

	# Efeito especial
	if ritual.card_data.ritual_final_effect != "":
		print("✨ Efeito especial: %s" % ritual.card_data.ritual_final_effect)
		# TODO: Implementar efeitos especiais customizados

	ritual_completed.emit(ritual.card_data.card_name)

func get_active_rituals_count() -> int:
	return active_rituals.size()

func get_active_rituals_info() -> String:
	if active_rituals.is_empty():
		return ""

	var info: Array[String] = []
	for ritual in active_rituals:
		info.append("%s (%d)" % [ritual.card_data.card_name, ritual.turns_remaining])

	return "Rituais: " + " | ".join(info)

func clear_all_rituals() -> void:
	active_rituals.clear()
