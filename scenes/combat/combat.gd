extends Node2D

@onready var player_health: PlayerHealth = $PlayerHealth
@onready var health_bar: ProgressBar = $PlayerHealthBar
@onready var corruption = $Corruption
@onready var corruption_bar: ProgressBar = $CorruptionBar
@onready var player_energy = $PlayerEnergy
@onready var energy_bar: ProgressBar = $EnergyBar
@onready var player_block = $PlayerBlock
@onready var block_bar: ProgressBar = $BlockBar
@onready var player_status_manager = $PlayerStatusManager
@onready var enemy_status_manager = $EnemyStatusManager
@onready var turn_manager = $TurnManager
@onready var deck = $Deck
@onready var end_turn_button: Button = $EndTurnButton
@onready var hand = $Hand
@onready var enemy = $Enemy
@onready var game_over_panel: Panel = $GameOverPanel
@onready var game_over_label: Label = $GameOverPanel/GameOverLabel
@onready var restart_button: Button = $GameOverPanel/RestartButton
@onready var player_status_label: Label = $PlayerStatusLabel
@onready var enemy_status_label: Label = $EnemyStatusLabel

# Pool de cartas iniciais para o deck
var initial_deck_cards: Array[Resource] = []

func _ready() -> void:
	# Conectar signals de vida
	player_health.health_changed.connect(_on_player_health_changed)
	player_health.player_died.connect(_on_player_died)

	# Conectar signals de corrupção
	corruption.corruption_changed.connect(_on_corruption_changed)
	corruption.corruption_maxed.connect(_on_corruption_maxed)

	# Conectar signals de energia
	player_energy.energy_changed.connect(_on_energy_changed)

	# Conectar signals de bloqueio
	player_block.block_changed.connect(_on_block_changed)

	# Conectar signals de status effects
	player_status_manager.status_applied.connect(_on_player_status_changed)
	player_status_manager.status_removed.connect(_on_player_status_changed)
	player_status_manager.status_updated.connect(_on_player_status_changed)
	enemy_status_manager.status_applied.connect(_on_enemy_status_changed)
	enemy_status_manager.status_removed.connect(_on_enemy_status_changed)
	enemy_status_manager.status_updated.connect(_on_enemy_status_changed)

	# Conectar signals de turno
	turn_manager.player_turn_started.connect(_on_player_turn_started)
	turn_manager.enemy_turn_started.connect(_on_enemy_turn_started)
	turn_manager.enemy_turn_ended.connect(_on_enemy_turn_ended)

	# Conectar signals do inimigo
	enemy.enemy_died.connect(_on_enemy_died)

	# Conectar botão de End Turn
	end_turn_button.pressed.connect(_on_end_turn_pressed)

	# Conectar botão de Restart
	restart_button.pressed.connect(_on_restart_pressed)

	# Conectar signal de carta jogada
	hand.card_played.connect(_on_card_played)

	# Atualizar UI inicial
	_on_player_health_changed(player_health.current_health, player_health.max_health)
	_on_corruption_changed(corruption.current_corruption, corruption.max_corruption)
	_on_energy_changed(player_energy.current_energy, player_energy.max_energy)
	_on_block_changed(player_block.current_block)

	# Configurar bloqueio no player_health
	player_health.set_player_block(player_block)

	# Configurar status_manager no player_health
	player_health.set_status_manager(player_status_manager)

	# Inicializar deck
	_initialize_deck()
	hand.set_deck(deck)

	# Iniciar o primeiro turno
	turn_manager.initialize()

func _initialize_deck() -> void:
	# Ataques: 5x Strike, 2x Heavy Strike, 1x Devastating Blow, 1x Desperate Strike
	for i in range(5):
		initial_deck_cards.append(load("res://resources/cards/strike.tres"))
	for i in range(2):
		initial_deck_cards.append(load("res://resources/cards/heavy_strike.tres"))
	initial_deck_cards.append(load("res://resources/cards/devastating_blow.tres"))
	initial_deck_cards.append(load("res://resources/cards/desperate_strike.tres"))

	# Defesa: 3x Defend, 1x Iron Wall
	for i in range(3):
		initial_deck_cards.append(load("res://resources/cards/defend.tres"))
	initial_deck_cards.append(load("res://resources/cards/iron_wall.tres"))

	# Skills: 1x Bandage, 1x Insight, 1x Enfeeble, 1x Expose
	initial_deck_cards.append(load("res://resources/cards/bandage.tres"))
	initial_deck_cards.append(load("res://resources/cards/insight.tres"))
	initial_deck_cards.append(load("res://resources/cards/enfeeble.tres"))
	initial_deck_cards.append(load("res://resources/cards/expose.tres"))

	# Powers: 1x Offering, 1x Flex
	initial_deck_cards.append(load("res://resources/cards/offering.tres"))
	initial_deck_cards.append(load("res://resources/cards/flex.tres"))

	deck.initialize(initial_deck_cards)

