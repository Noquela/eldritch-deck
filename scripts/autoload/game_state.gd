extends Node

# Singleton que mantém estado do jogo entre cenas

# Dados do jogador
var player_max_health: int = 100
var player_current_health: int = 100
var player_gold: int = 100  # Começar com 100 de ouro para testar loja
var player_deck: Array[Resource] = []
var player_artifacts: Array[Resource] = []

# Alias para compatibilidade
var gold: int:
	get: return player_gold
	set(value): player_gold = value

# Progresso no mapa
var current_floor: int = 1
var nodes_cleared: int = 0
var current_map_nodes: Array[MapNodeData] = []  # Estado atual do mapa
var current_act: int = 1

signal health_changed(current: int, maximum: int)
signal gold_changed(amount: int)
signal deck_changed
signal map_state_changed

func _ready() -> void:
	_initialize_starting_deck()

func _initialize_starting_deck() -> void:
	# Deck inicial (mesmo do combat.gd)
	player_deck.clear()

	# Ataques: 5x Strike, 2x Heavy Strike, 1x Devastating Blow, 1x Desperate Strike
	for i in range(5):
		player_deck.append(load("res://resources/cards/strike.tres"))
	for i in range(2):
		player_deck.append(load("res://resources/cards/heavy_strike.tres"))
	player_deck.append(load("res://resources/cards/devastating_blow.tres"))
	player_deck.append(load("res://resources/cards/desperate_strike.tres"))

	# Defesa: 3x Defend, 1x Iron Wall
	for i in range(3):
		player_deck.append(load("res://resources/cards/defend.tres"))
	player_deck.append(load("res://resources/cards/iron_wall.tres"))

	# Skills: 1x Bandage, 1x Insight, 1x Enfeeble, 1x Expose
	player_deck.append(load("res://resources/cards/bandage.tres"))
	player_deck.append(load("res://resources/cards/insight.tres"))
	player_deck.append(load("res://resources/cards/enfeeble.tres"))
	player_deck.append(load("res://resources/cards/expose.tres"))

	# Powers: 1x Offering, 1x Flex
	player_deck.append(load("res://resources/cards/offering.tres"))
	player_deck.append(load("res://resources/cards/flex.tres"))

	# RITUAIS LOVECRAFTIANOS: 1x Invocar Yog-Sothoth
	player_deck.append(load("res://resources/cards/summon_yog_sothoth.tres"))

	deck_changed.emit()

func add_card_to_deck(card: Resource) -> void:
	player_deck.append(card)
	deck_changed.emit()

func remove_card_from_deck(card: Resource) -> void:
	var idx = player_deck.find(card)
	if idx >= 0:
		player_deck.remove_at(idx)
		deck_changed.emit()

func add_artifact(artifact: Resource) -> void:
	player_artifacts.append(artifact)
	print("🔮 Artefato adicionado à coleção: %s" % artifact.artifact_name)

func add_gold(amount: int) -> void:
	player_gold += amount
	gold_changed.emit(player_gold)

func spend_gold(amount: int) -> bool:
	if player_gold >= amount:
		player_gold -= amount
		gold_changed.emit(player_gold)
		return true
	return false

func take_damage(amount: int) -> void:
	player_current_health = max(0, player_current_health - amount)
	health_changed.emit(player_current_health, player_max_health)

func heal(amount: int) -> void:
	player_current_health = min(player_max_health, player_current_health + amount)
	health_changed.emit(player_current_health, player_max_health)

func reset_run() -> void:
	player_current_health = player_max_health
	player_gold = 0
	current_floor = 1
	nodes_cleared = 0
	_initialize_starting_deck()
	health_changed.emit(player_current_health, player_max_health)
	gold_changed.emit(player_gold)
