extends Node2D

@onready var player_health: PlayerHealth = $PlayerHealth
@onready var health_bar: ProgressBar = $PlayerHealthBar
@onready var corruption = $Corruption
@onready var corruption_bar: ProgressBar = $CorruptionBar

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
