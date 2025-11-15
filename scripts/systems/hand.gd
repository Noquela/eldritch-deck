extends HBoxContainer
class_name Hand

@export var card_scene: PackedScene
@export var cards_to_draw: int = 3
@export var card_spacing: float = 20.0

var card_pool: Array[Resource] = []
var cards_in_hand: Array = []

func _ready() -> void:
	add_theme_constant_override("separation", int(card_spacing))

func set_card_pool(pool: Array[Resource]) -> void:
	card_pool = pool

func draw_cards(amount: int = 3) -> void:
	clear_hand()

	for i in range(amount):
		if card_pool.is_empty():
			break

		var random_index = randi() % card_pool.size()
		var card_data = card_pool[random_index]

		var card_instance = card_scene.instantiate()
		card_instance.set_card_data(card_data)

		add_child(card_instance)
		cards_in_hand.append(card_instance)

func clear_hand() -> void:
	for card in cards_in_hand:
		card.queue_free()
	cards_in_hand.clear()

func remove_card(card) -> void:
	if card in cards_in_hand:
		cards_in_hand.erase(card)
		card.queue_free()
