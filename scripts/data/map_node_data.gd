extends Resource
class_name MapNodeData

enum NodeType {
	COMBAT,
	ELITE,
	SHOP,
	CAMPFIRE,
	BOSS,
	UNKNOWN
}

@export var node_type: NodeType = NodeType.COMBAT
@export var node_id: int = 0
@export var position: Vector2 = Vector2.ZERO
@export var connected_nodes: Array[int] = []
@export var is_completed: bool = false
@export var is_available: bool = false

func get_type_name() -> String:
	match node_type:
		NodeType.COMBAT:
			return "Combate"
		NodeType.ELITE:
			return "Elite"
		NodeType.SHOP:
			return "Loja"
		NodeType.CAMPFIRE:
			return "Fogueira"
		NodeType.BOSS:
			return "Boss"
		NodeType.UNKNOWN:
			return "???"
	return "Desconhecido"

func get_type_color() -> Color:
	match node_type:
		NodeType.COMBAT:
			return Color(0.8, 0.3, 0.3)  # Vermelho
		NodeType.ELITE:
			return Color(0.9, 0.5, 0.2)  # Laranja
		NodeType.SHOP:
			return Color(0.3, 0.8, 0.3)  # Verde
		NodeType.CAMPFIRE:
			return Color(0.4, 0.6, 0.9)  # Azul
		NodeType.BOSS:
			return Color(0.7, 0.2, 0.7)  # Roxo
		NodeType.UNKNOWN:
			return Color(0.5, 0.5, 0.5)  # Cinza
	return Color.WHITE
