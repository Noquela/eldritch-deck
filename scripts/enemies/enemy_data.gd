extends Resource
class_name EnemyData

@export var enemy_name: String = ""
@export var max_health: int = 50
@export var min_damage: int = 5
@export var max_damage: int = 10
@export var block_amount: int = 8

# Pesos de ações (maior = mais provável)
@export var attack_weight: int = 60
@export var defend_weight: int = 30
@export var buff_weight: int = 10

# Tipos de buff que o inimigo pode aplicar
@export var can_apply_strength: bool = false
@export var strength_amount: int = 1

func _to_string() -> String:
	return "%s (HP: %d, Dano: %d-%d)" % [enemy_name, max_health, min_damage, max_damage]
