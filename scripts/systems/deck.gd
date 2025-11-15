extends Node
class_name Deck

signal deck_shuffled
signal card_drawn(card_data: Resource)
signal deck_empty

var draw_pile: Array[Resource] = []
var discard_pile: Array[Resource] = []
var initial_cards: Array[Resource] = []

func initialize(cards: Array[Resource]) -> void:
	initial_cards = cards.duplicate()
	reset_deck()

func reset_deck() -> void:
	draw_pile.clear()
	discard_pile.clear()
	draw_pile = initial_cards.duplicate()
	shuffle_deck()

func shuffle_deck() -> void:
	draw_pile.shuffle()
	deck_shuffled.emit()
	print("Deck embaralhado! Cartas no deck: %d" % draw_pile.size())

func draw_card() -> Resource:
	# Se o deck acabou, embaralhar descarte
	if draw_pile.is_empty():
		if discard_pile.is_empty():
			deck_empty.emit()
			print("Deck e descarte vazios!")
			return null

		print("Deck vazio! Embaralhando descarte...")
		draw_pile = discard_pile.duplicate()
		discard_pile.clear()
		shuffle_deck()

	var card = draw_pile.pop_front()
	card_drawn.emit(card)
	return card

func discard_card(card_data: Resource) -> void:
	discard_pile.append(card_data)

func get_draw_pile_count() -> int:
	return draw_pile.size()

func get_discard_pile_count() -> int:
	return discard_pile.size()
