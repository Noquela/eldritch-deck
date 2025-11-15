extends Node
class_name MapGenerator

const FLOORS_PER_ACT = 15  # 15 andares por ato
const PATHS_PER_FLOOR = 3  # 3 caminhos possíveis por andar
const HORIZONTAL_SPACING = 400
const VERTICAL_SPACING = 120

# Gera um mapa completo para o ato
static func generate_map(act: int = 1) -> Array[MapNodeData]:
	var nodes: Array[MapNodeData] = []
	var node_id = 0

	# Criar nós para cada andar
	for floor in range(FLOORS_PER_ACT):
		var floor_nodes = _generate_floor(floor, node_id)
		nodes.append_array(floor_nodes)
		node_id += floor_nodes.size()

	# Conectar nós entre andares
	_connect_floors(nodes)

	# Marcar primeiro andar como disponível
	for node in nodes:
		if node.position.y == 0:
			node.is_available = true

	return nodes

static func _generate_floor(floor: int, start_id: int) -> Array[MapNodeData]:
	var floor_nodes: Array[MapNodeData] = []

	# Determinar tipo de andar
	var node_type: MapNodeData.NodeType

	if floor == 0:
		# Primeiro andar: sempre combate
		node_type = MapNodeData.NodeType.COMBAT
	elif floor == FLOORS_PER_ACT - 1:
		# Último andar: sempre boss
		node_type = MapNodeData.NodeType.BOSS
	elif floor == 7:
		# Meio do ato: sempre fogueira
		node_type = MapNodeData.NodeType.CAMPFIRE
	else:
		# Outros andares: mix de tipos
		node_type = _random_node_type(floor)

	# Criar nós para este andar
	var paths_count = 1 if node_type == MapNodeData.NodeType.BOSS else PATHS_PER_FLOOR

	for path in range(paths_count):
		var node = MapNodeData.new()
		node.node_id = start_id + path
		node.node_type = node_type

		# Posicionar nó
		var x_offset = (path - paths_count / 2.0 + 0.5) * HORIZONTAL_SPACING
		node.position = Vector2(x_offset, floor * VERTICAL_SPACING)

		floor_nodes.append(node)

	return floor_nodes

static func _random_node_type(floor: int) -> MapNodeData.NodeType:
	var rand = randf()

	# Mais combates no início, mais variedade depois
	if floor < 5:
		if rand < 0.7:
			return MapNodeData.NodeType.COMBAT
		elif rand < 0.85:
			return MapNodeData.NodeType.SHOP
		else:
			return MapNodeData.NodeType.ELITE
	else:
		if rand < 0.5:
			return MapNodeData.NodeType.COMBAT
		elif rand < 0.7:
			return MapNodeData.NodeType.ELITE
		elif rand < 0.85:
			return MapNodeData.NodeType.SHOP
		else:
			return MapNodeData.NodeType.CAMPFIRE

static func _connect_floors(nodes: Array[MapNodeData]) -> void:
	# Agrupar nós por andar (posição Y)
	var floors: Dictionary = {}

	for node in nodes:
		var floor_y = node.position.y
		if not floors.has(floor_y):
			floors[floor_y] = []
		floors[floor_y].append(node)

	# Ordenar floors
	var floor_keys = floors.keys()
	floor_keys.sort()

	# Conectar cada andar com o próximo
	for i in range(floor_keys.size() - 1):
		var current_floor = floors[floor_keys[i]]
		var next_floor = floors[floor_keys[i + 1]]

		# Cada nó conecta com 1-2 nós do próximo andar
		for current_node in current_floor:
			var connections = 0
			var max_connections = 2 if next_floor.size() > 1 else 1

			# Conectar com nós próximos
			for next_node in next_floor:
				var distance = current_node.position.distance_to(next_node.position)

				if distance < HORIZONTAL_SPACING * 1.5 and connections < max_connections:
					current_node.connected_nodes.append(next_node.node_id)
					connections += 1

			# Garantir que todo nó tem pelo menos 1 conexão
			if current_node.connected_nodes.is_empty() and not next_floor.is_empty():
				current_node.connected_nodes.append(next_floor[0].node_id)