func _on_player_health_changed(current: int, maximum: int) -> void:
	health_bar.max_value = maximum
	health_bar.value = current

func _on_player_died() -> void:
	print("Player morreu!")
	_show_game_over(false)

func _on_corruption_changed(current: float, maximum: float) -> void:
	corruption_bar.max_value = maximum
	corruption_bar.value = current

func _on_corruption_maxed() -> void:
	print("Corrupção máxima! Game Over!")
	_show_game_over(false)

func _on_energy_changed(current: int, maximum: int) -> void:
	energy_bar.max_value = maximum
	energy_bar.value = current

func _on_block_changed(current: int) -> void:
	block_bar.value = current

func _on_player_status_changed(_effect_type = null, _stacks: int = 0) -> void:
	_update_status_label(player_status_manager, player_status_label)

func _on_enemy_status_changed(_effect_type = null, _stacks: int = 0) -> void:
	_update_status_label(enemy_status_manager, enemy_status_label)

func _update_status_label(manager, label: Label) -> void:
	var effects = manager.get_all_effects()
	if effects.is_empty():
		label.text = ""
		return

	var status_text = []
	for effect in effects:
		var effect_name = effect.get_effect_name()
		var effect_stacks = effect.stacks
		var duration_text = ""
		if effect.duration > 0:
			duration_text = " (%d)" % effect.duration
		status_text.append("%s x%d%s" % [effect_name, effect_stacks, duration_text])

	label.text = " | ".join(status_text)

func _on_player_turn_started() -> void:
	# Resetar bloqueio no início do turno
	player_block.reset_block()
	player_energy.restore_full()

	# Reduzir duração dos status effects do jogador
	player_status_manager.reduce_all_durations()

	hand.draw_cards(3)
	end_turn_button.disabled = false

	# Escolher próxima ação do inimigo e mostrar intenção
	enemy.choose_action()
	enemy.show_intention()

func _on_enemy_turn_started() -> void:
	end_turn_button.disabled = true
	hand.discard_hand()

	# Reduzir duração dos status effects do inimigo
	enemy_status_manager.reduce_all_durations()

	# Aguardar 1 segundo antes do inimigo agir
	await get_tree().create_timer(1.0).timeout
	_enemy_take_action()

func _on_enemy_turn_ended() -> void:
	pass

func _enemy_take_action() -> void:
	var action = enemy.get_next_action()

	if action.is_empty():
		print("Inimigo não tem ação definida!")
		turn_manager.end_enemy_turn()
		return

	match action.type:
		0: # ActionType.ATTACK
			var damage = action.damage
			player_health.take_damage(damage)
			print("Inimigo usou %s causando %d de dano!" % [action.name, damage])
		1: # ActionType.DEFEND
			var block = action.block
			print("Inimigo usou %s ganhando %d de bloqueio!" % [action.name, block])
		_:
			print("Inimigo usou %s!" % action.name)

	# Aguardar 1 segundo antes de terminar o turno
	await get_tree().create_timer(1.0).timeout
	turn_manager.end_enemy_turn()

func _on_end_turn_pressed() -> void:
	turn_manager.end_player_turn()

func _on_enemy_died() -> void:
	print("Inimigo morreu! Vitória!")
	_show_game_over(true)

func _show_game_over(victory: bool) -> void:
	game_over_panel.visible = true
	end_turn_button.disabled = true

	if victory:
		game_over_label.text = "VITÓRIA!"
		game_over_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
	else:
		game_over_label.text = "DERROTA!"
		game_over_label.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2))

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()

