extends Resource
class_name CardData

enum CardType {
	ATTACK,   # Cartas de dano
	SKILL,    # Cartas de defesa/utilidade
	POWER,    # Cartas de buff/passiva
	RITUAL    # NOVO: Cartas de múltiplos turnos (Lovecraftiano!)
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

# RITUAIS: Sistema de múltiplos turnos (mecânica Lovecraftiana!)
@export var is_ritual: bool = false  # Se é um ritual
@export var ritual_turns: int = 0  # Turnos necessários para completar (ex: 3)
@export var ritual_damage_per_turn: int = 0  # Dano por turno durante ritual
@export var ritual_final_damage: int = 0  # Dano ao completar ritual
@export var ritual_final_effect: String = ""  # Efeito especial ao completar

# Status effects (buffs/debuffs)
@export var apply_player_status: String = ""  # Status effect para jogador (ex: "STRENGTH")
@export var apply_player_stacks: int = 0  # Quantidade de stacks para jogador
@export var apply_player_duration: int = -1  # Duração para jogador (-1 = permanente)
@export var apply_enemy_status: String = ""  # Status effect para inimigo (ex: "WEAKNESS")
@export var apply_enemy_stacks: int = 0  # Quantidade de stacks para inimigo
@export var apply_enemy_duration: int = -1  # Duração para inimigo (-1 = permanente)

func _to_string() -> String:
	return "%s (Custo: %d energia, %d corrupção)" % [card_name, energy_cost, corruption_cost]
