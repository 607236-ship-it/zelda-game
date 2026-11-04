extends Node

signal player_health_changed(current_health: int, max_health: int)

var max_health: int = 6
var current_health: int = 6:
	set(value):
		current_health = clampi(value, 0, max_health)
		player_health_changed.emit(current_health, max_health)

func damage_player(amount: int) -> void:
	current_health -= amount
	if current_health <= 0:
		call_deferred("_respawn_player")

func _respawn_player() -> void:
	current_health = max_health
	get_tree().reload_current_scene()
