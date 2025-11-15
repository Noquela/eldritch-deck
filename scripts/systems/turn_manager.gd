extends Node
class_name TurnManager

signal turn_changed(is_player_turn: bool)
signal player_turn_started
signal player_turn_ended
signal enemy_turn_started
signal enemy_turn_ended

enum Turn { PLAYER, ENEMY }

var current_turn: Turn = Turn.PLAYER
var turn_number: int = 1

func _ready() -> void:
	start_player_turn()

func start_player_turn() -> void:
	current_turn = Turn.PLAYER
	print("=== Turno do Jogador %d ===" % turn_number)
	turn_changed.emit(true)
	player_turn_started.emit()

func end_player_turn() -> void:
	if current_turn != Turn.PLAYER:
		return

	print("=== Fim do turno do Jogador ===")
	player_turn_ended.emit()
	start_enemy_turn()

func start_enemy_turn() -> void:
	current_turn = Turn.ENEMY
	print("=== Turno do Inimigo ===")
	turn_changed.emit(false)
	enemy_turn_started.emit()

func end_enemy_turn() -> void:
	if current_turn != Turn.ENEMY:
		return

	print("=== Fim do turno do Inimigo ===")
	enemy_turn_ended.emit()
	turn_number += 1
	start_player_turn()

func is_player_turn() -> bool:
	return current_turn == Turn.PLAYER
