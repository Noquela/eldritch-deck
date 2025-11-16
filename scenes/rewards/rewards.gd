extends Control

@export var card_scene: PackedScene

@onready var gold_label: Label = $GoldLabel
@onready var card_choices: HBoxContainer = $CardChoices
@onready var skip_button: Button = $SkipButton
@onready var continue_button: Button = $ContinueButton

var gold_reward: int = 50
var card_options: Array[Resource] = []

# Pool de todas as cartas disponíveis para recompensa
var all_cards: Array[Resource] = []

func _ready() -> void:
	_load_card_pool()
	_setup_rewards()
	skip_button.pressed.connect(_on_skip_pressed)
	continue_button.pressed.connect(_on_continue_pressed)

func _load_card_pool() -> void:
	# Carregar todas as cartas disponíveis
	# Ataques
	all_cards.append(load("res://resources/cards/strike.tres"))
	all_cards.append(load("res://resources/cards/heavy_strike.tres"))
	all_cards.append(load("res://resources/cards/devastating_blow.tres"))
	all_cards.append(load("res://resources/cards/desperate_strike.tres"))

	# Defesa
	all_cards.append(load("res://resources/cards/defend.tres"))
	all_cards.append(load("res://resources/cards/iron_wall.tres"))

	# Skills
	all_cards.append(load("res://resources/cards/bandage.tres"))
	all_cards.append(load("res://resources/cards/insight.tres"))
	all_cards.append(load("res://resources/cards/enfeeble.tres"))
	all_cards.append(load("res://resources/cards/expose.tres"))

	# Powers
	all_cards.append(load("res://resources/cards/offering.tres"))
	all_cards.append(load("res://resources/cards/flex.tres"))

func _setup_rewards() -> void:
	# Dar ouro
	GameState.add_gold(gold_reward)
	gold_label.text = "Ouro ganho: +%d (Total: %d)" % [gold_reward, GameState.player_gold]

	# Gerar 3 opções de carta aleatórias
	card_options.clear()
	var available_cards = all_cards.duplicate()

	for i in range(3):
		if available_cards.is_empty():
			break

		var random_idx = randi() % available_cards.size()
		var chosen_card = available_cards[random_idx]
		card_options.append(chosen_card)
		available_cards.remove_at(random_idx)

	# Criar visual das cartas
	for card_data in card_options:
		var card_instance = card_scene.instantiate()
		card_choices.add_child(card_instance)
		card_instance.set_card_data(card_data)
		# O signal card_clicked já emite card_data, não precisa de .bind()
		card_instance.card_clicked.connect(_on_card_chosen)

func _on_card_chosen(card_data: Resource) -> void:
	# Adicionar carta ao deck
	GameState.add_card_to_deck(card_data)
	print("Carta adicionada ao deck: %s" % card_data.card_name)

	# Esconder escolhas e mostrar botão continuar
	skip_button.visible = false
	continue_button.visible = true

	# Desabilitar cliques nas outras cartas
	for card in card_choices.get_children():
		card.set_process_input(false)

func _on_skip_pressed() -> void:
	print("Recompensa de carta pulada")
	_continue_to_next()

func _on_continue_pressed() -> void:
	_continue_to_next()

func _continue_to_next() -> void:
	# Ir para o mapa após vitória
	get_tree().change_scene_to_file("res://scenes/map/map.tscn")
