# res://scripts/weapons/HealingHallway.gd
class_name HealingHallway
extends Area2D

const MAX_PLAYER_HEALTH: float = 300.0
const HEALING_RATE: float = 20.0   # puntos de vida por segundo

var player_in_corridor: Node2D = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	if player_in_corridor == null:
		return
	if not is_instance_valid(player_in_corridor):
		player_in_corridor = null
		return

	if player_in_corridor.health < MAX_PLAYER_HEALTH:
		player_in_corridor.health += HEALING_RATE * delta
		if player_in_corridor.health >= MAX_PLAYER_HEALTH:
			player_in_corridor.health = MAX_PLAYER_HEALTH
			print("Salud máxima restaurada (300 HP).")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("El jugador ha entrado al pasillo de curación.")
		player_in_corridor = body


func _on_body_exited(body: Node2D) -> void:
	if body == player_in_corridor:
		print("El jugador abandona el pasillo hacia la Fase Final.")
		player_in_corridor = null
