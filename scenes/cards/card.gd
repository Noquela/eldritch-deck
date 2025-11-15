extends Control
class_name Card

signal card_played(card_data: Resource)

@export var card_data: Resource

@onready var card_name_label: Label = $CardName
@onready var energy_cost_label: Label = $EnergyCost
@onready var description_label: Label = $Description
@onready var background: ColorRect = $Background

func _ready() -> void:
	if card_data:
		update_display()

	# Permitir cliques na carta
	mouse_filter = Control.MOUSE_FILTER_STOP

func set_card_data(data: Resource) -> void:
	card_data = data
	if is_node_ready():
		update_display()

func update_display() -> void:
	card_name_label.text = card_data.card_name
	energy_cost_label.text = str(card_data.energy_cost)
	description_label.text = card_data.description

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			play_card()

func play_card() -> void:
	card_played.emit(card_data)
	queue_free()
