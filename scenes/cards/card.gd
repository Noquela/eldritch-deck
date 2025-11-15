extends Control
class_name Card

@export var card_data: Resource

@onready var card_name_label: Label = $CardName
@onready var energy_cost_label: Label = $EnergyCost
@onready var description_label: Label = $Description
@onready var background: ColorRect = $Background

func _ready() -> void:
	if card_data:
		update_display()

func set_card_data(data: Resource) -> void:
	card_data = data
	if is_node_ready():
		update_display()

func update_display() -> void:
	card_name_label.text = card_data.card_name
	energy_cost_label.text = str(card_data.energy_cost)
	description_label.text = card_data.description
