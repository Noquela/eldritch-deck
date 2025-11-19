extends Resource
class_name BossData

## Boss enemy com múltiplas fases e habilidades especiais

@export var boss_name: String = "Boss Lovecraftiano"
@export var max_health: int = 150
@export var phases: Array[BossPhase] = []
@export var boss_lore: String = ""

## Retorna a fase atual baseada no HP %
func get_current_phase(current_hp: int) -> BossPhase:
	var hp_percent = float(current_hp) / float(max_health)

	# Fases são definidas por threshold de HP
	# Ex: Fase 1 = 100%-66%, Fase 2 = 66%-33%, Fase 3 = 33%-0%
	for phase in phases:
		if hp_percent >= phase.hp_threshold:
			return phase

	# Retornar última fase se não encontrar
	if not phases.is_empty():
		return phases[-1]

	return null

func get_phase_index(current_hp: int) -> int:
	var current_phase = get_current_phase(current_hp)
	if current_phase:
		return phases.find(current_phase)
	return -1
