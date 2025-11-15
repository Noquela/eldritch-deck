extends Node2D

@onready var player_health: PlayerHealth = $PlayerHealth
@onready var health_bar: ProgressBar = $PlayerHealthBar
@onready var corruption = $Corruption
@onready var corruption_bar: ProgressBar = $CorruptionBar
@onready var player_energy = $PlayerEnergy
@onready var energy_bar: ProgressBar = $EnergyBar
@onready var turn_manager = $TurnManager
@onready var end_turn_button: Button = $EndTurnButton
@onready var hand = $Hand
@onready var enemy = $Enemy

# Pool de cartas disponíveis
var card_pool: Array[Resource] = []

func _ready() -> void:
	# Conectar signals de vida
	player_health.health_changed.connect(_on_player_health_changed)
	player_health.player_died.connect(_on_player_died)

	# Conectar signals de corrupção
	corruption.corruption_changed.connect(_on_corruption_changed)
	corruption.corruption_maxed.connect(_on_corruption_maxed)

	# Conectar signals de energia
	player_energy.energy_changed.connect(_on_energy_changed)

	# Conectar signals de turno
	turn_manager.player_turn_started.connect(_on_player_turn_started)
	turn_manager.enemy_turn_started.connect(_on_enemy_turn_started)
	turn_manager.enemy_turn_ended.connect(_on_enemy_turn_ended)

	# Conectar botão de End Turn
	end_turn_button.pressed.connect(_on_end_turn_pressed)

	# Conectar signal de carta jogada
	hand.card_played.connect(_on_card_played)

	# Atualizar UI inicial
	_on_player_health_changed(player_health.current_health, player_health.max_health)
	_on_corruption_changed(corruption.current_corruption, corruption.max_corruption)
	_on_energy_changed(player_energy.current_energy, player_energy.max_energy)

	# Inicializar pool de cartas
	_initialize_card_pool()
	hand.set_card_pool(card_pool)

	# Iniciar o primeiro turno
	turn_manager.initialize()

func _initialize_card_pool() -> void:
	card_pool.append(load("res://resources/cards/strike.tres"))
	card_pool.append(load("res://resources/cards/heavy_strike.tres"))
	card_pool.append(load("res://resources/cards/devastating_blow.tres"))

func _on_player_health_changed(current: int, maximum: int) -> void:
	health_bar.max_value = maximum
	health_bar.value = current

func _on_player_died() -> void:
	print("Player morreu!")

func _on_corruption_changed(current: float, maximum: float) -> void:
	corruption_bar.max_value = maximum
	corruption_bar.value = current

func _on_corruption_maxed() -> void:
	print("Corrupção máxima! Game Over!")

func _on_energy_changed(current: int, maximum: int) -> void:
	energy_bar.max_value = maximum
	energy_bar.value = current

func _on_player_turn_started() -> void:
	player_energy.restore_full()
	hand.draw_cards(3)
	end_turn_button.disabled = false

	# Escolher próxima ação do inimigo e mostrar intenção
	enemy.choose_action()
	enemy.show_intention()

func _on_enemy_turn_started() -> void:
	end_turn_button.disabled = true
	hand.clear_hand()
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

	# Remover a carta da mão
	var card_to_remove = null
	for card in hand.cards_in_hand:
		if card.card_data == card_data:
			card_to_remove = card
			break

	if card_to_remove:
		hand.remove_card(card_to_remove)

	# Aplicar dano no inimigo
	if card_data.damage > 0:
		enemy.take_damage(card_data.damage)
		print("Carta jogada: %s - Dano: %d - Energia gasta: %d" % [card_data.card_name, card_data.damage, card_data.energy_cost])

	# Adicionar corrupção se houver
	if card_data.corruption_cost > 0:
		corruption.add_corruption(card_data.corruption_cost)
		print("Corrupção adicionada: %d" % card_data.corruption_cost)
