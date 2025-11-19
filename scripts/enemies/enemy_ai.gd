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

# Métodos para atualizar stats durante boss phase transitions
func update_attack_stats(new_min_damage: int, new_max_damage: int, new_block_amount: int) -> void:
	"""Atualiza os valores de dano e bloqueio das ações"""
	if not enemy_data:
		return

	enemy_data.min_damage = new_min_damage
	enemy_data.max_damage = new_max_damage
	enemy_data.block_amount = new_block_amount

	# Reconstruir ações com novos valores
	_build_actions()

func update_ai_weights(new_attack_weight: int, new_defend_weight: int, new_buff_weight: int) -> void:
	"""Atualiza os pesos de decisão da IA"""
	if not enemy_data:
		return

	enemy_data.attack_weight = new_attack_weight
	enemy_data.defend_weight = new_defend_weight
	enemy_data.buff_weight = new_buff_weight

	# Reconstruir ações com novos pesos
	_build_actions()

func update_special_abilities(abilities: Dictionary) -> void:
	"""Atualiza as habilidades especiais do boss"""
	if not enemy_data:
		return

	if abilities.has("can_apply_strength"):
		enemy_data.can_apply_strength = abilities.can_apply_strength
	if abilities.has("strength_amount"):
		enemy_data.strength_amount = abilities.strength_amount

	# Reconstruir ações para incluir novas habilidades
	_build_actions()
