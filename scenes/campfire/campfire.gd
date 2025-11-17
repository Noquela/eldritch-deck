extends Control

@onready var rest_button: Button = $Panel/VBox/RestButton
@onready var upgrade_button: Button = $Panel/VBox/UpgradeButton
@onready var leave_button: Button = $Panel/VBox/LeaveButton
@onready var title_label: Label = $Panel/VBox/TitleLabel
@onready var hp_label: Label = $Panel/VBox/HPLabel

const HEAL_AMOUNT: int = 30

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

	# TODO: Implementar UI de seleção de carta para upgrade
	# Por enquanto, só mostra mensagem
	var popup_label = Label.new()
	popup_label.text = "🚧 Sistema de upgrade de cartas em desenvolvimento!\nPor enquanto, volte ao mapa."
	popup_label.add_theme_font_size_override("font_size", 24)
	popup_label.position = Vector2(400, 300)
	add_child(popup_label)

	# Desabilitar botões
	rest_button.disabled = true
	upgrade_button.disabled = true

	await get_tree().create_timer(2.0).timeout
	_return_to_map()

func _on_leave_pressed() -> void:
	print("🚪 Saindo da fogueira sem ações...")
	_return_to_map()

func _return_to_map() -> void:
	# AUTOSAVE: Salvar progresso após visitar fogueira
	SaveManager.save_game()

	get_tree().change_scene_to_file("res://scenes/map/map.tscn")
