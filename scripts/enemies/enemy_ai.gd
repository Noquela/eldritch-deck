extends Node
class_name EnemyAI

enum ActionType { ATTACK, DEFEND, SPECIAL }

var actions: Array[Dictionary] = [
	{"type": ActionType.ATTACK, "name": "Ataque Fraco", "damage": 5, "weight": 50},
	{"type": ActionType.ATTACK, "name": "Ataque Forte", "damage": 10, "weight": 30},
	{"type": ActionType.DEFEND, "name": "Defender", "block": 8, "weight": 20},
]

var next_action: Dictionary = {}

func choose_next_action() -> Dictionary:
	# Escolher ação baseada em peso
	var total_weight = 0
	for action in actions:
		total_weight += action.weight

	var roll = randi() % total_weight
	var current_weight = 0

	for action in actions:
		current_weight += action.weight
		if roll < current_weight:
			next_action = action
			return next_action

	next_action = actions[0]
	return next_action

func get_next_action() -> Dictionary:
	return next_action

func get_action_description() -> String:
	if next_action.is_empty():
		return "???"

	match next_action.type:
		ActionType.ATTACK:
			return "Ataque: %d" % next_action.damage
		ActionType.DEFEND:
			return "Defesa: %d" % next_action.block
		_:
			return next_action.name
