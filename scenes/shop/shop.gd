extends Control

@onready var gold_label: Label = $GoldLabel
@onready var cards_container: HBoxContainer = $CardsSection/CardsContainer
@onready var artifacts_container: VBoxContainer = $ArtifactsSection/ArtifactsContainer
@onready var remove_button: Button = $RemoveSection/RemoveButton
@onready var leave_button: Button = $LeaveButton

const CARD_SCENE = preload("res://scenes/cards/card.tscn")
const CARD_PRICE = 50
const ARTIFACT_PRICE = 75
const REMOVE_PRICE = 50

# Pool de cartas disponíveis na loja
var available_cards: Array[Resource] = [
	preload("res://resources/cards/strike.tres"),
	preload("res://resources/cards/heavy_strike.tres"),
	preload("res://resources/cards/devastating_blow.tres"),
	preload("res://resources/cards/defend.tres"),
	preload("res://resources/cards/iron_wall.tres"),
	preload("res://resources/cards/power_up.tres"),
	preload("res://resources/cards/weaken.tres"),
	preload("res://resources/cards/draw_cards.tres"),
	preload("res://resources/cards/heal.tres"),
	preload("res://resources/cards/blood_sacrifice.tres"),
	preload("res://resources/cards/despair.tres"),
	preload("res://resources/cards/curse.tres")
]

# Pool de artefatos disponíveis na loja
var available_artifacts: Array[Resource] = [
	preload("res://resources/artifacts/necronomicon_page.tres"),
	preload("res://resources/artifacts/elder_sign.tres"),
	preload("res://resources/artifacts/shining_trapezohedron.tres"),
	preload("res://resources/artifacts/cthulhu_idol.tres"),
	preload("res://resources/artifacts/cursed_dagger.tres")
]

var card_offerings: Array[Resource] = []
var artifact_offerings: Array[Resource] = []

func _ready() -> void:
	# Conectar botões
	remove_button.pressed.connect(_on_remove_button_pressed)
	leave_button.pressed.connect(_on_leave_button_pressed)

	# Gerar ofertas da loja
	_generate_shop_offerings()

	# Atualizar UI
	_update_gold_display()

func _generate_shop_offerings() -> void:
	# Escolher 5 cartas aleatórias
	var cards_pool = available_cards.duplicate()
	for i in range(5):
		if cards_pool.is_empty():
			break
		var random_idx = randi() % cards_pool.size()
		var chosen_card = cards_pool[random_idx]
		card_offerings.append(chosen_card)
		cards_pool.remove_at(random_idx)

	# Escolher 2 artefatos aleatórios
	var artifacts_pool = available_artifacts.duplicate()
	for i in range(2):
		if artifacts_pool.is_empty():
			break
		var random_idx = randi() % artifacts_pool.size()
		var chosen_artifact = artifacts_pool[random_idx]
		artifact_offerings.append(chosen_artifact)
		artifacts_pool.remove_at(random_idx)

	# Criar UI das cartas
	for card_data in card_offerings:
		var card_instance = CARD_SCENE.instantiate()
		cards_container.add_child(card_instance)
		card_instance.set_card_data(card_data)
		card_instance.card_clicked.connect(_on_card_clicked.bind(card_data))

		# Adicionar label de preço
		var price_label = Label.new()
		price_label.text = "💰 %d" % CARD_PRICE
		price_label.add_theme_font_size_override("font_size", 20)
		price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		card_instance.add_child(price_label)
		price_label.position = Vector2(0, 200)

	# Criar UI dos artefatos
	for artifact_data in artifact_offerings:
		var artifact_panel = Panel.new()
		artifact_panel.custom_minimum_size = Vector2(400, 80)
		artifacts_container.add_child(artifact_panel)

		var vbox = VBoxContainer.new()
		artifact_panel.add_child(vbox)
		vbox.position = Vector2(10, 10)

		var name_label = Label.new()
		name_label.text = "🔮 %s" % artifact_data.artifact_name
		name_label.add_theme_font_size_override("font_size", 18)
		name_label.modulate = artifact_data.get_rarity_color()
		vbox.add_child(name_label)

		var desc_label = Label.new()
		desc_label.text = artifact_data.description
		desc_label.add_theme_font_size_override("font_size", 14)
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		desc_label.custom_minimum_size = Vector2(380, 0)
		vbox.add_child(desc_label)

		var buy_button = Button.new()
		buy_button.text = "Comprar - 💰 %d" % ARTIFACT_PRICE
		buy_button.pressed.connect(_on_artifact_clicked.bind(artifact_data, artifact_panel))
		vbox.add_child(buy_button)

func _update_gold_display() -> void:
	gold_label.text = "💰 %d" % GameState.gold

func _on_card_clicked(card_data: Resource) -> void:
	if GameState.gold < CARD_PRICE:
		print("❌ Ouro insuficiente! Precisa de %d" % CARD_PRICE)
		return

	# Comprar carta
	GameState.gold -= CARD_PRICE
	GameState.add_card_to_deck(card_data)
	print("✅ Comprou carta: %s por %d ouro" % [card_data.card_name, CARD_PRICE])

	_update_gold_display()

func _on_artifact_clicked(artifact_data: Resource, panel: Panel) -> void:
	if GameState.gold < ARTIFACT_PRICE:
		print("❌ Ouro insuficiente! Precisa de %d" % ARTIFACT_PRICE)
		return

	# Comprar artefato
	GameState.gold -= ARTIFACT_PRICE
	GameState.add_artifact(artifact_data)
	print("✅ Comprou artefato: %s por %d ouro" % [artifact_data.artifact_name, ARTIFACT_PRICE])

	# Remover da loja
	panel.queue_free()
	artifact_offerings.erase(artifact_data)

	_update_gold_display()

func _on_remove_button_pressed() -> void:
	if GameState.gold < REMOVE_PRICE:
		print("❌ Ouro insuficiente! Precisa de %d" % REMOVE_PRICE)
		return

	# TODO: Implementar seleção de carta para remover
	print("⚠ Remoção de carta ainda não implementada!")

func _on_leave_button_pressed() -> void:
	# Voltar ao mapa
	get_tree().change_scene_to_file("res://scenes/map/map.tscn")
