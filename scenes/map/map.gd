extends Control

@onready var map_container: Control = $ScrollContainer/MapContainer
@onready var act_label: Label = $UI/ActLabel

const MAP_NODE_SCENE = preload("res://scenes/map/map_node.tscn")

var current_act: int = 1
var map_nodes: Array[MapNodeData] = []
var node_instances: Dictionary = {}  # node_id -> MapNode instance

func _ready() -> void:
	_generate_map()

func _generate_map() -> void:
	# Se já existe mapa salvo no GameState, usar ele
	if not GameState.current_map_nodes.is_empty():
		map_nodes = GameState.current_map_nodes
		current_act = GameState.current_act
		print("📍 Mapa restaurado do GameState")
	else:
		# Gerar novo mapa
		map_nodes = MapGenerator.generate_map(current_act)
		GameState.current_map_nodes = map_nodes
		GameState.current_act = current_act
		print("🗺️ Novo mapa gerado")

	# Atualizar label do ato
	act_label.text = "Ato %d - R'lyeh" % current_act

	# Criar visual dos nós
	for node_data in map_nodes:
		var node_instance = MAP_NODE_SCENE.instantiate()
		map_container.add_child(node_instance)

		# Posicionar nó
		node_instance.position = node_data.position + Vector2(1720/2, 100)  # Centralizar

		# Configurar dados
		node_instance.set_node_data(node_data)
		node_instance.node_clicked.connect(_on_node_clicked)

		# Guardar referência
		node_instances[node_data.node_id] = node_instance

	# Desenhar linhas de conexão
	_draw_connections()

func _draw_connections() -> void:
	# Criar um node Line2D para cada conexão
	for node_data in map_nodes:
		if node_data.connected_nodes.is_empty():
			continue

		var start_pos = node_data.position + Vector2(1720/2, 100)

		for connected_id in node_data.connected_nodes:
			var connected_node = _find_node_by_id(connected_id)
			if not connected_node:
				continue

			var end_pos = connected_node.position + Vector2(1720/2, 100)

			var line = Line2D.new()
			line.add_point(start_pos + Vector2(50, 40))  # Centro do botão
			line.add_point(end_pos + Vector2(50, 40))
			line.width = 3
			line.default_color = Color(0.4, 0.4, 0.4, 0.6)
			line.z_index = -1

			map_container.add_child(line)

func _find_node_by_id(node_id: int) -> MapNodeData:
	for node in map_nodes:
		if node.node_id == node_id:
			return node
	return null

func _on_node_clicked(node_data: MapNodeData) -> void:
	print("Nó clicado: %s (ID: %d)" % [node_data.get_type_name(), node_data.node_id])

	# Marcar nó como completo
	node_data.is_completed = true

	# Desbloquear nós conectados
	for connected_id in node_data.connected_nodes:
		var connected_node = _find_node_by_id(connected_id)
		if connected_node:
			connected_node.is_available = true

			# Atualizar visual
			if node_instances.has(connected_id):
				node_instances[connected_id].set_node_data(connected_node)

	# Atualizar visual do nó atual
	if node_instances.has(node_data.node_id):
		node_instances[node_data.node_id].set_node_data(node_data)

	# Salvar estado do mapa no GameState
	GameState.current_map_nodes = map_nodes
	GameState.map_state_changed.emit()

	# Navegar para a cena apropriada
	_navigate_to_node(node_data)

func _navigate_to_node(node_data: MapNodeData) -> void:
	match node_data.node_type:
		MapNodeData.NodeType.COMBAT:
			GameState.is_boss_fight = false
			GameState.current_boss = null
			get_tree().change_scene_to_file("res://scenes/combat/combat.tscn")
		MapNodeData.NodeType.ELITE:
			# TODO: Combate elite (inimigos mais fortes)
			GameState.is_boss_fight = false
			GameState.current_boss = null
			get_tree().change_scene_to_file("res://scenes/combat/combat.tscn")
		MapNodeData.NodeType.SHOP:
			get_tree().change_scene_to_file("res://scenes/shop/shop.tscn")
		MapNodeData.NodeType.CAMPFIRE:
			get_tree().change_scene_to_file("res://scenes/campfire/campfire.tscn")
		MapNodeData.NodeType.BOSS:
			# Preparar boss fight baseado no Act atual
			GameState.is_boss_fight = true
			GameState.current_boss = _get_boss_for_act(GameState.current_act)
			print("🔥 Preparando Boss Fight: %s" % GameState.current_boss.boss_name)
			get_tree().change_scene_to_file("res://scenes/combat/combat.tscn")

func _get_boss_for_act(act: int) -> Resource:
	"""Retorna o boss apropriado para o Act atual"""
	match act:
		1:
			return preload("res://resources/bosses/act1_prophet.tres")
		2:
			return preload("res://resources/bosses/act2_dagon.tres")
		3:
			return preload("res://resources/bosses/act3_cthulhu.tres")
		_:
			# Fallback para Act 1 se algo der errado
			return preload("res://resources/bosses/act1_prophet.tres")
