extends Node
class_name ArtifactManager

## Gerencia artefatos ativos e seus efeitos durante combate

signal artifact_triggered(artifact_name: String, effect: String)

var active_artifacts: Array[ArtifactData] = []

func _ready() -> void:
	# Carregar artefatos do GameState quando implementado
	pass

func add_artifact(artifact: ArtifactData) -> void:
	active_artifacts.append(artifact)
	print("🔮 Artefato obtido: %s" % artifact.artifact_name)

func get_stat_multiplier(stat_type: String) -> float:
	var multiplier = 1.0

	for artifact in active_artifacts:
		match stat_type:
			"damage":
				multiplier *= artifact.damage_multiplier
			"block":
				multiplier *= artifact.block_multiplier

	return multiplier

func get_stat_bonus(stat_type: String) -> int:
	var bonus = 0

	for artifact in active_artifacts:
		match stat_type:
			"max_hp":
				bonus += artifact.max_hp_bonus
			"max_sanity":
				bonus += artifact.max_sanity_bonus
			"sanity_regen":
				bonus += artifact.sanity_regen_bonus

	return bonus

func trigger_effect(trigger_type: ArtifactData.EffectTrigger, context: Dictionary = {}) -> void:
	for artifact in active_artifacts:
		if artifact.effect_trigger == trigger_type:
			_execute_artifact_effect(artifact, context)

func _execute_artifact_effect(artifact: ArtifactData, context: Dictionary) -> void:
	print("⚡ Artefato '%s' ativado!" % artifact.artifact_name)
	artifact_triggered.emit(artifact.artifact_name, artifact.effect_id)

	# Efeitos específicos por ID
	match artifact.effect_id:
		"heal_on_combat_start":
			if context.has("player"):
				context["player"].heal(artifact.trigger_value)

		"damage_on_turn_start":
			if context.has("enemy"):
				context["enemy"].take_damage(artifact.trigger_value)

		"gain_corruption_on_kill":
			if context.has("corruption"):
				context["corruption"].add_corruption(artifact.trigger_corruption)

		"heal_on_kill":
			if context.has("player"):
				context["player"].heal(artifact.trigger_value)

func get_passive_corruption_per_turn() -> int:
	var total = 0
	for artifact in active_artifacts:
		total += artifact.corruption_per_turn
	return total

func has_artifact(artifact_name: String) -> bool:
	for artifact in active_artifacts:
		if artifact.artifact_name == artifact_name:
			return true
	return false
