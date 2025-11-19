extends Resource
class_name BossPhase

## Representa uma fase do boss com padrões de ataque únicos

@export var phase_name: String = "Fase 1"
@export var hp_threshold: float = 1.0  # % de HP para ativar (1.0 = 100%, 0.33 = 33%)
@export var phase_description: String = ""

## Padrões de ataque
@export var min_damage: int = 5
@export var max_damage: int = 10
@export var block_amount: int = 8

## Pesos para IA (0-100, total deve ser ~100)
@export var attack_weight: int = 60
@export var defend_weight: int = 20
@export var special_ability_weight: int = 20

## Habilidades especiais
@export var can_apply_strength: bool = false
@export var strength_amount: int = 0
@export var can_apply_weakness: bool = false
@export var weakness_amount: int = 0
@export var can_apply_vulnerable: bool = false
@export var vulnerable_amount: int = 0

## Multi-ataques
@export var can_multi_attack: bool = false
@export var multi_attack_count: int = 2

## Habilidade especial única da fase
@export var special_ability_name: String = ""
@export var special_ability_description: String = ""

## Retorna ação do boss baseado em pesos
func get_boss_action() -> String:
	var total = attack_weight + defend_weight + special_ability_weight
	var roll = randi() % total

	if roll < attack_weight:
		return "attack"
	elif roll < attack_weight + defend_weight:
		return "defend"
	else:
		return "special"

## Retorna dano do ataque
func get_attack_damage() -> int:
	if can_multi_attack:
		# Multi-ataque faz menos dano individual
		return randi_range(min_damage / 2, max_damage / 2)
	else:
		return randi_range(min_damage, max_damage)
