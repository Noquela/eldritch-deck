extends Resource
class_name ArtifactData

## Resource para artefatos/relíquias Lovecraftianas
## Artefatos fornecem efeitos passivos permanentes durante a run

enum ArtifactRarity {
	COMMON,
	UNCOMMON,
	RARE,
	BOSS,
	CURSED  # Artefatos amaldiçoados: poderosos mas com custo
}

enum EffectTrigger {
	ON_COMBAT_START,      # Início do combate
	ON_TURN_START,        # Início do turno do jogador
	ON_TURN_END,          # Fim do turno do jogador
	ON_CARD_PLAYED,       # Ao jogar carta
	ON_DAMAGE_DEALT,      # Ao causar dano
	ON_DAMAGE_TAKEN,      # Ao receber dano
	ON_ENEMY_DEATH,       # Ao matar inimigo
	ON_CORRUPTION_GAIN,   # Ao ganhar Corrupção
	PASSIVE               # Efeito sempre ativo
}

@export var artifact_name: String = "Artefato Misterioso"
@export_multiline var description: String = "Descrição do artefato."
@export var flavor_text: String = ""  # Texto Lovecraftiano
@export var rarity: ArtifactRarity = ArtifactRarity.COMMON

# Efeitos do artefato
@export var effect_trigger: EffectTrigger = EffectTrigger.PASSIVE
@export var effect_id: String = ""  # ID único do efeito para código reconhecer

# Stats modificadores (para efeitos PASSIVE)
@export var max_hp_bonus: int = 0
@export var max_sanity_bonus: int = 0
@export var sanity_regen_bonus: int = 0
@export var damage_multiplier: float = 1.0  # 1.1 = +10% dano
@export var block_multiplier: float = 1.0
@export var corruption_per_turn: int = 0  # Corrupção passiva por turno

# Efeitos de gatilho (valores usados quando effect_trigger não é PASSIVE)
@export var trigger_value: int = 0  # Valor genérico (cura, dano, etc)
@export var trigger_corruption: int = 0  # Corrupção ao ativar efeito

func get_rarity_name() -> String:
	match rarity:
		ArtifactRarity.COMMON:
			return "Comum"
		ArtifactRarity.UNCOMMON:
			return "Incomum"
		ArtifactRarity.RARE:
			return "Raro"
		ArtifactRarity.BOSS:
			return "Boss"
		ArtifactRarity.CURSED:
			return "Amaldiçoado"
	return "Desconhecido"

func get_rarity_color() -> Color:
	match rarity:
		ArtifactRarity.COMMON:
			return Color(0.7, 0.7, 0.7)  # Cinza
		ArtifactRarity.UNCOMMON:
			return Color(0.3, 0.8, 0.3)  # Verde
		ArtifactRarity.RARE:
			return Color(0.3, 0.5, 1.0)  # Azul
		ArtifactRarity.BOSS:
			return Color(0.9, 0.5, 0.2)  # Laranja
		ArtifactRarity.CURSED:
			return Color(0.7, 0.2, 0.7)  # Roxo
	return Color.WHITE
