# res://scripts/weapons/EspadaSimple.gd
class_name EspadaSimple
extends Arma

## Arma básica de prueba. Hereda de Arma e implementa atacar().

func _ready() -> void:
	damage = 25
	attack_cooldown = 0.4

func atacar() -> void:
	if not puede_atacar():
		return
	_cooldown_timer = attack_cooldown
	_golpear_enemigos_cercanos()

func _golpear_enemigos_cercanos() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		if enemy.global_position.distance_to(global_position) <= 60.0:
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage)
