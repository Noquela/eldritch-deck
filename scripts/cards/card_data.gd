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
@export var is_upgraded: bool = false  # Se a carta foi melhorada

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

## Retorna uma cópia upgraded desta carta
func get_upgraded_copy() -> CardData:
	if is_upgraded:
		return self  # Já está upgraded

	var upgraded = self.duplicate()
	upgraded.is_upgraded = true
	upgraded.card_name = card_name + "+"

	# Aumenta valores baseado no tipo
	if damage > 0:
		upgraded.damage = int(damage * 1.5)  # +50% dano
	if block > 0:
		upgraded.block = int(block * 1.5)  # +50% bloqueio
	if heal > 0:
		upgraded.heal = int(heal * 1.5)  # +50% cura
	if draw_cards > 0:
		upgraded.draw_cards = draw_cards + 1  # +1 carta

	# Rituais ficam mais fortes
	if is_ritual:
		if ritual_damage_per_turn > 0:
			upgraded.ritual_damage_per_turn = int(ritual_damage_per_turn * 1.5)
		if ritual_final_damage > 0:
			upgraded.ritual_final_damage = int(ritual_final_damage * 1.5)

	# Atualiza descrição
	upgraded.description = _get_upgraded_description(upgraded)

	return upgraded

func _get_upgraded_description(card: CardData) -> String:
	var desc = ""
	if card.damage > 0:
		desc += "Causa %d de dano. " % card.damage
	if card.block > 0:
		desc += "Ganha %d de bloqueio. " % card.block
	if card.heal > 0:
		desc += "Cura %d HP. " % card.heal
	if card.draw_cards > 0:
		desc += "Compra %d carta(s). " % card.draw_cards
	if card.apply_enemy_status != "":
		desc += "Aplica %s x%d. " % [card.apply_enemy_status, card.apply_enemy_stacks]
	if card.apply_player_status != "":
		desc += "Ganha %s x%d. " % [card.apply_player_status, card.apply_player_stacks]
	return desc.strip_edges()
