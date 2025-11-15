extends Node2D

@onready var player_health: PlayerHealth = $PlayerHealth
@onready var health_bar: ProgressBar = $PlayerHealthBar
@onready var corruption = $Corruption
@onready var corruption_bar: ProgressBar = $CorruptionBar
@onready var player_sanity = $PlayerSanity
@onready var sanity_bar: ProgressBar = $SanityBar
@onready var player_block = $PlayerBlock
@onready var block_bar: ProgressBar = $BlockBar
@onready var player_status_manager = $PlayerStatusManager
@onready var enemy_status_manager = $EnemyStatusManager
@onready var ritual_manager = $RitualManager
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

# Pool de tipos de inimigos
var enemy_types: Array[Resource] = [
	preload("res://resources/enemies/cultist.tres"),
	preload("res://resources/enemies/brute.tres"),
	preload("res://resources/enemies/defender.tres")
]

func _ready() -> void:
	# Conectar signals de vida
	player_health.health_changed.connect(_on_player_health_changed)
	player_health.player_died.connect(_on_player_died)

	# Conectar signals de corrupção
	corruption.corruption_changed.connect(_on_corruption_changed)
	corruption.corruption_maxed.connect(_on_corruption_maxed)

	# Conectar signals de sanidade
	player_sanity.sanity_changed.connect(_on_sanity_changed)
	player_sanity.went_insane.connect(_on_went_insane)

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
	_on_sanity_changed(player_sanity.current_sanity, player_sanity.max_sanity)
	_on_block_changed(player_block.current_block)

	# Configurar bloqueio no player_health
	player_health.set_player_block(player_block)

	# Configurar status_manager no player_health
	player_health.set_status_manager(player_status_manager)

	# Inicializar deck
	_initialize_deck()
	hand.set_deck(deck)

	# Inicializar inimigo aleatório
	_spawn_random_enemy()

	# Iniciar o primeiro turno
	turn_manager.initialize()

func _spawn_random_enemy() -> void:
	# Escolher tipo de inimigo aleatório
	var random_enemy_data = enemy_types[randi() % enemy_types.size()]
	enemy.initialize_from_data(random_enemy_data)
	print("Inimigo spawnou: %s (HP: %d)" % [random_enemy_data.enemy_name, random_enemy_data.max_health])

func _initialize_deck() -> void:
	# Usar deck do GameState ao invés de criar novo
	deck.initialize(GameState.player_deck)

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

func _on_sanity_changed(current: int, maximum: int) -> void:
	sanity_bar.max_value = maximum
	sanity_bar.value = current

func _on_went_insane() -> void:
	print("!!! JOGADOR ENLOUQUECEU !!!")
	# TODO: Adicionar efeitos visuais de enlouquecimento
	# TODO: Cartas ficam mais fortes mas aleatórias?

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
	player_sanity.restore_partial()  # Regenera apenas parcialmente!

	# Reduzir duração dos status effects do jogador
	player_status_manager.reduce_all_durations()

	# MECÂNICA LOVECRAFTIANA: Progredir rituais ativos!
	ritual_manager.progress_rituals(enemy)

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
		2: # ActionType.BUFF
			var strength = action.strength
			enemy_status_manager.apply_status(StatusEffect.EffectType.STRENGTH, strength, -1)
			print("Inimigo usou %s ganhando %d de Força!" % [action.name, strength])
		_:
			print("Inimigo usou %s!" % action.name)

	# Aguardar 1 segundo antes de terminar o turno
	await get_tree().create_timer(1.0).timeout
	turn_manager.end_enemy_turn()

func _on_end_turn_pressed() -> void:
	turn_manager.end_player_turn()

func _on_enemy_died() -> void:
	print("Inimigo morreu! Vitória!")
	# Ir para tela de recompensas ao invés de game over
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/rewards/rewards.tscn")

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

	# MECÂNICA LOVECRAFTIANA: Corrupção aumenta poder!
	# Cada ponto de Corrupção = +1% de dano
	# Exemplo: 50 de Corrupção = +50% de dano!
	var corruption_percentage = corruption.current_corruption
	if corruption_percentage > 0:
		var bonus_damage = int(base_damage * (corruption_percentage / 100.0))
		damage += bonus_damage
		print("⚠ CORRUPÇÃO %.0f - Bônus: +%d dano (%d → %d)" % [corruption_percentage, bonus_damage, base_damage, damage])

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

func _calculate_player_block(base_block: int) -> int:
	var block = base_block

	# MECÂNICA LOVECRAFTIANA: Corrupção aumenta bloqueio também!
	# Cada ponto de Corrupção = +1% de bloqueio
	# Exemplo: 50 de Corrupção = +50% de bloqueio!
	var corruption_percentage = corruption.current_corruption
	if corruption_percentage > 0:
		var bonus_block = int(base_block * (corruption_percentage / 100.0))
		block += bonus_block
		print("⚠ CORRUPÇÃO %.0f - Bônus: +%d bloqueio (%d → %d)" % [corruption_percentage, bonus_block, base_block, block])

	# TODO: Adicionar outros modificadores de bloqueio (ex: Dexterity)

	return block

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

	# Verificar se tem sanidade suficiente
	if not player_sanity.has_sanity(card_data.energy_cost):
		print("Sanidade insuficiente!")
		return

	# Gastar sanidade
	if not player_sanity.spend_sanity(card_data.energy_cost):
		print("Falha ao gastar sanidade!")
		return

	# Remover a carta da mão (exhaust se necessário)
	var card_to_remove = null
	for card in hand.cards_in_hand:
		if card.card_data == card_data:
			card_to_remove = card
			break

	if card_to_remove:
		hand.remove_card(card_to_remove, card_data.is_exhaust)

	# MECÂNICA LOVECRAFTIANA: Iniciar ritual se for carta de ritual!
	if card_data.is_ritual:
		ritual_manager.start_ritual(card_data)
		# Rituais não aplicam efeitos imediatamente, apenas iniciam
		return

	# Aplicar dano no inimigo (verificar se ainda existe)
	if card_data.damage > 0 and is_instance_valid(enemy):
		var final_damage = _calculate_player_damage(card_data.damage)
		enemy.take_damage(final_damage)
		print("Carta jogada: %s - Dano base: %d - Dano final: %d - Energia gasta: %d" % [card_data.card_name, card_data.damage, final_damage, card_data.energy_cost])

	# Ganhar bloqueio (com bônus de Corrupção!)
	if card_data.block > 0:
		var final_block = _calculate_player_block(card_data.block)
		player_block.gain_block(final_block)
		print("Carta jogada: %s - Bloqueio base: %d - Bloqueio final: %d - Energia gasta: %d" % [card_data.card_name, card_data.block, final_block, card_data.energy_cost])

	# Curar vida
	if card_data.heal > 0:
		player_health.heal(card_data.heal)
		print("Carta jogada: %s - Cura: %d - Energia gasta: %d" % [card_data.card_name, card_data.heal, card_data.energy_cost])

	# Comprar cartas
	if card_data.draw_cards > 0:
		hand.draw_cards(card_data.draw_cards)
		print("Carta jogada: %s - Comprou %d cartas - Energia gasta: %d" % [card_data.card_name, card_data.draw_cards, card_data.energy_cost])

	# Ganhar sanidade
	if card_data.energy_gain > 0:
		player_sanity.restore_sanity(card_data.energy_gain)
		print("Carta jogada: %s - Ganhou %d sanidade - Sanidade gasta: %d" % [card_data.card_name, card_data.energy_gain, card_data.energy_cost])

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
