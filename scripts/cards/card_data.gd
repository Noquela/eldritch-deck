extends Resource
class_name CardData

enum CardType {
	ATTACK,   # Cartas de dano
	SKILL,    # Cartas de defesa/utilidade
	POWER     # Cartas de buff/passiva
}

@export var card_name: String = ""
@export var card_type: CardType = CardType.ATTACK
@export var energy_cost: int = 1
@export var description: String = ""
@export var corruption_cost: int = 0

# Efeitos básicos da carta
@export var damage: int = 0
@export var block: int = 0
@export var draw_cards: int = 0  # Comprar cartas
@export var heal: int = 0  # Curar vida
@export var energy_gain: int = 0  # Ganhar energia extra

# Efeitos especiais (para Skills e Powers)
@export var effect_name: String = ""  # Nome do efeito único
@export var effect_value: int = 0  # Valor do efeito
@export var is_exhaust: bool = false  # Carta some após jogar

func _to_string() -> String:
	return "%s (Custo: %d energia, %d corrupção)" % [card_name, energy_cost, corruption_cost]
