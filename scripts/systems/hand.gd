extends HBoxContainer
class_name Hand

signal card_played(card_data: Resource)
signal hand_discarded(cards: Array[Resource])

@export var card_scene: PackedScene
@export var cards_to_draw: int = 3
@export var card_spacing: float = 20.0

var deck = null
var cards_in_hand: Array = []

func _ready() -> void:
	add_theme_constant_override("separation", int(card_spacing))

func set_deck(new_deck) -> void:
	deck = new_deck

func draw_cards(amount: int = 3) -> void:
	if not deck:
		print("Deck não configurado!")
		return

	for i in range(amount):
		var card_data = deck.draw_card()
		if not card_data:
			break

		var card_instance = card_scene.instantiate()
		card_instance.set_card_data(card_data)
		card_instance.card_played.connect(_on_card_played)

		add_child(card_instance)
		cards_in_hand.append(card_instance)

func _on_card_played(card_data: Resource) -> void:
	card_played.emit(card_data)

func discard_hand() -> void:
	if not deck:
		return

	var discarded_cards: Array[Resource] = []
	for card in cards_in_hand:
		if card.card_data:
			deck.discard_card(card.card_data)
			discarded_cards.append(card.card_data)
		card.queue_free()

	cards_in_hand.clear()
	hand_discarded.emit(discarded_cards)
	print("Mão descartada: %d cartas" % discarded_cards.size())

func clear_hand() -> void:
	for card in cards_in_hand:
		card.queue_free()
	cards_in_hand.clear()

func remove_card(card) -> void:
	if card in cards_in_hand:
		cards_in_hand.erase(card)
		if deck and card.card_data:
			deck.discard_card(card.card_data)
		card.queue_free()
