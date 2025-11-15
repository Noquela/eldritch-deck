extends Node2D

@onready var player_health: PlayerHealth = $PlayerHealth
@onready var health_bar: ProgressBar = $PlayerHealthBar
@onready var corruption = $Corruption
@onready var corruption_bar: ProgressBar = $CorruptionBar
@onready var hand = $Hand

# Pool de cartas disponíveis
var card_pool: Array[Resource] = []

func _ready() -> void:
	# Conectar signals de vida
	player_health.health_changed.connect(_on_player_health_changed)
	player_health.player_died.connect(_on_player_died)

	# Conectar signals de corrupção
	corruption.corruption_changed.connect(_on_corruption_changed)
	corruption.corruption_maxed.connect(_on_corruption_maxed)

	# Atualizar UI inicial
	_on_player_health_changed(player_health.current_health, player_health.max_health)
	_on_corruption_changed(corruption.current_corruption, corruption.max_corruption)

	# Inicializar pool de cartas e comprar mão inicial
	_initialize_card_pool()
	hand.set_card_pool(card_pool)
	hand.draw_cards(3)

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
