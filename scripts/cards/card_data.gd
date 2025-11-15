extends Resource
class_name CardData

enum CardType {
	ATTACK,
	SKILL,
	POWER
}

@export var card_name: String = ""
@export var card_type: CardType = CardType.ATTACK
@export var energy_cost: int = 1
@export var description: String = ""
@export var corruption_cost: int = 0

# Efeitos da carta
@export var damage: int = 0
@export var block: int = 0

func _to_string() -> String:
	return "%s (Custo: %d energia, %d corrupção)" % [card_name, energy_cost, corruption_cost]
