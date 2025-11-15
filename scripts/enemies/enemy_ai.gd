extends Node
class_name EnemyAI

enum ActionType { ATTACK, DEFEND, BUFF }

var enemy_data: Resource = null
var actions: Array[Dictionary] = []
var next_action: Dictionary = {}

func set_enemy_data(data: Resource) -> void:
	enemy_data = data
	_build_actions()

func _build_actions() -> void:
	if not enemy_data:
		return

	actions.clear()

	# Ação de ataque
	actions.append({
		"type": ActionType.ATTACK,
		"name": "Ataque",
		"damage": randi_range(enemy_data.min_damage, enemy_data.max_damage),
		"weight": enemy_data.attack_weight
	})

	# Ação de defesa
	actions.append({
		"type": ActionType.DEFEND,
		"name": "Defender",
		"block": enemy_data.block_amount,
		"weight": enemy_data.defend_weight
	})

	# Ação de buff (se disponível)
	if enemy_data.can_apply_strength:
		actions.append({
			"type": ActionType.BUFF,
			"name": "Fortalecer",
			"strength": enemy_data.strength_amount,
			"weight": enemy_data.buff_weight
		})

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
		ActionType.BUFF:
			return "Força +%d" % next_action.strength
		_:
			return next_action.name
