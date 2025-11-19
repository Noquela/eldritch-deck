extends Control

signal node_clicked(node_data: MapNodeData)

@onready var button: Button = $Button
@onready var icon_label: Label = $Button/IconLabel
@onready var type_label: Label = $Button/TypeLabel

var node_data: MapNodeData

func _ready() -> void:
	button.pressed.connect(_on_button_pressed)

func set_node_data(data: MapNodeData) -> void:
	node_data = data
	_update_visuals()

func _update_visuals() -> void:
	if not node_data:
		return

	# Atualizar cor do botão
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = node_data.get_type_color()
	style_box.border_width_left = 4
	style_box.border_width_right = 4
	style_box.border_width_top = 4
	style_box.border_width_bottom = 4
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8

	if node_data.is_completed:
		style_box.bg_color = Color(0.3, 0.3, 0.3)
		style_box.border_color = Color(0.5, 0.5, 0.5)
	elif node_data.is_available:
		style_box.border_color = Color(1, 1, 0.5)
	else:
		style_box.border_color = Color(0.2, 0.2, 0.2)

	button.add_theme_stylebox_override("normal", style_box)
	button.add_theme_stylebox_override("hover", style_box)
	button.add_theme_stylebox_override("pressed", style_box)

	# Atualizar ícone
	var icon = _get_node_icon()
	icon_label.text = icon

	# Atualizar label de tipo
	type_label.text = node_data.get_type_name()

	# Desabilitar se não disponível
	button.disabled = not node_data.is_available or node_data.is_completed

func _get_node_icon() -> String:
	match node_data.node_type:
		MapNodeData.NodeType.COMBAT:
			return "⚔"
		MapNodeData.NodeType.ELITE:
			return "☠"
		MapNodeData.NodeType.SHOP:
			return "$"
		MapNodeData.NodeType.CAMPFIRE:
			return "🔥"
		MapNodeData.NodeType.BOSS:
			return "👹"
		MapNodeData.NodeType.UNKNOWN:
			return "?"
	return "?"

func _on_button_pressed() -> void:
	if node_data and node_data.is_available and not node_data.is_completed:
		node_clicked.emit(node_data)
