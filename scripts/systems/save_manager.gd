extends Node
class_name SaveManager

const API_URL = "http://localhost:3000/api"
const DEFAULT_SAVE_NAME = "save_1"

var http_request: HTTPRequest

func _ready() -> void:
	http_request = HTTPRequest.new()
	add_child(http_request)

# Salvar progresso atual
func save_game(save_name: String = DEFAULT_SAVE_NAME) -> void:
	print("💾 Salvando jogo...")

	# Coletar dados do GameState
	var save_data = {
		"save_name": save_name,
		"player_data": {
			"current_health": GameState.player_current_health,
			"max_health": GameState.player_max_health,
			"gold": GameState.player_gold,
			"current_floor": GameState.current_floor,
			"nodes_cleared": GameState.nodes_cleared,
			"current_act": GameState.current_act
		},
		"deck": [],
		"artifacts": [],
		"map_nodes": []
	}

	# Serializar deck (resource paths)
	for card in GameState.player_deck:
		save_data["deck"].append(card.resource_path)

	# Serializar artifacts (resource paths)
	for artifact in GameState.player_artifacts:
		save_data["artifacts"].append(artifact.resource_path)

	# Serializar map nodes
	for node in GameState.current_map_nodes:
		save_data["map_nodes"].append({
			"node_id": node.node_id,
			"node_type": node.node_type,
			"position_x": node.position.x,
			"position_y": node.position.y,
			"is_available": node.is_available,
			"is_completed": node.is_completed,
			"connected_nodes": JSON.stringify(node.connected_nodes)
		})

	# Fazer POST request
	var json = JSON.stringify(save_data)
	var headers = ["Content-Type: application/json"]

	http_request.request_completed.connect(_on_save_completed)
	var error = http_request.request(API_URL + "/save", headers, HTTPClient.METHOD_POST, json)

	if error != OK:
		print("❌ Erro ao iniciar request de save: %d" % error)

func _on_save_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	http_request.request_completed.disconnect(_on_save_completed)

	if response_code == 200:
		var json_parser = JSON.new()
		var parse_result = json_parser.parse(body.get_string_from_utf8())

		if parse_result == OK:
			var response = json_parser.data
			if response.get("success", false):
				print("✅ Jogo salvo com sucesso! (ID: %d)" % response.get("save_id", 0))
			else:
				print("❌ Erro ao salvar: %s" % response.get("error", "Desconhecido"))
		else:
			print("❌ Erro ao parsear resposta do save")
	else:
		print("❌ Erro HTTP ao salvar: %d" % response_code)

# Carregar progresso
func load_game(save_name: String = DEFAULT_SAVE_NAME) -> void:
	print("📂 Carregando jogo...")

	http_request.request_completed.connect(_on_load_completed)
	var error = http_request.request(API_URL + "/load/" + save_name)

	if error != OK:
		print("❌ Erro ao iniciar request de load: %d" % error)

func _on_load_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	http_request.request_completed.disconnect(_on_load_completed)

	if response_code == 200:
		var json_parser = JSON.new()
		var parse_result = json_parser.parse(body.get_string_from_utf8())

		if parse_result == OK:
			var response = json_parser.data

			if response.get("success", false):
				var data = response.get("data", {})
				_apply_loaded_data(data)
				print("✅ Jogo carregado com sucesso!")
			else:
				print("❌ Save não encontrado: %s" % response.get("error", ""))
		else:
			print("❌ Erro ao parsear resposta do load")
	else:
		print("❌ Erro HTTP ao carregar: %d" % response_code)

func _apply_loaded_data(data: Dictionary) -> void:
	var player_data = data.get("player_data", {})

	# Restaurar stats do jogador
	GameState.player_current_health = player_data.get("current_health", 100)
	GameState.player_max_health = player_data.get("max_health", 100)
	GameState.player_gold = player_data.get("gold", 0)
	GameState.current_floor = player_data.get("current_floor", 1)
	GameState.nodes_cleared = player_data.get("nodes_cleared", 0)
	GameState.current_act = player_data.get("current_act", 1)

	# Restaurar deck
	GameState.player_deck.clear()
	for card_path in data.get("deck", []):
		var card = load(card_path)
		if card:
			GameState.player_deck.append(card)

	# Restaurar artifacts
	GameState.player_artifacts.clear()
	for artifact_path in data.get("artifacts", []):
		var artifact = load(artifact_path)
		if artifact:
			GameState.player_artifacts.append(artifact)

	# Restaurar map nodes
	GameState.current_map_nodes.clear()
	for node_data in data.get("map_nodes", []):
		var map_node = MapNodeData.new()
		map_node.node_id = node_data.get("node_id", 0)
		map_node.node_type = node_data.get("node_type", 0)
		map_node.position = Vector2(node_data.get("position_x", 0), node_data.get("position_y", 0))
		map_node.is_available = node_data.get("is_available", false)
		map_node.is_completed = node_data.get("is_completed", false)

		# Parsear connected_nodes JSON
		var connected_str = node_data.get("connected_nodes", "[]")
		var json_parser = JSON.new()
		if json_parser.parse(connected_str) == OK:
			map_node.connected_nodes = json_parser.data

		GameState.current_map_nodes.append(map_node)

	# Emitir sinais
	GameState.health_changed.emit(GameState.player_current_health, GameState.player_max_health)
	GameState.gold_changed.emit(GameState.player_gold)
	GameState.deck_changed.emit()
	GameState.map_state_changed.emit()
