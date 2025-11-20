extends Control

## Menu Principal do Eldritch Deck

@onready var new_run_button: Button = $VBoxContainer/NewRunButton
@onready var continue_button: Button = $VBoxContainer/ContinueButton
@onready var settings_button: Button = $VBoxContainer/SettingsButton
@onready var quit_button: Button = $VBoxContainer/QuitButton
@onready var saves_container: VBoxContainer = $SavesPanel/VBoxContainer
@onready var saves_panel: PanelContainer = $SavesPanel

var has_saves: bool = false

func _ready() -> void:
	_connect_signals()
	_check_for_saves()
	saves_panel.visible = false

func _connect_signals() -> void:
	new_run_button.pressed.connect(_on_new_run_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _check_for_saves() -> void:
	# Verifica se existe save no PostgreSQL
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_saves_check_completed)

	var url = "http://localhost:3000/api/saves"
	var error = http_request.request(url)
	if error != OK:
		print("Erro ao verificar saves: ", error)
		continue_button.disabled = true

func _on_saves_check_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		continue_button.disabled = true
		return

	var json = JSON.parse_string(body.get_string_from_utf8())
	if json and json.has("saves") and json.saves.size() > 0:
		has_saves = true
		continue_button.disabled = false
		_populate_saves_list(json.saves)
	else:
		has_saves = false
		continue_button.disabled = true

func _populate_saves_list(saves: Array) -> void:
	# Limpa lista existente
	for child in saves_container.get_children():
		child.queue_free()

	# Adiciona cada save como botão
	for save in saves:
		var save_button = Button.new()
		save_button.text = "%s - Act %d Floor %d (HP: %d/%d)" % [
			save.save_name,
			save.current_act,
			save.current_floor,
			save.current_health,
			save.max_health
		]
		save_button.pressed.connect(_on_save_selected.bind(save.id))
		saves_container.add_child(save_button)

func _on_new_run_pressed() -> void:
	print("Iniciando nova run...")
	GameState.reset_run()
	get_tree().change_scene_to_file("res://scenes/map/map.tscn")

func _on_continue_pressed() -> void:
	if has_saves:
		saves_panel.visible = true

func _on_save_selected(save_id: int) -> void:
	print("Carregando save ID: ", save_id)
	saves_panel.visible = false

	# Carrega o save via API
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_load_completed)

	var url = "http://localhost:3000/api/load/%d" % save_id
	http_request.request(url)

func _on_load_completed(result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		print("Erro ao carregar save")
		return

	var json = JSON.parse_string(body.get_string_from_utf8())
	if json and json.has("success") and json.success:
		# Aplica dados ao GameState
		GameState.player_health = json.data.current_health
		GameState.player_max_health = json.data.max_health
		GameState.gold = json.data.gold
		GameState.current_floor = json.data.current_floor
		GameState.current_act = json.data.current_act

		# Carrega deck
		GameState.player_deck.clear()
		for card_path in json.data.deck:
			var card = load(card_path)
			if card:
				GameState.player_deck.append(card)

		# Carrega artefatos
		GameState.player_artifacts.clear()
		for artifact_path in json.data.artifacts:
			var artifact = load(artifact_path)
			if artifact:
				GameState.player_artifacts.append(artifact)

		print("Save carregado com sucesso!")
		get_tree().change_scene_to_file("res://scenes/map/map.tscn")
	else:
		print("Falha ao carregar save")

func _on_settings_pressed() -> void:
	# TODO: Implementar tela de configurações
	print("Settings - TODO")

func _on_quit_pressed() -> void:
	get_tree().quit()