func _calculate_player_damage(base_damage: int) -> int:
	var damage = base_damage

	# Aplicar STRENGTH (aumenta dano)
	var strength = player_status_manager.get_status_stacks(StatusEffect.EffectType.STRENGTH)
	if strength > 0:
		damage += strength
		print("Força +%d: %d → %d" % [strength, base_damage, damage])

	# Aplicar WEAKNESS (reduz dano em 25% por stack)
	var weakness = player_status_manager.get_status_stacks(StatusEffect.EffectType.WEAKNESS)
	if weakness > 0:
		var reduction = int(damage * 0.25 * weakness)
		damage = max(0, damage - reduction)
		print("Fraqueza -%d (%d stacks): %d → %d" % [reduction, weakness, base_damage + strength, damage])

	return damage

func _get_effect_type_from_string(effect_string: String):
	match effect_string.to_upper():
		"STRENGTH":
			return StatusEffect.EffectType.STRENGTH
		"WEAKNESS":
			return StatusEffect.EffectType.WEAKNESS
		"VULNERABLE":
			return StatusEffect.EffectType.VULNERABLE
		"FRAIL":
			return StatusEffect.EffectType.FRAIL
		"REGEN":
			return StatusEffect.EffectType.REGEN
		"POISON":
			return StatusEffect.EffectType.POISON
		_:
			print("Status effect desconhecido: %s" % effect_string)
			return null

func _on_card_played(card_data: Resource) -> void:
	# Verificar se é turno do jogador
	if not turn_manager.is_player_turn():
		print("Não é seu turno!")
		return

	# Verificar se tem energia suficiente
	if not player_energy.has_energy(card_data.energy_cost):
		print("Energia insuficiente!")
		return

	# Gastar energia
	if not player_energy.spend_energy(card_data.energy_cost):
		print("Falha ao gastar energia!")
		return

	# Remover a carta da mão (exhaust se necessário)
	var card_to_remove = null
	for card in hand.cards_in_hand:
		if card.card_data == card_data:
			card_to_remove = card
			break

	if card_to_remove:
		hand.remove_card(card_to_remove, card_data.is_exhaust)

	# Aplicar dano no inimigo
	if card_data.damage > 0:
		var final_damage = _calculate_player_damage(card_data.damage)
		enemy.take_damage(final_damage)
		print("Carta jogada: %s - Dano base: %d - Dano final: %d - Energia gasta: %d" % [card_data.card_name, card_data.damage, final_damage, card_data.energy_cost])

	# Ganhar bloqueio
	if card_data.block > 0:
		player_block.gain_block(card_data.block)
		print("Carta jogada: %s - Bloqueio: %d - Energia gasta: %d" % [card_data.card_name, card_data.block, card_data.energy_cost])

	# Curar vida
	if card_data.heal > 0:
		player_health.heal(card_data.heal)
		print("Carta jogada: %s - Cura: %d - Energia gasta: %d" % [card_data.card_name, card_data.heal, card_data.energy_cost])

	# Comprar cartas
	if card_data.draw_cards > 0:
		hand.draw_cards(card_data.draw_cards)
		print("Carta jogada: %s - Comprou %d cartas - Energia gasta: %d" % [card_data.card_name, card_data.draw_cards, card_data.energy_cost])

	# Ganhar energia
	if card_data.energy_gain > 0:
		player_energy.current_energy += card_data.energy_gain
		player_energy.energy_changed.emit(player_energy.current_energy, player_energy.max_energy)
		print("Carta jogada: %s - Ganhou %d energia - Energia gasta: %d" % [card_data.card_name, card_data.energy_gain, card_data.energy_cost])

	# Efeitos especiais
	if card_data.effect_name == "self_damage":
		player_health.take_damage(card_data.effect_value)
		print("Efeito: Sofreu %d de dano" % card_data.effect_value)

	# Aplicar status effects no jogador
	if card_data.apply_player_status != "" and card_data.apply_player_stacks > 0:
		var effect_type = _get_effect_type_from_string(card_data.apply_player_status)
		if effect_type != null:
			player_status_manager.apply_status(effect_type, card_data.apply_player_stacks, card_data.apply_player_duration)

	# Aplicar status effects no inimigo
	if card_data.apply_enemy_status != "" and card_data.apply_enemy_stacks > 0:
		var effect_type = _get_effect_type_from_string(card_data.apply_enemy_status)
		if effect_type != null:
			enemy_status_manager.apply_status(effect_type, card_data.apply_enemy_stacks, card_data.apply_enemy_duration)

	# Adicionar corrupção se houver
	if card_data.corruption_cost > 0:
		corruption.add_corruption(card_data.corruption_cost)
		print("Corrupção adicionada: %d" % card_data.corruption_cost)
