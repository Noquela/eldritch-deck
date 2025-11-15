extends Node
class_name PlayerBlock

signal block_changed(current: int)
signal block_gained(amount: int)
signal block_lost(amount: int)

var current_block: int = 0

func gain_block(amount: int) -> void:
	current_block += amount
	block_changed.emit(current_block)
	block_gained.emit(amount)
	print("Bloqueio ganho: +%d (Total: %d)" % [amount, current_block])

func lose_block(amount: int) -> int:
	var lost = min(current_block, amount)
	current_block -= lost
	block_changed.emit(current_block)
	if lost > 0:
		block_lost.emit(lost)
	return lost

func reset_block() -> void:
	if current_block > 0:
		print("Bloqueio resetado: %d → 0" % current_block)
		current_block = 0
		block_changed.emit(current_block)

func get_block() -> int:
	return current_block
