extends Control

@onready var rest_button: Button = $Panel/VBox/RestButton
@onready var upgrade_button: Button = $Panel/VBox/UpgradeButton
@onready var leave_button: Button = $Panel/VBox/LeaveButton
@onready var title_label: Label = $Panel/VBox/TitleLabel
@onready var hp_label: Label = $Panel/VBox/HPLabel

const HEAL_AMOUNT: int = 30

# UI de seleção de carta para upgrade
var card_selection_panel: PanelContainer = null
var selected_card_index: int = -1

func _ready() -> void:
	# Conectar botões
	rest_button.pressed.connect(_on_rest_pressed)
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	leave_button.pressed.connect(_on_leave_pressed)

	# Atualizar UI
	_update_ui()

	# Conectar ao sinal de mudança de vida
	GameState.health_changed.connect(_on_health_changed)

func _update_ui() -> void:
	hp_label.text = "❤️ HP: %d / %d" % [GameState.player_current_health, GameState.player_max_health]

	# Desabilitar descanso se já está com HP cheio
	if GameState.player_current_health >= GameState.player_max_health:
		rest_button.disabled = true
		rest_button.text = "Descansar (HP Cheio)"
	else:
		rest_button.disabled = false
		rest_button.text = "Descansar (+%d HP)" % HEAL_AMOUNT

	# Desabilitar upgrade se não tem cartas
	if GameState.player_deck.is_empty():
		upgrade_button.disabled = true
		upgrade_button.text = "Melhorar Carta (Sem Cartas)"
	else:
		upgrade_button.disabled = false
		upgrade_button.text = "Melhorar Carta"

func _on_health_changed(current: int, maximum: int) -> void:
	_update_ui()

func _on_rest_pressed() -> void:
	print("🔥 Descansando na fogueira...")
	GameState.heal(HEAL_AMOUNT)

	# Feedback visual
	var tween = create_tween()
	tween.tween_property(hp_label, "modulate", Color.GREEN, 0.3)
	tween.tween_property(hp_label, "modulate", Color.WHITE, 0.3)

	# Desabilitar botão após usar
	rest_button.disabled = true
	upgrade_button.disabled = true

	# Esperar um pouco e voltar ao mapa
	await get_tree().create_timer(1.5).timeout
	_return_to_map()

func _on_upgrade_pressed() -> void:
	print("⚡ Abrindo menu de upgrade de cartas...")
	_show_card_selection()

func _show_card_selection() -> void:
	# Criar painel de seleção
	card_selection_panel = PanelContainer.new()
	card_selection_panel.set_anchors_preset(Control.PRESET_CENTER)
	card_selection_panel.custom_minimum_size = Vector2(800, 500)
	card_selection_panel.position = Vector2(-400, -250)
	add_child(card_selection_panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	card_selection_panel.add_child(vbox)

	# Título
	var title = Label.new()
	title.text = "⚡ Selecione uma carta para melhorar"
	title.add_theme_font_size_override("font_size", 24)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	# ScrollContainer para as cartas
	var scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(780, 350)
	vbox.add_child(scroll)

	var grid = GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 10)
	scroll.add_child(grid)

	# Mostrar cartas do deck que podem ser upgraded
	for i in range(GameState.player_deck.size()):
		var card = GameState.player_deck[i]
		if card.is_upgraded:
			continue  # Pular cartas já upgraded

		var card_button = Button.new()
		card_button.custom_minimum_size = Vector2(180, 100)

		# Mostrar preview do upgrade
		var upgraded = card.get_upgraded_copy()
		var preview_text = "%s\n→ %s\n" % [card.card_name, upgraded.card_name]
		if card.damage > 0:
			preview_text += "Dano: %d → %d\n" % [card.damage, upgraded.damage]
		if card.block > 0:
			preview_text += "Bloqueio: %d → %d\n" % [card.block, upgraded.block]
		if card.heal > 0:
			preview_text += "Cura: %d → %d" % [card.heal, upgraded.heal]

		card_button.text = preview_text
		card_button.pressed.connect(_on_card_selected.bind(i))
		grid.add_child(card_button)

	# Botão cancelar
	var cancel_button = Button.new()
	cancel_button.text = "Cancelar"
	cancel_button.custom_minimum_size = Vector2(200, 40)
	cancel_button.pressed.connect(_on_cancel_upgrade)
	vbox.add_child(cancel_button)

func _on_card_selected(index: int) -> void:
	var card = GameState.player_deck[index]
	var upgraded_card = card.get_upgraded_copy()

	# Substituir carta no deck
	GameState.player_deck[index] = upgraded_card
	print("⚡ Carta melhorada: %s → %s" % [card.card_name, upgraded_card.card_name])

	# Fechar painel
	if card_selection_panel:
		card_selection_panel.queue_free()
		card_selection_panel = null

	# Desabilitar botões
	rest_button.disabled = true
	upgrade_button.disabled = true

	# Feedback
	var feedback = Label.new()
	feedback.text = "✨ %s melhorada!" % upgraded_card.card_name
	feedback.add_theme_font_size_override("font_size", 28)
	feedback.set_anchors_preset(Control.PRESET_CENTER)
	feedback.position = Vector2(-150, -50)
	add_child(feedback)

	await get_tree().create_timer(1.5).timeout
	_return_to_map()

func _on_cancel_upgrade() -> void:
	if card_selection_panel:
		card_selection_panel.queue_free()
		card_selection_panel = null

func _on_leave_pressed() -> void:
	print("🚪 Saindo da fogueira sem ações...")
	_return_to_map()

func _return_to_map() -> void:
	# AUTOSAVE: Salvar progresso após visitar fogueira
	SaveManager.save_game()

	get_tree().change_scene_to_file("res://scenes/map/map.tscn")
